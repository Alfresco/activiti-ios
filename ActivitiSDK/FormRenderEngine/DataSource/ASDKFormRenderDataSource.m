/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import "ASDKFormRenderDataSource.h"

// Constants
#import "ASDKLocalizationConstants.h"
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLogConfiguration.h"

// Categories
#import "NSArray+ASDKFormRenderDataSourceArrayAddition.h"

// Protocols
#import "ASDKFormFieldDetailsControllerProtocol.h"
#import "ASDKFormEngineDataSourceActionHandlerDelegate.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelFormDescription.h"
#import "ASDKModelFormOutcome.h"
#import "ASDKModelDynamicTableFormField.h"
#import "ASDKModelFormTab.h"
#import "ASDKModelFormTabDescription.h"
#import "ASDKModelFormVariable.h"

// Managers
#import "ASDKFormVisibilityConditionsProcessor.h"
#import "ASDKKVOManager.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKFormRenderDataSource() <ASDKFormEngineDataSourceActionHandlerDelegate>

/**
 *  Holds a reference to the current form description used to initialize the data source
 */
@property (strong, nonatomic, readonly) ASDKModelFormDescription *currenFormDescription;

/**
 *  Property meant to hold reference to form outcomes models.
 */
@property (strong, nonatomic) NSArray *formOutcomes;
/**
 *  Property meant to hold reference to the form outcomes index path
 *  objects.
 */
@property (strong, nonatomic) NSMutableArray *formOutcomesIndexPaths;

/**
 *  Property meant to indicate whether the save action is available for the current
 *  data source context or not.
 */
@property (assign, nonatomic) BOOL isSaveActionAvailable;

/**
 *  Property meant to hold a reference to a KVO manager that will be monitoring
 *  the state of form field objects
 */
@property (strong, nonatomic) ASDKKVOManager *kvoManager;

@end

@implementation ASDKFormRenderDataSource


#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithTaskFormDescription:(ASDKModelFormDescription *)formDescription {
    self = [super init];
    
    if (self) {
        _isSaveActionAvailable = YES;
        _currenFormDescription = formDescription;
        
        ASDKModelFormOutcome *defaultFormOutcome = [ASDKModelFormOutcome new];
        defaultFormOutcome.name = ASDKLocalizedStringFromTable(kLocalizationDefaultFormOutcome, ASDKLocalizationTable, @"Default outcome");
        
        [self setupWithFormDescription:formDescription
                    defaultFormOutcome:defaultFormOutcome];
    }
    
    return self;
}

- (instancetype)initWithProcessDefinitionFormDescription:(ASDKModelFormDescription *)formDescription {
    self = [super init];
    
    if (self) {
        _isSaveActionAvailable = NO;
        _currenFormDescription = formDescription;
        
        ASDKModelFormOutcome *defaultFormOutcome = [ASDKModelFormOutcome new];
        defaultFormOutcome.name = ASDKLocalizedStringFromTable(kLocalizationStartProcessFormOutcome, ASDKLocalizationTable, @"Start process outcome");
        
        [self setupWithFormDescription:formDescription
                    defaultFormOutcome:defaultFormOutcome];
    }
    
    return self;
}

- (instancetype)initWithTabFormDescription:(ASDKModelFormTabDescription *)formDescription {
    self = [super init];
    
    if (self) {
        _isSaveActionAvailable = YES;
        _currenFormDescription = formDescription;
        self.formTitle = formDescription.formTitle;
        
        [self setupWithTabFormDescription:formDescription];
    }
    
    return self;
}

- (void)setupWithFormDescription:(ASDKModelFormDescription *)formDescription
              defaultFormOutcome:(ASDKModelFormOutcome *)defaultFormOutcome {
    // Prepare the KVO manager to handle visibility conditions re-evaluations
    self.kvoManager = [ASDKKVOManager managerWithObserver:self];
    
    // Parse the renderable form fields from the form description to a tab/section disposed array
    NSArray *renderableParsedFormFields = [self parseRenderableFormFieldsFromContainerList:formDescription.formFields
                                                                                   tabList:formDescription.formTabs];
    // Deep copy all renderable objects so that the initial collection remains
    // untouched by future mutations of sections and sub-section elements
    NSError *error = nil;
    NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject:renderableParsedFormFields
                                           requiringSecureCoding:NO
                                                           error:&error];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:buffer
                                                                                error:&error];
    unarchiver.requiresSecureCoding = NO;
    NSArray *renderableParsedFormFieldsCopy = [unarchiver decodeObjectOfClasses:[NSSet setWithObjects:NSMutableArray.class, ASDKModelFormField.class, nil]
                                                                         forKey:NSKeyedArchiveRootObjectKey];
    if (error) {
        ASDKLogError(@"Encountered an error while un/archiving the form description");
    }
    
    // Initialize the visibility condition processor with a plain array of form fields and form variables
    self.renderableFormFields = renderableParsedFormFieldsCopy;
    
    self.visibilityConditionsProcessor = [[ASDKFormVisibilityConditionsProcessor alloc] initWithFormFields:renderableParsedFormFields
                                                                                             formVariables:formDescription.formVariables];
    if (self.visibilityConditionsProcessor) {
        // Run a pre-process operation to evaluate visibility conditions and provide the first set of visible form
        // fields
        self.visibleFormFields = [self filterRenderableFormFields:renderableParsedFormFields
                                             forVisibleFormFields:[self.visibilityConditionsProcessor parseVisibleFormFields]];
        
        // Handle value changes for form fields that have a direct impact over visibility conditions
        [self registerVisibilityHandlersForInfluencialFormFields:[self.visibilityConditionsProcessor visibilityInfluentialFormFields]];
    } else {
        // If the visibility condition processor fails in it's initiation then fall back as a mean of recovery and
        // display all fields
        self.visibleFormFields = renderableParsedFormFields;
    }
    
    // Show the form outcomes only when the data source is in tab view mode or
    // there aren't any defined tabs
    if (ASDKFormRenderEngineDataSourceViewModeTabs == self.dataSourceViewMode ||
        !formDescription.formTabs.count) {
        self.formHasUserdefinedOutcomes = formDescription.formOutcomes.count ? YES : NO;
        self.formOutcomesIndexPaths = [NSMutableArray array];
        
        if (self.formHasUserdefinedOutcomes) {
            self.formOutcomes = formDescription.formOutcomes;
        } else {
            if (defaultFormOutcome) {
                self.formOutcomes = @[defaultFormOutcome];
            }
        }
    }
}

