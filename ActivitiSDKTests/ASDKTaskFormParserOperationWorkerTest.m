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

#import "ASDKBaseTest.h"

@interface ASDKTaskFormParserOperationWorkerTest : ASDKBaseTest

@property (strong, nonatomic) ASDKTaskFormParserOperationWorker *taskFormParserWorker;

@end

@implementation ASDKTaskFormParserOperationWorkerTest

- (void)setUp {
    [super setUp];
    
    self.taskFormParserWorker = [ASDKTaskFormParserOperationWorker new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItReturnsAvailableServices {
    NSArray *availableServices = @[CREATE_STRING(ASDKTaskFormParserContentTypeFormModels),
                                   CREATE_STRING(ASDKTaskFormParserContentTypeRestFieldValues),
                                   CREATE_STRING(ASDKTaskFormParserContentTypeFormVariables)];
    XCTAssert([[self.taskFormParserWorker availableServices] isEqualToArray:availableServices]);
}

- (void)testThatItParsesSimpleUnpopulatedFormModels {
    // given
    NSDictionary *response = [self contentDictionaryFromJSON:@"TaskAllFieldsFormResponse"];
    XCTAssertNotNil(response);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.taskFormParserWorker
     parseContentDictionary:response
     ofType:CREATE_STRING(ASDKTaskFormParserContentTypeFormModels)
     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
         XCTAssertNil(error);
         XCTAssertNil(paging);
         XCTAssert([parsedObject isKindOfClass:[ASDKModelFormDescription class]]);
         
         ASDKModelFormDescription *formDescription = (ASDKModelFormDescription *)parsedObject;
         XCTAssert([formDescription.processDefinitionID isEqualToString:@"DisplayValueProcess:1:35004"]);
         XCTAssert([formDescription.processDefinitionKey isEqualToString:@"DisplayValueProcess"]);
         XCTAssert([formDescription.processDefinitionName isEqualToString:@"DisplayValueProcess"]);
         XCTAssert(!formDescription.formTabs.count);
         XCTAssert(!formDescription.formVariables.count);
         XCTAssert(!formDescription.formOutcomes.count);
         
         ASDKModelFormField *containerFormField = formDescription.formFields.firstObject;
         XCTAssert(containerFormField.fieldType == ASDKModelFormFieldTypeContainer);
         XCTAssert([containerFormField.modelID isEqualToString:@"1472729004123"]);
         XCTAssert(containerFormField.representationType == ASDKModelFormFieldRepresentationTypeContainer);
         XCTAssertNil(containerFormField.placeholder);
         XCTAssertNil(containerFormField.values);
         XCTAssertFalse(containerFormField.isReadOnly);
         XCTAssertFalse(containerFormField.isRequired);
         XCTAssert(containerFormField.sizeX == 2);
         XCTAssert(containerFormField.sizeY == 1);
         XCTAssertNil(containerFormField.formFieldOptions);
         XCTAssertNil(containerFormField.formFieldParams);
         XCTAssertNil(containerFormField.metadataValue);
         XCTAssertNil(containerFormField.tabID);
         XCTAssertNil(containerFormField.visibilityCondition);
         XCTAssert(containerFormField.formFields.count == 12);
         
         ASDKModelFormField *textFormField = (ASDKModelFormField *)containerFormField.formFields[0];
         XCTAssert(textFormField.fieldType == ASDKModelFormFieldTypeFormField);
         XCTAssert(textFormField.representationType == ASDKModelFormFieldRepresentationTypeText);
         XCTAssert([textFormField.fieldName isEqualToString:@"Text field"]);
         XCTAssert([textFormField.modelID isEqualToString:@"textfield"]);
         XCTAssertNil(textFormField.placeholder);
         XCTAssertNil(textFormField.values);
         XCTAssertFalse(textFormField.isReadOnly);
         XCTAssertFalse(textFormField.isRequired);
         XCTAssert(textFormField.sizeX == textFormField.sizeY == 1);
         XCTAssertNil(textFormField.formFields);
         XCTAssertNil(textFormField.formFieldOptions);
         XCTAssertNil(textFormField.metadataValue);
         XCTAssertNil(textFormField.visibilityCondition);
         XCTAssertNil(textFormField.tabID);
         
         ASDKModelFormField *multilineFormField = (ASDKModelFormField *)containerFormField.formFields[1];
         XCTAssert(multilineFormField.fieldType == ASDKModelFormFieldTypeFormField);
         XCTAssert(multilineFormField.representationType == ASDKModelFormFieldRepresentationTypeMultiline);
         XCTAssert([multilineFormField.fieldName isEqualToString:@"Multiline textfield"]);
         XCTAssert([multilineFormField.modelID isEqualToString:@"multilinetextfield"]);
         XCTAssertNil(multilineFormField.placeholder);
         XCTAssertNil(multilineFormField.values);
         XCTAssertFalse(multilineFormField.isReadOnly);
         XCTAssertFalse(multilineFormField.isRequired);
         XCTAssert(multilineFormField.sizeX == 1 &&
                   multilineFormField.sizeY == 2);
         XCTAssertNil(multilineFormField.formFields);
         XCTAssertNil(multilineFormField.formFieldOptions);
         XCTAssertNil(multilineFormField.metadataValue);
         XCTAssertNil(multilineFormField.visibilityCondition);
         XCTAssertNil(multilineFormField.tabID);
         
         ASDKModelFormField *numberFormField = (ASDKModelFormField *)containerFormField.formFields[2];
         XCTAssert(numberFormField.fieldType == ASDKModelFormFieldTypeFormField);
         XCTAssert(numberFormField.representationType == ASDKModelFormFieldRepresentationTypeNumerical);
         XCTAssert([numberFormField.fieldName isEqualToString:@"Number textfield"]);
         XCTAssert([numberFormField.modelID isEqualToString:@"numbertextfield"]);
         XCTAssertNil(numberFormField.placeholder);
         XCTAssertNil(numberFormField.values);
         XCTAssertFalse(numberFormField.isReadOnly);
         XCTAssertFalse(numberFormField.isRequired);
         XCTAssert(numberFormField.sizeX == numberFormField.sizeY == 1);
         XCTAssertNil(numberFormField.formFields);
         XCTAssertNil(numberFormField.formFieldOptions);
         XCTAssertNil(numberFormField.metadataValue);
         XCTAssertNil(numberFormField.visibilityCondition);
         XCTAssertNil(numberFormField.tabID);
         
         ASDKModelFormField *checkboxFormField = (ASDKModelFormField *)containerFormField.formFields[3];
         XCTAssert(checkboxFormField.fieldType == ASDKModelFormFieldTypeFormField);
         XCTAssert(checkboxFormField.representationType == ASDKModelFormFieldRepresentationTypeBoolean);
         XCTAssert([checkboxFormField.fieldName isEqualToString:@"Checkbox field"]);
         XCTAssert([checkboxFormField.modelID isEqualToString:@"checkboxfield"]);
         XCTAssertNil(checkboxFormField.placeholder);
         XCTAssertNil(checkboxFormField.values);
         XCTAssertFalse(checkboxFormField.isReadOnly);
         XCTAssertFalse(checkboxFormField.isRequired);
         XCTAssert(checkboxFormField.sizeX == checkboxFormField.sizeY == 1);
         XCTAssertNil(checkboxFormField.formFields);
         XCTAssertNil(checkboxFormField.formFieldOptions);
         XCTAssertNil(checkboxFormField.metadataValue);
         XCTAssertNil(checkboxFormField.visibilityCondition);
         XCTAssertNil(checkboxFormField.tabID);
         
         ASDKModelFormField *dateFormField = (ASDKModelFormField *)containerFormField.formFields[4];
         XCTAssert(dateFormField.fieldType == ASDKModelFormFieldTypeFormField);
         XCTAssert(dateFormField.representationType == ASDKModelFormFieldRepresentationTypeDate);
         XCTAssert([dateFormField.fieldName isEqualToString:@"Date formfield"]);
         XCTAssert([dateFormField.modelID isEqualToString:@"dateformfield"]);
         XCTAssertNil(dateFormField.placeholder);
         XCTAssertNil(dateFormField.values);
         XCTAssertFalse(dateFormField.isReadOnly);
         XCTAssertFalse(dateFormField.isRequired);
         XCTAssert(dateFormField.sizeX == dateFormField.sizeY == 1);
         XCTAssertNil(dateFormField.formFields);
         XCTAssertNil(dateFormField.formFieldOptions);
         XCTAssertNil(dateFormField.metadataValue);
         XCTAssertNil(dateFormField.visibilityCondition);
         XCTAssertNil(dateFormField.tabID);
         
         ASDKModelRestFormField *dropdownField = (ASDKModelRestFormField *)containerFormField.formFields[5];
         XCTAssert(dropdownField.fieldType == ASDKModelFormFieldTypeRestField);
         XCTAssert(dropdownField.representationType == ASDKModelFormFieldRepresentationTypeDropdown);
         XCTAssert([dropdownField.fieldName isEqualToString:@"Dropdown formfield"]);
         XCTAssert([dropdownField.modelID isEqualToString:@"dropdownformfield"]);
         XCTAssertNil(dropdownField.placeholder);
         XCTAssert([dropdownField.values.firstObject isEqualToString:@"Choose one..."]);
         XCTAssertFalse(dropdownField.isReadOnly);
         XCTAssertFalse(dropdownField.isRequired);
         XCTAssert(dropdownField.sizeX == dropdownField.sizeY == 1);
         XCTAssertNil(dropdownField.formFields);
         XCTAssert([dropdownField.formFieldOptions isKindOfClass:[NSArray class]]);
         XCTAssertNil(dropdownField.restURL);
         
         ASDKModelFormFieldOption *dropdownFormFieldOption = dropdownField.formFieldOptions.firstObject;
         XCTAssert([dropdownFormFieldOption.modelID isEqualToString:@"empty"]);
         XCTAssert([dropdownFormFieldOption.name isEqualToString:@"Choose one..."]);
         XCTAssertNil(dropdownField.metadataValue);
         XCTAssertNil(dropdownField.visibilityCondition);
         XCTAssertNil(dropdownField.tabID);
         
         ASDKModelAmountFormField *amountFormField = (ASDKModelAmountFormField *)containerFormField.formFields[6];
         XCTAssert(amountFormField.fieldType == ASDKModelFormFieldTypeAmountField);
         XCTAssert(amountFormField.representationType == ASDKModelFormFieldRepresentationTypeAmount);
         XCTAssert([amountFormField.fieldName isEqualToString:@"Amount formfield"]);
         XCTAssert([amountFormField.modelID isEqualToString:@"amountformfield"]);
         XCTAssertNil(amountFormField.placeholder);
         XCTAssertNil(amountFormField.values);
         XCTAssertFalse(amountFormField.isReadOnly);
         XCTAssertFalse(amountFormField.isRequired);
         XCTAssert(amountFormField.sizeX == amountFormField.sizeY == 1);
         XCTAssertNil(amountFormField.formFields);
         XCTAssertNil(amountFormField.formFieldOptions);
         XCTAssertNil(amountFormField.metadataValue);
         XCTAssertNil(amountFormField.visibilityCondition);
         XCTAssertNil(amountFormField.tabID);
         XCTAssertFalse(amountFormField.enableFractions);
         XCTAssertNil(amountFormField.currency);
         
         ASDKModelRestFormField *radioFormField = (ASDKModelRestFormField *)containerFormField.formFields[7];
         XCTAssert(radioFormField.fieldType == ASDKModelFormFieldTypeRestField);
         XCTAssert(radioFormField.representationType == ASDKModelFormFieldRepresentationTypeRadio);
         XCTAssert([radioFormField.fieldName isEqualToString:@"Radio formfield"]);
         XCTAssert([radioFormField.modelID isEqualToString:@"radioformfield"]);
         XCTAssertNil(radioFormField.placeholder);
         XCTAssert([radioFormField.values.firstObject isEqualToString:@"Option 1"]);
         XCTAssertFalse(radioFormField.isReadOnly);
         XCTAssertFalse(radioFormField.isRequired);
         XCTAssert(radioFormField.sizeX == radioFormField.sizeY == 1);
         XCTAssertNil(radioFormField.formFields);
         
         ASDKModelFormFieldOption *radioFormFieldOption = radioFormField.formFieldOptions.lastObject;
         XCTAssert([radioFormFieldOption.modelID isEqualToString:@"option_2"]);
         XCTAssert([radioFormFieldOption.name isEqualToString:@"Option 2"]);
         XCTAssertNil(radioFormField.metadataValue);
         XCTAssertNil(radioFormField.visibilityCondition);
         XCTAssertNil(radioFormField.tabID);
         XCTAssertNil(radioFormField.restURL);
         
         ASDKModelPeopleFormField *peopleFormField = (ASDKModelPeopleFormField *)containerFormField.formFields[8];
         XCTAssert(peopleFormField.fieldType == ASDKModelFormFieldTypeFormField);
         XCTAssert(peopleFormField.representationType == ASDKModelFormFieldRepresentationTypePeople);
         XCTAssert([peopleFormField.fieldName isEqualToString:@"People formfield"]);
         XCTAssert([peopleFormField.modelID isEqualToString:@"peopleformfield"]);
         XCTAssertNil(peopleFormField.placeholder);
         XCTAssertNil(peopleFormField.values);
         XCTAssertFalse(peopleFormField.isReadOnly);
         XCTAssertFalse(peopleFormField.isRequired);
         XCTAssert(peopleFormField.sizeX == peopleFormField.sizeY == 1);
         XCTAssertNil(peopleFormField.formFields);
         XCTAssertNil(peopleFormField.formFieldOptions);
         XCTAssertNil(peopleFormField.metadataValue);
         XCTAssertNil(peopleFormField.visibilityCondition);
         XCTAssertNil(peopleFormField.tabID);
         
         ASDKModelHyperlinkFormField *hyperlinkFormField = (ASDKModelHyperlinkFormField *)containerFormField.formFields[9];
         XCTAssert(hyperlinkFormField.fieldType == ASDKModelFormFieldTypeHyperlinkField);
         XCTAssert(hyperlinkFormField.representationType == ASDKModelFormFieldRepresentationTypeHyperlink);
         XCTAssert([hyperlinkFormField.fieldName isEqualToString:@"Hyperlink formfield"]);
         XCTAssert([hyperlinkFormField.modelID isEqualToString:@"hyperlinkformfield"]);
         XCTAssertNil(hyperlinkFormField.placeholder);
         XCTAssertNil(hyperlinkFormField.values);
         XCTAssertFalse(hyperlinkFormField.isReadOnly);
         XCTAssertFalse(hyperlinkFormField.isRequired);
         XCTAssert(hyperlinkFormField.sizeX == peopleFormField.sizeY == 1);
         XCTAssertNil(hyperlinkFormField.formFields);
         XCTAssertNil(hyperlinkFormField.formFieldOptions);
         XCTAssertNil(hyperlinkFormField.metadataValue);
         XCTAssertNil(hyperlinkFormField.visibilityCondition);
         XCTAssertNil(hyperlinkFormField.tabID);
         XCTAssert([hyperlinkFormField.hyperlinkURL isEqualToString:@"http://www.alfresco.com"]);
         XCTAssert([hyperlinkFormField.displayText isEqualToString:@"Alfresco website"]);
         
         ASDKModelFormField *attachFormField = (ASDKModelFormField *)containerFormField.formFields[10];
         XCTAssert(attachFormField.fieldType == ASDKModelFormFieldTypeAttachField);
         XCTAssert(attachFormField.representationType == ASDKModelFormFieldRepresentationTypeAttach);
         XCTAssert([attachFormField.fieldName isEqualToString:@"Attach formfield"]);
         XCTAssert([attachFormField.modelID isEqualToString:@"attachformfield"]);
         XCTAssertNil(attachFormField.placeholder);
         XCTAssertNil(attachFormField.values);
         XCTAssertFalse(attachFormField.isReadOnly);
         XCTAssertFalse(attachFormField.isRequired);
         XCTAssert(attachFormField.sizeX == attachFormField.sizeY == 1);
         XCTAssertNil(attachFormField.formFields);
         XCTAssertNil(attachFormField.formFieldOptions);
         XCTAssertNil(attachFormField.metadataValue);
         XCTAssertNil(attachFormField.visibilityCondition);
         XCTAssertNil(attachFormField.tabID);
         XCTAssert([attachFormField.formFieldParams isKindOfClass:[ASDKModelFormFieldAttachParameter class]]);
         
         ASDKModelFormFieldAttachParameter *attachParameter = (ASDKModelFormFieldAttachParameter *)attachFormField.formFieldParams;
         XCTAssertFalse(attachParameter.allowMultipleFiles);
         XCTAssertFalse(attachParameter.isLinkReference);
         XCTAssert([attachParameter.fileSource isKindOfClass:[ASDKModelFormFieldFileSource class]]);
         ASDKModelFormFieldFileSource *fileSource = (ASDKModelFormFieldFileSource *)attachParameter.fileSource;
         XCTAssert([fileSource.integrationServiceID isEqualToString:@"all-file-sources"]);
         XCTAssert([fileSource.name isEqualToString:@"All file sources"]);
         
         ASDKModelFormField *displayTextFormField = (ASDKModelFormField *)containerFormField.formFields[11];
         XCTAssert(displayTextFormField.fieldType == ASDKModelFormFieldTypeFormField);
         XCTAssert(displayTextFormField.representationType == ASDKModelFormFieldRepresentationTypeReadonlyText);
         XCTAssert([displayTextFormField.fieldName isEqualToString:@"Display text formfield"]);
         XCTAssert([displayTextFormField.modelID isEqualToString:@"displaytextformfield"]);
         XCTAssertNil(displayTextFormField.placeholder);
         XCTAssert([displayTextFormField.values.firstObject isEqualToString:@"Some display text goes here...."]);
         XCTAssertFalse(displayTextFormField.isReadOnly);
         XCTAssertFalse(displayTextFormField.isRequired);
         XCTAssert(displayTextFormField.sizeX == displayTextFormField.sizeY == 1);
         XCTAssertNil(displayTextFormField.formFields);
         XCTAssertNil(displayTextFormField.formFieldOptions);
         XCTAssertNil(displayTextFormField.metadataValue);
         XCTAssertNil(displayTextFormField.visibilityCondition);
         XCTAssertNil(displayTextFormField.tabID);
         
         [expectation fulfill];
     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesTabAndVisibilityConditionRulesOfFormModels {
    // given
    NSDictionary *response = [self contentDictionaryFromJSON:@"TaskTabsWithVisibilityConditionsFormResponse"];
    XCTAssertNotNil(response);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.taskFormParserWorker
     parseContentDictionary:response
     ofType:CREATE_STRING(ASDKTaskFormParserContentTypeFormModels)
     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
         XCTAssertNil(error);
         XCTAssertNil(paging);
         XCTAssert([parsedObject isKindOfClass:[ASDKModelFormDescription class]]);
         
         ASDKModelFormDescription *formDescription = (ASDKModelFormDescription *)parsedObject;
         XCTAssert([formDescription.processDefinitionID isEqualToString:@"TabProcess:7:30125"]);
         XCTAssert([formDescription.processDefinitionKey isEqualToString:@"TabProcess"]);
         XCTAssert([formDescription.processDefinitionName isEqualToString:@"TabProcess"]);
         XCTAssert(!formDescription.formVariables.count);
         XCTAssert(!formDescription.formOutcomes.count);
         XCTAssert(formDescription.formTabs.count == 3);
         
         ASDKModelFormTab *tabFormField = (ASDKModelFormTab *)formDescription.formTabs.lastObject;
         XCTAssert([tabFormField.modelID isEqualToString:@"tab3"]);
         XCTAssert([tabFormField.title isEqualToString:@"Third tab"]);
         
         ASDKModelFormVisibilityCondition *tabVisibilityCondition = (ASDKModelFormVisibilityCondition *)tabFormField.visibilityCondition;
         XCTAssertNil(tabVisibilityCondition.nextCondition);
         XCTAssert([tabVisibilityCondition.rightValue isEqualToString:@"Second"]);
         XCTAssert(!tabVisibilityCondition.rightFormFieldID.length);
         XCTAssert(!tabVisibilityCondition.rightRestResponseID.length);
         XCTAssert(tabVisibilityCondition.operationOperator == ASDKModelFormVisibilityConditionOperatorTypeEqual);
         XCTAssertNil(tabVisibilityCondition.leftRestResponseID);
         XCTAssert([tabVisibilityCondition.leftFormFieldID isEqualToString:@"radiooptions_LABEL"]);
         XCTAssert(tabVisibilityCondition.nextConditionOperator == ASDKModelFormVisibilityConditionNextConditionOperatorTypeUndefined);
         
         ASDKModelFormField *firstTabContainerFormField = formDescription.formFields[1];
         ASDKModelFormField *firstTabDisplayFormField = firstTabContainerFormField.formFields[1];
         XCTAssert([firstTabDisplayFormField.formFieldParams.modelID isEqualToString:@"globalStringVariable"]);
         XCTAssert([firstTabDisplayFormField.formFieldParams.fieldName isEqualToString:@"globalStringVariable"]);
         
         ASDKModelFormVisibilityCondition *displayFormFieldVisibilityCondition = [(ASDKModelFormField *)firstTabContainerFormField.formFields[1] visibilityCondition];
         XCTAssert(displayFormFieldVisibilityCondition.operationOperator == ASDKModelFormVisibilityConditionOperatorTypeNotEmpty);
         XCTAssert([displayFormFieldVisibilityCondition.leftFormFieldID isEqualToString:@"textfield"]);
         XCTAssert([[firstTabContainerFormField.formFields[0] tabID] isEqualToString:@"tab1"] &&
                   [[firstTabContainerFormField.formFields[1] tabID] isEqualToString:@"tab1"]);
         
         [expectation fulfill];
     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesDynamicTableFormFieldModel {
    // given
    NSDictionary *response = [self contentDictionaryFromJSON:@"TaskTabsWithVisibilityConditionsFormResponse"];
    XCTAssertNotNil(response);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.taskFormParserWorker
     parseContentDictionary:response
     ofType:CREATE_STRING(ASDKTaskFormParserContentTypeFormModels)
     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
         XCTAssertNil(error);
         XCTAssertNil(paging);
         XCTAssert([parsedObject isKindOfClass:[ASDKModelFormDescription class]]);
         
         ASDKModelDynamicTableFormField *dynamicTableFormField = [(ASDKModelFormDescription *)parsedObject formFields][2];
         XCTAssert([dynamicTableFormField.modelID isEqualToString:@"employeetable"]);
         XCTAssert(dynamicTableFormField.fieldType == ASDKModelFormFieldTypeDynamicTableField);
         XCTAssert(dynamicTableFormField.representationType == ASDKModelFormFieldRepresentationTypeDynamicTable);
         XCTAssert([dynamicTableFormField.fieldName isEqualToString:@"Employee table"]);
         XCTAssert([dynamicTableFormField.tabID isEqualToString:@"tab3"]);
         XCTAssert(dynamicTableFormField.columnDefinitions.count == 2);
         
         ASDKModelDynamicTableColumnDefinitionFormField *columnDefinition = (ASDKModelDynamicTableColumnDefinitionFormField *)dynamicTableFormField.columnDefinitions.firstObject;
         XCTAssert([columnDefinition.modelID isEqualToString:@"employeeName"]);
         XCTAssertTrue(columnDefinition.editable);
         XCTAssertTrue(columnDefinition.visible);
         XCTAssert([columnDefinition.fieldName isEqualToString:@"Employee name"]);
         XCTAssertTrue(columnDefinition.isRequired);
         
         ASDKModelDynamicTableColumnDefinitionAmountFormField *amountColumnDefinition = (ASDKModelDynamicTableColumnDefinitionAmountFormField *)dynamicTableFormField.columnDefinitions.lastObject;
         XCTAssert([amountColumnDefinition.modelID isEqualToString:@"employeeSalary"]);
         XCTAssertTrue(amountColumnDefinition.editable);
         XCTAssertTrue(amountColumnDefinition.visible);
         XCTAssertTrue(amountColumnDefinition.isRequired);
         XCTAssert([amountColumnDefinition.fieldName isEqualToString:@"Employee salary"]);
         XCTAssertTrue(amountColumnDefinition.enableFractions);
         XCTAssert([amountColumnDefinition.currency isEqualToString:@"RON"]);
         
         [expectation fulfill];
     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesTaskFormRestFieldValues {
    // given
    NSDictionary *response = [self contentDictionaryFromJSON:@"TaskFormRestFieldValuesResponse"];
    XCTAssertNotNil(response);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.taskFormParserWorker
     parseContentDictionary:response
     ofType:CREATE_STRING(ASDKTaskFormParserContentTypeRestFieldValues)
     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
         XCTAssertNil(error);
         XCTAssertNil(paging);
         XCTAssert([parsedObject isKindOfClass:[NSArray class]]);
         XCTAssert(((NSArray *)parsedObject).count == 10);
         
         ASDKModelFormFieldOption *formFieldOption = [(NSArray *)parsedObject firstObject];
         XCTAssert([formFieldOption.modelID isEqualToString:@"1"]);
         XCTAssert([formFieldOption.name isEqualToString:@"Leanne Graham"]);
         
         [expectation fulfill];
     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItParsesFormVariable {
    // given
    NSDictionary *response = [self contentDictionaryFromJSON:@"TaskFormWithVariableResponse"];
    XCTAssertNotNil(response);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    [self.taskFormParserWorker
     parseContentDictionary:response
     ofType:CREATE_STRING(ASDKTaskFormParserContentTypeFormModels)
     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
         XCTAssertNil(error);
         XCTAssertNil(paging);
         XCTAssert([parsedObject isKindOfClass:[ASDKModelFormDescription class]]);
         
         ASDKModelFormDescription *formDescription = (ASDKModelFormDescription *)parsedObject;
         ASDKModelFormVariable *formVariable = (ASDKModelFormVariable *)formDescription.formVariables.firstObject;
         XCTAssert([formVariable.name isEqualToString:@"testVar"]);
         XCTAssert(formVariable.type == ASDKModelFormVariableTypePeople);
         XCTAssert([formVariable.value isEqualToString:@"John Doe"]);
         
         [expectation fulfill];
     } queue:dispatch_get_main_queue()];
    
    // then
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesInvalidJSONData {
    XCTestExpectation *formFieldModelListExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.formFieldModelList", NSStringFromSelector(_cmd)]];
    XCTestExpectation *formFieldRestValuesExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.formFieldRestValues", NSStringFromSelector(_cmd)]];
    
    // when
    NSDictionary *invalidContentDictionary = @{@"foo":@"bar"};
    [self.taskFormParserWorker parseContentDictionary:invalidContentDictionary
                                               ofType:CREATE_STRING(ASDKTaskFormParserContentTypeFormModels)
                                  withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                      XCTAssertNotNil(error);
                                      XCTAssertNil(parsedObject);
                                      XCTAssertNil(paging);
                                      
                                      [formFieldModelListExpectation fulfill];
                                  } queue:dispatch_get_main_queue()];
    [self.taskFormParserWorker parseContentDictionary:invalidContentDictionary
                                               ofType:CREATE_STRING(ASDKTaskFormParserContentTypeRestFieldValues)
                                  withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                                      XCTAssertNotNil(error);
                                      XCTAssertNil(parsedObject);
                                      XCTAssertNil(paging);
                                      
                                      [formFieldRestValuesExpectation fulfill];
                                  } queue:dispatch_get_main_queue()];
    
    [self waitForExpectationsWithTimeout:.5
                                 handler:nil];
}

@end
