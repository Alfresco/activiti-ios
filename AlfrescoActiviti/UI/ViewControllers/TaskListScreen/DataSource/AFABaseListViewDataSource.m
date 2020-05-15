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

#import "AFABaseListViewDataSource.h"
@import ActivitiSDK;

// Constants
#import "AFABusinessConstants.h"


@implementation AFABaseListViewDataSource


#pragma mark -
#pragma mark Public interface

- (instancetype)initWithDataEntries:(NSArray *)dataEntries
                         themeColor:(UIColor *)themeColor {
    // Override behaviour in subclasses
    self = [super init];
    return self;
}

- (NSArray *)processAdditionalEntries:(NSArray *)additionalEntriesArr
                   forExistingEntries:(NSArray *)existingEntriesArr
                               paging:(ASDKModelPaging *)paging {
    NSArray *entriesArr = nil;
    
    if (!paging.start) {
        if (!additionalEntriesArr.count) {
            return nil;
        } else {
            entriesArr = additionalEntriesArr;
        }
    } else if (existingEntriesArr.count) {
        // Make sure that the incoming data is not a subset of the existing collection
        NSArray *existingModelIDsArr = [existingEntriesArr valueForKeyPath:@"@distinctUnionOfObjects.modelID"];
        NSPredicate *uniqueEntitiesPredicate = [NSPredicate predicateWithFormat:@"NOT (modelID IN %@)", existingModelIDsArr];
        NSArray *serverEntriesArr = [additionalEntriesArr filteredArrayUsingPredicate:uniqueEntitiesPredicate];
        
        if (serverEntriesArr.count) {
            NSMutableArray *additionedEntries = [NSMutableArray arrayWithArray:existingEntriesArr];
            [additionedEntries addObjectsFromArray:serverEntriesArr];
            entriesArr = additionedEntries;
        } else {
            entriesArr = existingEntriesArr;
        }
    } else {
        entriesArr = additionalEntriesArr;
    }
    
    return entriesArr;
}

- (NSInteger)totalPagesForPaging:(ASDKModelPaging *)paging
                     dataEntries:(NSArray *)dataEntries {
    return ceilf((float) paging.total / dataEntries.count);
}
- (NSInteger)preloadCellIndexForPaging:(ASDKModelPaging *)paging
                           dataEntries:(NSArray *)dataEntries {
    // Compute the preload index that will trigger a new request
    if ([self totalPagesForPaging:paging
                      dataEntries:dataEntries] > 1) {
        return dataEntries.count - kTaskPreloadCellThreshold;
    } else {
        return 0;
    }
}

@end