- (void)setupWithTabFormDescription:(ASDKModelFormTabDescription *)formTabDescription {
    // Prepare the KVO manager to handle visibility conditions re-evaluations
    self.kvoManager = [ASDKKVOManager managerWithObserver:self];
    
    // Parse the renderable form fields from the form description to a tab/section disposed array
    NSArray *renderableParsedFormFields = [self parseRenderableFormFieldsFromContainerList:formTabDescription.renderableTabFormFields
                                                                                   tabList:formTabDescription.formTabs];
    self.renderableFormFields = renderableParsedFormFields;
    
    // Initialize the visibility condition processor with a plain array of form fields and form variables
    self.visibilityConditionsProcessor = [[ASDKFormVisibilityConditionsProcessor alloc] initWithFormFields:formTabDescription.visibleTabFormFields
                                                                                             formVariables:formTabDescription.formVariables];
    
    // Run a pre-process operation to evaluate visibility conditions and provide the first set of visible form
    // fields
    self.visibleFormFields = [self filterRenderableFormFields:formTabDescription.visibleTabFormFields
                                         forVisibleFormFields:[self.visibilityConditionsProcessor parseVisibleFormFields]];
    
    // Handle value changes for form fields that have a direct impact over visibility conditions
    [self registerVisibilityHandlersForInfluencialFormFields:[self.visibilityConditionsProcessor visibilityInfluentialFormFields]];
}

- (void)dealloc {
    [self unregisterVisibilityHandlersForInfluencialFormFields:[self.visibilityConditionsProcessor visibilityInfluentialFormFields]];
}


#pragma mark -
#pragma mark ASDKFormRenderEngine Protocol

- (NSInteger)numberOfSectionsForCurrentFormDescription {
    // Where + 1 is the additional section for form outcomes
    return self.formOutcomes.count ? self.visibleFormFields.count + 1 : self.visibleFormFields.count;
}

- (NSInteger)numberOfFormFieldsForSection:(NSInteger)section {
    NSUInteger fieldsCount = 0;
    
    if (section >= self.visibleFormFields.count) {
        fieldsCount = self.formOutcomes.count;
    } else {
        if (ASDKFormRenderEngineDataSourceViewModeTabs == self.dataSourceViewMode) {
            fieldsCount = 1;
        } else {
            ASDKModelFormField *sectionFormField = self.visibleFormFields[section];
            
            if (sectionFormField.fieldType == ASDKModelFormFieldTypeDynamicTableField ||
                (ASDKModelFormFieldRepresentationTypeReadOnly == sectionFormField.representationType &&
                 ASDKModelFormFieldRepresentationTypeDynamicTable == sectionFormField.formFieldParams.representationType)) {
                    fieldsCount = 1;
                } else {
                    fieldsCount = sectionFormField.formFields.count;
                }
        }
    }
    
    return fieldsCount;
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = nil;
    
    if (indexPath.section >= self.visibleFormFields.count) {
        cellIdentifier = kASDKCellIDFormFieldOutcomeRepresentation;
    } else {
        if (ASDKFormRenderEngineDataSourceViewModeTabs == self.dataSourceViewMode) {
            cellIdentifier = kASDKCellIDFormFieldTabRepresentation;
        } else {
            ASDKModelFormField *sectionFormField = self.visibleFormFields[indexPath.section];
            
            if (sectionFormField.fieldType == ASDKModelFormFieldTypeDynamicTableField ||
                (ASDKModelFormFieldRepresentationTypeReadOnly == sectionFormField.representationType &&
                 ASDKModelFormFieldRepresentationTypeDynamicTable == sectionFormField.formFieldParams.representationType)) {
                    cellIdentifier = [self validCellIdentifierForFormField:sectionFormField];
                } else {
                    ASDKModelFormField *formFieldAtIndexPath = sectionFormField.formFields[indexPath.row];
                    cellIdentifier = [self validCellIdentifierForFormField:formFieldAtIndexPath];
                }
        }
    }
    
    return cellIdentifier;
}

