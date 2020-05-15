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

#import "NSArray+ASDKFormRenderDataSourceArrayAddition.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormTab.h"
#import "ASDKModelAttributable.h"

@implementation NSArray (ASDKFormRenderDataSourceArrayAddition)

- (NSUInteger)sectionForFormField:(ASDKModelFormField *)formField {
    for (NSUInteger sectionCount = 0; sectionCount < self.count; sectionCount++) {
        ASDKModelFormField *sectionField = self[sectionCount];
        
        // Direct match
        if ([formField.modelID isEqualToString:sectionField.modelID]) {
            return sectionCount;
        }
        
        // Section match
        for (ASDKModelFormField *subSectionField in sectionField.formFields) {
            if ([formField.modelID isEqualToString:subSectionField.modelID]) {
                return sectionCount;
            }
        }
    }
    
    return NSNotFound;
}

- (NSUInteger)sectionForTab:(ASDKModelFormTab *)formTab {
    for (NSUInteger sectionCount = 0; sectionCount < self.count; sectionCount++) {
        ASDKModelFormField *sectionTab = self[sectionCount];
        
        if ([formTab.modelID isEqualToString:sectionTab.modelID]) {
            return sectionCount;
        }
    }
    
    return NSNotFound;
}

- (BOOL)doesCollectionContainFormField:(ASDKModelAttributable *)sectionFormField {
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"modelID == %@", sectionFormField.modelID];
    NSArray *results = [self filteredArrayUsingPredicate:searchPredicate];
    
    return results.count ? YES : NO;
}

- (NSUInteger)indexOfFormField:(ASDKModelAttributable *)formField {
    __block NSUInteger formFieldIdx = NSNotFound;
    
    [self enumerateObjectsUsingBlock:^(ASDKModelAttributable *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj.modelID isEqualToString:formField.modelID]) {
            formFieldIdx = idx;
            *stop = YES;
        }
    }];
    
    return formFieldIdx;
}

- (NSUInteger)insertIndexInFormFieldCollectionForSectionIndex:(NSUInteger)sectionIndex
                                         refferenceCollection:(NSArray *)refferenceCollection {
    NSUInteger insertIndex = 0;
    
    for (NSInteger sectionCount = sectionIndex - 1; sectionCount >= 0; sectionCount--) {
        ASDKModelAttributable *previousSectionField = (ASDKModelAttributable *)refferenceCollection[sectionCount];
        
        if ([self doesCollectionContainFormField:previousSectionField]) {
            insertIndex = [self indexOfFormField:previousSectionField] + 1;
            break;
        }
    }
    
    return insertIndex;
}

- (BOOL)isFormFieldVisible:(ASDKModelFormField *)formField {
    for (ASDKModelFormField *sectionField in self) {
        for (ASDKModelFormField *childField in sectionField.formFields) {
            if ([formField.modelID isEqualToString:childField.modelID]) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
