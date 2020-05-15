/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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

#import <UIKit/UIKit.h>
#import "ASDKFormRenderEngineDataSourceDelegate.h"
#import "ASDKFormFieldDetailsControllerProtocol.h"

@class ASDKModelFormDescription,
ASDKModelFormTabDescription,
ASDKModelAttributable,
ASDKModelFormField,
ASDKFormVisibilityConditionsProcessor;

typedef NS_ENUM(NSInteger, ASDKFormRenderEngineDataSourceViewMode) {
    ASDKFormRenderEngineDataSourceViewModeTabs,
    ASDKFormRenderEngineDataSourceViewModeFormFields
};

@protocol ASDKFormRenderEngineDataSourceProtocol <NSObject>

/**
 *  Property meant to indicate what data source mode is currently on i.e. showing
 *  information about tabs or form fields
 */
@property (assign, nonatomic, readonly) ASDKFormRenderEngineDataSourceViewMode dataSourceViewMode;

/**
 *  Property meant to hold a reference to renderable but not necessarly visible
 *  form fields, organized per tabs (if they exist) / form sections and stripped 
 *  of container-like objects that don't have a visual representation. This property 
 *  is intended to act as a reference point when visibility conditions affect a subset 
 *  of form fields and some get removed or inserted. We fallback to this property
 *  when we want to find out what was removed, from where, and what's should be
 *  inserted and where.
 */
@property (strong, nonatomic) NSArray *renderableFormFields;

/**
 *  Property meant to hold a reference to visible form field objects
 *  organized per section and strip from the collection container-like
 *  objects that don't have a visual representation, or objects that
 *  after the visibility condition processing shouldn't be visible anymore
 *
 */
@property (strong, nonatomic) NSArray *visibleFormFields;

/**
 *  Property meant to indicate whether the form is read only or not. Setting
 *  this property to true  will disable the outcome buttons. Form fields will
 *  be taken care of by interpreting the server representation.
 */
@property (assign, nonatomic) BOOL isReadOnlyForm;

/**
 *  Property meant to indicate whether the form has user defined outcomes.
 *  This is used when no user defined outcomes are defined yet the form
 *  still has to display a default outcome that will allow the user to
 *  end it.
 */
@property (assign, nonatomic) BOOL formHasUserdefinedOutcomes;

/**
 *  Property meant to hold a reference to the form title.
 *
 *  @return String object containing the form title or nil if a title is not defined.
 */
@property (strong, nonatomic) NSString *formTitle;

/**
 *  Returns the number of sections available for the current form description.
 *
 *  @return Integer value with number of sections
 */
- (NSInteger)numberOfSectionsForCurrentFormDescription;

/**
 *  Returns the number of form fields available in the current form description
 *  for a given section.
 *
 *  @param section The section for which the number of form fields is required
 *
 *  @return        Integer value with the number of form fields
 */
- (NSInteger)numberOfFormFieldsForSection:(NSInteger)section;

/**
 *  Returns the cell identifier used to dequeue the appropiate cell by the
 *  collection view controller for a provided index path.
 *
 *  @param indexPath Index path for which the cell identifier needs to be provided
 *
 *  @return          String containing the cell identifier value
 */
- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath;

/**
 *  Method returns an array of index paths corresponding to the form outcomes indexes
 *  This is useful when a refresh in needed but just for the form outcome section.
 *
 *  @return Array containing NSIndesPath obects corresponding to the form outcome cells
 */
- (NSArray *)indexPathsOfFormOutcomes;

/**
 *  Method returns the associated model object for the provided index path whether 
 *  it's a form field model object or a form outcome model object.
 *
 *  @param indexPath Index path for which the model needs to be returned
 *
 *  @return          Model object associated with the passed index path
 */
- (ASDKModelAttributable *)modelForIndexPath:(NSIndexPath *)indexPath;

/**
 *  Method returns the section header title string for the provided index path if
 *  that exists.
 *
 *  @param indexPath Index path for which the section header title is requested
 *
 *  @return String object containing the header title value or nil if there is no
 *          available entry
 */
- (NSString *)sectionHeaderTitleForIndexPath:(NSIndexPath *)indexPath;

/**
 *  Method returns whether or not form field metadata information is present or not
 *  on required form field objects.
 *
 *  @return YES if metadata is present on all required fields and NO, otherwise
 */
- (BOOL)areFormFieldMetadataValuesValid;

/**
 *  This method checks whether there is a view controller class associated with a
 *  particular form field and returns an initialized instance for that particular 
 *  type of form field. 
 *  Discussion: That UIViewController instance represents the child contex of that 
 *  form field and should be presented as a detail view.
 *
 *  @param formField Form field object for which the associated controller check is
 *                   performed
 *
 *  @return UIViewController initialized instance to be presented
 */
- (UIViewController<ASDKFormFieldDetailsControllerProtocol> *)childControllerForFormField:(ASDKModelFormField *)formField;

/**
 *  Method returns a form description tailored for the tab at the requested index path.
 *
 *  @param indexpath Index path of the tab for which the form description is requested
 *
 *  @return Form tab description object
 */
- (ASDKModelFormTabDescription *)formDescriptionForTabAtIndexPath:(NSIndexPath *)indexpath;

@end