- (ASDKModelAttributable *)modelForIndexPath:(NSIndexPath *)indexPath {
    ASDKModelAttributable *formFieldModel = nil;
    
    if (indexPath.section >= self.visibleFormFields.count) {
        ASDKModelFormOutcome *formOutcome = self.formOutcomes[indexPath.row];
        
        if (NSNotFound == [self.formOutcomesIndexPaths indexOfObject:indexPath]) {
            [self.formOutcomesIndexPaths addObject:indexPath];
        }
        
        formFieldModel = formOutcome;
    } else {
        if (ASDKFormRenderEngineDataSourceViewModeTabs == self.dataSourceViewMode) {
            formFieldModel = (ASDKModelFormTab *)self.visibleFormFields[indexPath.section];
        } else {
            ASDKModelFormField *sectionFormField = self.visibleFormFields[indexPath.section];
            
            if (sectionFormField.fieldType == ASDKModelFormFieldTypeDynamicTableField ||
                (ASDKModelFormFieldRepresentationTypeReadOnly == sectionFormField.representationType &&
                 ASDKModelFormFieldRepresentationTypeDynamicTable == sectionFormField.formFieldParams.representationType)) {
                    formFieldModel = sectionFormField;
                } else {// Set up the cell from the corresponding section
                    ASDKModelFormField *formFieldForCurrentIndexPath = [(ASDKModelFormField *)self.visibleFormFields[indexPath.section] formFields][indexPath.row];
                    
                    // If form variables exist for this form field attach their string value to the form field
                    // Double check if formFieldParams is a ASDKModelFormField derived object because it is
                    // probable to have other types of parameters that do not have the same inheritance
                    if ([formFieldForCurrentIndexPath.formFieldParams isKindOfClass:[ASDKModelFormField class]]) {
                        if (formFieldForCurrentIndexPath.formFieldParams.modelID) {
                            NSPredicate *searchVariablePredicate = [NSPredicate predicateWithFormat:@"name == %@", formFieldForCurrentIndexPath.formFieldParams.modelID];
                            NSArray *matchingVariables = [self.currenFormDescription.formVariables filteredArrayUsingPredicate:searchVariablePredicate];
                            if (matchingVariables.count &&
                                !formFieldForCurrentIndexPath.values.count) {
                                ASDKModelFormVariable *formVariable = (ASDKModelFormVariable *)matchingVariables.firstObject;
                                formFieldForCurrentIndexPath.values = @[formVariable.value];
                            } else if (formFieldForCurrentIndexPath.values.count) {
                                NSString *variableLabelName = [NSString stringWithFormat:@"%@_LABEL", formFieldForCurrentIndexPath.formFieldParams.modelID];
                                NSPredicate *searchVariableLabelValuePredicate = [NSPredicate predicateWithFormat:@"modelID == %@", variableLabelName];
                                matchingVariables = [self.currenFormDescription.formVariables filteredArrayUsingPredicate:searchVariableLabelValuePredicate];
                                
                                if (matchingVariables.count) {
                                    ASDKModelFormVariable *formVariable = (ASDKModelFormVariable *)matchingVariables.firstObject;
                                    formFieldForCurrentIndexPath.formFieldParams.values = @[formVariable];
                                }
                            }
                        }
                    }
                    
                    formFieldModel = formFieldForCurrentIndexPath;
                }
        }
    }
    
    return formFieldModel;
}

- (NSString *)sectionHeaderTitleForIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionHeaderTitleString = nil;
    
    if (ASDKFormRenderEngineDataSourceViewModeFormFields == self.dataSourceViewMode) {
        ASDKModelFormField *sectionFormField = indexPath.section < self.visibleFormFields.count ? self.visibleFormFields[indexPath.section] : nil;
        
        // We're checking for header representation types, we don't care for containers of
        // form field objects without a visual representation
        if (ASDKModelFormFieldRepresentationTypeHeader == sectionFormField.representationType) {
            sectionHeaderTitleString = sectionFormField.fieldName;
        }
    }
    
    return sectionHeaderTitleString;
}

- (NSArray *)indexPathsOfFormOutcomes {
    return self.formOutcomesIndexPaths;
}

- (UIViewController *)childControllerForFormField:(ASDKModelFormField *)formField {
    UIStoryboard *formStoryboard = [UIStoryboard storyboardWithName:kASDKFormStoryboardBundleName
                                                             bundle:[NSBundle bundleForClass:[self class]]];
    NSString *controllerIdentifier = [self controllerIdentifierForFormField:formField];
    
    if (controllerIdentifier) {
        UIViewController<ASDKFormFieldDetailsControllerProtocol> *childControllerInstance = [formStoryboard instantiateViewControllerWithIdentifier:controllerIdentifier];
        if ([childControllerInstance respondsToSelector:@selector(setupWithFormFieldModel:)]) {
            [childControllerInstance setupWithFormFieldModel:formField];
        }
        
        return childControllerInstance;
    } else {
        return nil;
    }
}

