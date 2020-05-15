/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile iOS App.
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

@class AFAGenericFilterModel,
ASDKModelApp;

typedef NS_ENUM(NSInteger, AFAFilterType) {
    AFAFilterTypeTask,
    AFAFilterTypeProcessInstance
};

@protocol AFAFilterViewControllerDelegate <NSObject>

- (void)searchWithFilterModel:(AFAGenericFilterModel *)filterModel;
- (void)filterModelsDidLoadWithDefaultFilter:(AFAGenericFilterModel *)filterModel
                                  filterType:(AFAFilterType)filterType
                            isCachedResponse:(BOOL)isCachedResponse
                                       error:(NSError *)error;
- (void)clearFilterInputText;

@end

@interface AFAFilterViewController : UIViewController

@property (strong, nonatomic) ASDKModelApp                        *currentApp;
@property (weak, nonatomic)   id<AFAFilterViewControllerDelegate> delegate;

- (void)loadTaskFilterList;
- (void)loadProcessInstanceFilterList;
- (CGSize)contentSizeForFilterView;
- (void)rollbackFilterValuesToFilter:(AFAGenericFilterModel *)filterModel;

@end