- (ASDKModelFormTabDescription *)formDescriptionForTabAtIndexPath:(NSIndexPath *)indexpath {
    ASDKModelFormTabDescription *tabFormDescription = [ASDKModelFormTabDescription new];
    tabFormDescription.processDefinitionID = self.currenFormDescription.processDefinitionID;
    tabFormDescription.processDefinitionName = self.currenFormDescription.processDefinitionName;
    tabFormDescription.processDefinitionKey = self.currenFormDescription.processDefinitionKey;
    tabFormDescription.formVariables = self.currenFormDescription.formVariables;
    
    ASDKModelFormTab *currentVisibleTab = (ASDKModelFormTab *)self.visibleFormFields[indexpath.section];
    ASDKModelFormTab *currentRenderableTab = (ASDKModelFormTab *)self.renderableFormFields[indexpath.section];
    tabFormDescription.visibleTabFormFields = [self.visibilityConditionsProcessor formFieldsForTabID:currentVisibleTab.modelID];
    tabFormDescription.renderableTabFormFields = currentRenderableTab.formFields;
    tabFormDescription.formTitle = currentVisibleTab.title;
    tabFormDescription.isReadOnlyForm = self.isReadOnlyForm;
    
    return tabFormDescription;
}


#pragma mark -
#pragma mark Form parser methods

- (NSArray *)parseRenderableFormFieldsFromContainerList:(NSArray *)containerList
                                                tabList:(NSArray *)tabList {
    NSMutableArray *sections = [NSMutableArray array];
    
    if (tabList.count) {
        _dataSourceViewMode = ASDKFormRenderEngineDataSourceViewModeTabs;
        
        for (ASDKModelFormTab *tab in tabList) {
            NSPredicate *containerFieldFromTabPredicate = [NSPredicate predicateWithFormat:@"tabID == %@", tab.modelID];
            NSArray *containerFieldsInTab = [containerList filteredArrayUsingPredicate:containerFieldFromTabPredicate];
            tab.formFields = [self parseFormFieldSectionsFromContainerList:containerFieldsInTab];
            [sections addObject:tab];
        }
    } else {
        _dataSourceViewMode = ASDKFormRenderEngineDataSourceViewModeFormFields;
        [sections addObjectsFromArray:[self parseFormFieldSectionsFromContainerList:containerList]];
    }
    
    return sections;
}

- (NSArray *)parseFormFieldSectionsFromContainerList:(NSArray *)containerList {
    NSMutableArray *formFieldSections = [NSMutableArray array];
    
    for (ASDKModelFormField *formField in containerList) {
        if (ASDKModelFormFieldTypeContainer == formField.fieldType) {
            formField.formFields = [self filterSupportedFormFields:formField.formFields];
            [formFieldSections addObject:formField];
        } else if (ASDKModelFormFieldTypeDynamicTableField == formField.fieldType ||
                   // if dynamic table or display value dynamic table
                   (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType &&
                    ASDKModelFormFieldRepresentationTypeDynamicTable == formField.formFieldParams.representationType)) {
                       [formFieldSections addObject:formField];
                   }
    }
    
    return formFieldSections;
}

- (NSArray *)filterRenderableFormFields:(NSArray *)renderableFormFields
                   forVisibleFormFields:(NSArray *)visibleFormFields {
    NSMutableArray *filteredArr = [NSMutableArray arrayWithArray:renderableFormFields];
    NSMutableIndexSet *sectionsToBeRemoved = [NSMutableIndexSet indexSet];
    
    for (int section = 0; section < filteredArr.count; section++) {
        ASDKModelAttributable *containerFormField = filteredArr[section];
        
        // Check first if the section / tab altogether is visible
        if (![visibleFormFields doesCollectionContainFormField:containerFormField]) {
            [sectionsToBeRemoved addIndex:section];
            continue;
        }
        
        NSMutableArray *formFieldsInSection = nil;
        if ([containerFormField isKindOfClass:ASDKModelFormTab.class]) {
            formFieldsInSection = [NSMutableArray arrayWithArray:((ASDKModelFormTab *)containerFormField).formFields];
        } else if ([containerFormField isKindOfClass:ASDKModelFormField.class]) {
            formFieldsInSection = [NSMutableArray arrayWithArray:((ASDKModelFormField *)containerFormField).formFields];
        }
        
        NSMutableArray *fieldsToBeRemoved = [NSMutableArray array];
        
        // Iterate over the list of form fields and remove the ones that are not inside
        // the visible form fields array
        for (ASDKModelFormField *formField in formFieldsInSection) {
            if (![visibleFormFields doesCollectionContainFormField:formField]) {
                [fieldsToBeRemoved addObject:formField];
            }
            // If dealing with nested form field structures from tabs, iterate through
            // section child form fields
            if (ASDKModelFormFieldTypeContainer == formField.fieldType) {
                NSMutableArray *formFieldsInContainer = [NSMutableArray arrayWithArray:formField.formFields];
                NSMutableArray *sectionFieldsToBeRemoved = [NSMutableArray array];
                
                for (ASDKModelFormField *sectionFormField in formFieldsInContainer) {
                    if (![visibleFormFields doesCollectionContainFormField:sectionFormField]) {
                        [sectionFieldsToBeRemoved addObject:sectionFormField];
                    }
                }
                [formFieldsInContainer removeObjectsInArray:sectionFieldsToBeRemoved];
            }
        }
        [formFieldsInSection removeObjectsInArray:fieldsToBeRemoved];
        
        if ([containerFormField isKindOfClass:ASDKModelFormField.class]) {
            // If a section has no more attached form fields and it's not a dynamic table remove it,
            // otherwise set the modified form field collection
            BOOL isReadOnlyDynamicTable = (ASDKModelFormFieldRepresentationTypeReadOnly == ((ASDKModelFormField *)containerFormField).representationType &&
                                           ASDKModelFormFieldRepresentationTypeDynamicTable == ((ASDKModelFormField *)containerFormField).formFieldParams.representationType);
            if (!formFieldsInSection.count &&
                (ASDKModelFormFieldTypeDynamicTableField != ((ASDKModelFormField *)containerFormField).fieldType &&
                 !isReadOnlyDynamicTable)) {
                    [sectionsToBeRemoved addIndex:section];
                } else {
                    ((ASDKModelFormField *)containerFormField).formFields = formFieldsInSection;
                }
        }
    }
    
    [filteredArr removeObjectsAtIndexes:sectionsToBeRemoved];
    
    return filteredArr;
}


#pragma mark -
#pragma mark Form validation methods

- (NSString *)validCellIdentifierForFormField:(ASDKModelFormField *)formField {
    NSString *cellIdentifier = nil;
    NSInteger representationType = ASDKModelFormFieldRepresentationTypeUndefined;
    
    // If dealing with read-only forms extract the representation type from the attached
    // form field params model
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType) {
        NSInteger formFieldParametersRepresentationType = formField.formFieldParams.representationType;
        representationType =  (formFieldParametersRepresentationType != ASDKModelFormFieldRepresentationTypeUndefined) ? formFieldParametersRepresentationType : ASDKModelFormFieldRepresentationTypeReadOnly;
    } else {
        representationType = formField.representationType;
    }
    
    switch (representationType) {
        case ASDKModelFormFieldRepresentationTypeText:
        case ASDKModelFormFieldRepresentationTypeNumerical:{
            cellIdentifier = kASDKCellIDFormFieldTextRepresentation;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeBoolean: {
            cellIdentifier = kASDKCellIDFormFieldBooleanRepresentation;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeAmount: {
            cellIdentifier = kASDKCellIDFormFieldAmountRepresentation;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeDropdown:
        case ASDKModelFormFieldRepresentationTypeRadio:
        case ASDKModelFormFieldRepresentationTypeTypeahead: {
            cellIdentifier = kASDKCellIDFormFieldRadioRepresentation;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeDate:
        case ASDKModelFormFieldRepresentationTypeDateTime: {
            cellIdentifier = kASDKCellIDFormFieldDateRepresentation;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeHyperlink: {
            cellIdentifier = kASDKCellIDFormFieldHyperlinkRepresentation;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeMultiline:
        case ASDKModelFormFieldRepresentationTypeReadOnly: {
            cellIdentifier = kASDKCellIDFormFieldMultilineRepresentation;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeReadonlyText: {
            cellIdentifier = kASDKCellIDFormFieldDisplayTextRepresentation;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeAttach: {
            cellIdentifier = kASDKCellIDFormFieldAttachRepresentation;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypePeople: {
            cellIdentifier = kASDKCellIDFormFieldPeopleRepresentation;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeDynamicTable: {
            cellIdentifier = kASDKCellIDFormFieldDynamicTableRepresentation;
        }
            break;
            
        default:
            break;
    }
    
    return cellIdentifier;
}

- (NSString *)controllerIdentifierForFormField:(ASDKModelFormField *)formField {
    NSString *controllerIdentifierString = nil;
    NSInteger representationType = ASDKModelFormFieldRepresentationTypeUndefined;
    
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType &&
        formField.formFieldParams) {
        if (ASDKModelFormFieldRepresentationTypeUndefined == formField.formFieldParams.representationType) {
            representationType = ASDKModelFormFieldRepresentationTypeReadonlyText;
        } else {
            representationType = formField.formFieldParams.representationType;
        }
    } else if (ASDKModelFormFieldRepresentationTypeReadOnly != formField.representationType) {
        representationType = formField.representationType;
    }
    
    switch (representationType) {
        case ASDKModelFormFieldRepresentationTypeDropdown:
        case ASDKModelFormFieldRepresentationTypeRadio: {
            controllerIdentifierString = kASDKStoryboardIDRadioFormFieldDetailController;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeDate:
        case ASDKModelFormFieldRepresentationTypeDateTime: {
            controllerIdentifierString = kASDKStoryboardIDDateFormFieldDetailController;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeMultiline:
        case ASDKModelFormFieldRepresentationTypeReadonlyText: {
            controllerIdentifierString = kASDKStoryboardIDMultilineFormFieldDetailController;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeAttach: {
            controllerIdentifierString = kASDKStoryboardIDAttachFormFieldDetailController;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypePeople: {
            controllerIdentifierString = kASDKStoryboardIDPeopleFormFieldDetailController;
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeDynamicTable: {
            controllerIdentifierString = kASDKStoryboardIDDynamicTableFormFieldDetailController;
        }
            break;
        case ASDKModelFormFieldRepresentationTypeTypeahead: {
            controllerIdentifierString = kASDKStoryboardIDTypeaheadFormFieldDetailController;
        }
            
        default:
            break;
    }
    
    return controllerIdentifierString;
}

- (NSArray *)filterSupportedFormFields:(NSArray *)formFieldsArr {
    NSMutableArray *supportedFormFields = [NSMutableArray array];
    
    for (ASDKModelFormField *formField in formFieldsArr) {
        if ([self validCellIdentifierForFormField:formField])
            [supportedFormFields addObject:formField];
    }
    
    return supportedFormFields;
}

- (BOOL)areFormFieldMetadataValuesValid {
    // Check if mandatory form field values had been addressed
    for (ASDKModelFormField *sectionFormField in self.visibleFormFields) {
        if ([sectionFormField isKindOfClass:ASDKModelDynamicTableFormField.class]) { // Extract formfields from dynamic table
            NSMutableArray *dynamicTableFormFields = [NSMutableArray new];
            
            // Add the dynamic table itself
            [dynamicTableFormFields addObject:sectionFormField];
            
            for (NSArray *dynamicTableRow in sectionFormField.values) {
                [dynamicTableFormFields addObjectsFromArray:dynamicTableRow];
            }
        }
        
        // Enumerate through the associated form fields and check if they
        // have a value or attached metadata values
        for (ASDKModelFormField *formField in sectionFormField.formFields) {
            if (ASDKModelFormFieldRepresentationTypeHeader == formField.representationType ||
                ASDKModelFormFieldRepresentationTypeContainer == formField.representationType) {
                for (ASDKModelFormField *containerChildFormField in formField.formFields) {
                    if (![self areFormFieldMetadataValuesValidForFormField:containerChildFormField]) {
                        return NO;
                    }
                }
            } else {
                if (![self areFormFieldMetadataValuesValidForFormField:formField]) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

- (BOOL)areFormFieldMetadataValuesValidForFormField:(ASDKModelFormField *)formField {
    BOOL formFieldsAreValid = YES;
    
    if (formField.isRequired) {
        if (formField.representationType == ASDKModelFormFieldRepresentationTypeBoolean) {
            BOOL checked = NO;
            if (formField.metadataValue.attachedValue.length) {
                checked = [formField.metadataValue.attachedValue isEqualToString:kASDKFormFieldTrueStringValue] ? YES : NO;
            } else if (formField.values) {
                checked = [formField.values.firstObject boolValue];
            }
            
            if (!checked) {
                formFieldsAreValid = NO;
            }
        } else if (!formField.values.count && !formField.metadataValue.attachedValue.length && !formField.metadataValue.option.attachedValue.length) {
            formFieldsAreValid = NO;
        }
    }
    
    return formFieldsAreValid;
}


#pragma mark -
#pragma mark Visibility handler methods

- (void)registerVisibilityHandlersForInfluencialFormFields:(NSSet *)influencialFormFields {
    for (ASDKModelFormField *influencialFormField in influencialFormFields) {
        __weak typeof(self) weakSelf = self;
        
        [self.kvoManager observeObject:influencialFormField
                            forKeyPath:NSStringFromSelector(@selector(metadataValue))
                               options:NSKeyValueObservingOptionNew
                                 block:^(id observer, id object, NSDictionary *change) {
                                     __strong typeof(self) strongSelf = weakSelf;
                                     [strongSelf handleVisibilityChangeForFormField:(ASDKModelFormField *)object];
                                 }];
    }
}

- (void)unregisterVisibilityHandlersForInfluencialFormFields:(NSSet *)influencialFormFields {
    for (ASDKModelFormField *influencialFormField in influencialFormFields) {
        [self.kvoManager removeObserver:influencialFormField
                             forKeyPath:NSStringFromSelector(@selector(metadataValue))];
    }
}

- (void)handleVisibilityChangeForFormField:(ASDKModelFormField *)formField {
    // Reevaluate visibility conditions
    NSDictionary *visibilityActionsDict = [self.visibilityConditionsProcessor reevaluateVisibilityConditionsAffectedByFormField:formField];
    
    NSMutableDictionary *indexPathOperations = [NSMutableDictionary dictionary];
    NSArray *fieldsToBeRemoved = visibilityActionsDict[@(ASDKFormVisibilityConditionActionTypeHideElement)];
    [indexPathOperations addEntriesFromDictionary:[self removeVisibleFormFieldsFromCollection:fieldsToBeRemoved]];
    NSArray *fieldsToBeAdded = visibilityActionsDict[@(ASDKFormVisibilityConditionActionTypeShowElement)];
    [indexPathOperations addEntriesFromDictionary:[self addVisibleFormFieldsFromCollection:fieldsToBeAdded]];
    
    // The form outcome indexes will have to be rebuilt
    [self.formOutcomesIndexPaths removeAllObjects];
    
    // Report index update operations to delegate
    if ([self.delegate respondsToSelector:@selector(requestControllerUpdateWithBatchOfOperations:)]) {
        [self.delegate requestControllerUpdateWithBatchOfOperations:indexPathOperations];
    }
}

- (NSDictionary *)addVisibleFormFieldsFromCollection:(NSArray *)fieldsToBeAdded {
    NSMutableDictionary *indexPathOperations = [NSMutableDictionary dictionary];
    NSMutableIndexSet *insertSectionIndexSet = [NSMutableIndexSet indexSet];
    NSMutableArray *insertIndexPaths = [NSMutableArray array];
    
    if (fieldsToBeAdded) {
        NSMutableArray *visibleFormFields = [NSMutableArray arrayWithArray:self.visibleFormFields];
        
        for (ASDKModelAttributable *field in fieldsToBeAdded) {
            BOOL isTabInsert = [field isKindOfClass:ASDKModelFormTab.class] ? YES : NO;
            
            if (isTabInsert) {
                NSUInteger originalTabIndex = [self.renderableFormFields sectionForTab:(ASDKModelFormTab *)field];
                NSUInteger insertIndex = [visibleFormFields insertIndexInFormFieldCollectionForSectionIndex:originalTabIndex
                                                                                       refferenceCollection:self.renderableFormFields];
                [visibleFormFields insertObject:field
                                        atIndex:insertIndex];
                
                [insertSectionIndexSet addIndex:insertIndex];
            } else if (ASDKFormRenderEngineDataSourceViewModeFormFields == self.dataSourceViewMode) {
                ASDKModelFormField *formFieldToBeInserted = (ASDKModelFormField *)field;
                BOOL isSectionInsert = (ASDKModelFormFieldTypeContainer == formFieldToBeInserted.fieldType);
                
                // To compute the insert index for the current form field we first look at it's position in the
                // renderable array (which holds all the form fields). We then take the previous item and check
                // if it's in the visible form fields collection and if so, that means the insert position is
                // after it. If not, we go back till the first element and repeat the process.
                
                if (isSectionInsert) {
                    NSUInteger originalSectionIndex = [self.renderableFormFields sectionForFormField:formFieldToBeInserted];
                    NSUInteger insertIndex = [visibleFormFields insertIndexInFormFieldCollectionForSectionIndex:originalSectionIndex
                                                                                           refferenceCollection:self.renderableFormFields];
                    [visibleFormFields insertObject:formFieldToBeInserted
                                            atIndex:insertIndex];
                    
                    [insertSectionIndexSet addIndex:insertIndex];
                } else {
                    // Check where the field was inside the renderable fields collection
                    NSUInteger originalSectionIndex = [self.renderableFormFields sectionForFormField:formFieldToBeInserted];
                    if (NSNotFound != originalSectionIndex) {
                        // Check if the section which contains the form field to be added is visible
                        if (![visibleFormFields doesCollectionContainFormField:self.renderableFormFields[originalSectionIndex]]) {
                            // If it doesn't then extract it from the renderable collection and only set
                            // the element to be added as a child
                            NSError *error = nil;
                            NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject:self.renderableFormFields[originalSectionIndex]
                                                                   requiringSecureCoding:NO
                                                                                   error:&error];
                            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:buffer
                                                                                                        error:&error];
                            unarchiver.requiresSecureCoding = NO;
                            ASDKModelFormField *sectionToBecomeVisible = [unarchiver decodeObjectOfClasses:[NSSet setWithObject: ASDKModelFormField.class]
                                                                                                    forKey:NSKeyedArchiveRootObjectKey];
                            if (error) {
                                ASDKLogError(@"Encountered an error while un/archiving data source form fields");
                            }
                            
                            sectionToBecomeVisible.formFields = @[formFieldToBeInserted];
                            
                            NSUInteger insertIndex = [visibleFormFields insertIndexInFormFieldCollectionForSectionIndex:originalSectionIndex
                                                                                                   refferenceCollection:self.renderableFormFields];
                            
                            [visibleFormFields insertObject:sectionToBecomeVisible
                                                    atIndex:insertIndex];
                            [insertSectionIndexSet addIndex:insertIndex];
                        } else {
                            ASDKModelFormField *originalFormFieldSection = self.renderableFormFields[originalSectionIndex];
                            NSInteger originalFormFieldIndex = [originalFormFieldSection.formFields indexOfFormField:formFieldToBeInserted];
                            NSUInteger insertIndex = 0;
                            NSUInteger insertSection = [visibleFormFields sectionForFormField:self.renderableFormFields[originalSectionIndex]];
                            
                            for (NSInteger fieldIndex = originalFormFieldIndex - 1; fieldIndex >= 0; fieldIndex--) {
                                ASDKModelFormField *currentFormField = originalFormFieldSection.formFields[fieldIndex];
                                if ([self.visibleFormFields isFormFieldVisible:currentFormField]) {
                                    insertSection = [visibleFormFields sectionForFormField:currentFormField];
                                    ASDKModelFormField *visibleFormFieldSection = visibleFormFields[insertSection];
                                    insertIndex = [visibleFormFieldSection.formFields indexOfFormField:currentFormField] + 1;
                                    break;
                                }
                            }
                            
                            ASDKModelFormField *sectionFormField = (ASDKModelFormField *)visibleFormFields[insertSection];
                            NSMutableArray *currentFormFields = [NSMutableArray arrayWithArray:sectionFormField.formFields];
                            [currentFormFields insertObject:formFieldToBeInserted
                                                    atIndex:insertIndex];
                            sectionFormField.formFields = currentFormFields;
                            [insertIndexPaths addObject:[NSIndexPath indexPathForItem:insertIndex
                                                                            inSection:insertSection]];
                        }
                    } else {
                        ASDKLogError(@"Cannot find original form field section index for form field:%@ that needs to become visibile in the renderable form field collection", formFieldToBeInserted.fieldName);
                    }
                }
            }
        }
        
        // Persist the mutated visible form fields version
        self.visibleFormFields = visibleFormFields;
    }
    
    [indexPathOperations setObject:insertSectionIndexSet
                            forKey:@(ASDKFormRenderEngineControllerOperationTypeInsertSection)];
    
    [indexPathOperations setObject:insertIndexPaths
                            forKey:@(ASDKFormRenderEngineControllerOperationTypeInsertRow)];
    
    return indexPathOperations;
}

- (NSDictionary *)removeVisibleFormFieldsFromCollection:(NSArray *)fieldsToBeRemoved {
    NSMutableIndexSet *deleteSectionIndexSet = [NSMutableIndexSet indexSet];
    NSMutableArray *deleteIndexPaths = [NSMutableArray array];
    NSMutableDictionary *indexPathOperations = [NSMutableDictionary dictionary];
    NSMutableArray *visibleFormFields = [NSMutableArray arrayWithArray:self.visibleFormFields];
    
    if (fieldsToBeRemoved) {
        for (ASDKModelAttributable *field in fieldsToBeRemoved) {
            BOOL isTabRemoval = [field isKindOfClass:ASDKModelFormTab.class] ? YES: NO;
            
            if (isTabRemoval) {
                NSUInteger tabIndexTodelete = [visibleFormFields sectionForTab:(ASDKModelFormTab *)field];
                if (NSNotFound != tabIndexTodelete) {
                    [deleteSectionIndexSet addIndex:tabIndexTodelete];
                }
            } else if (ASDKFormRenderEngineDataSourceViewModeFormFields == self.dataSourceViewMode) {
                ASDKModelFormField *formFieldToBeRemoved = (ASDKModelFormField *)field;
                BOOL isSectionRemoval = (ASDKModelFormFieldTypeContainer == formFieldToBeRemoved.fieldType);
                
                NSUInteger sectionIndexToDelete = [visibleFormFields sectionForFormField:formFieldToBeRemoved];
                
                // If the element to delete is present in the visible forms
                if (NSNotFound != sectionIndexToDelete) {
                    if (isSectionRemoval) {
                        [deleteSectionIndexSet addIndex:sectionIndexToDelete];
                    } else {
                        ASDKModelFormField *sectionFieldToRemoveFrom = visibleFormFields[sectionIndexToDelete];
                        NSMutableArray *sectionFormFieldsToRemoveFrom = [NSMutableArray arrayWithArray:sectionFieldToRemoveFrom.formFields];
                        NSUInteger itemIndexToDelete = [sectionFormFieldsToRemoveFrom indexOfFormField:formFieldToBeRemoved];
                        
                        // If there are no more form fields inside the section then remove the section altogether
                        if (!(sectionFormFieldsToRemoveFrom.count - 1)) {
                            [deleteSectionIndexSet addIndex:sectionIndexToDelete];
                        } else {
                            [deleteIndexPaths addObject:[NSIndexPath indexPathForItem:itemIndexToDelete
                                                                            inSection:sectionIndexToDelete]];
                        }
                    }
                }
            }
        }
        
        // Items will be removed after the indexes are computed to avoid
        // reporting of mutated indexes by multiple operations to the delegate
        [visibleFormFields removeObjectsAtIndexes:deleteSectionIndexSet];
        for (NSIndexPath *deleteIndexPath in deleteIndexPaths) {
            ASDKModelFormField *sectionFieldToRemoveFrom = visibleFormFields[deleteIndexPath.section];
            NSMutableArray *sectionFormFieldsToRemoveFrom = [NSMutableArray arrayWithArray:sectionFieldToRemoveFrom.formFields];
            [sectionFormFieldsToRemoveFrom removeObjectAtIndex:deleteIndexPath.row];
            sectionFieldToRemoveFrom.formFields = sectionFormFieldsToRemoveFrom;
        }
        
        [indexPathOperations setObject:deleteSectionIndexSet
                                forKey:@(ASDKFormRenderEngineControllerOperationTypeRemoveSection)];
        [indexPathOperations setObject:deleteIndexPaths
                                forKey:@(ASDKFormRenderEngineControllerOperationTypeRemoveRow)];
        
        // Persist the mutated visible form fields version
        self.visibleFormFields = visibleFormFields;
    }
    
    return indexPathOperations;
}


#pragma mark -
#pragma mark ASDKFormEngineDataSourceActionHandlerDelegate

- (BOOL)isSaveFormAvailable {
    return self.isSaveActionAvailable && !self.isReadOnlyForm;
}

@end
