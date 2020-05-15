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

#import "AFABaseModel.h"
#import <objc/runtime.h>

@implementation AFABaseModel


#pragma mark -
#pragma mark Object description

- (NSString *)description {
    NSMutableString *propertyDescriptions = [NSMutableString string];
    for (NSString *key in [self describablePropertyNames]) {
        id value = [self valueForKey:key];
        [propertyDescriptions appendFormat:@"; %@ = %@", key, value];
    }
    return [NSString stringWithFormat:@"<%@: 0x%lx%@>", [self class], (unsigned long)self, propertyDescriptions];
}

- (NSArray *)describablePropertyNames {
    // Loop through our superclasses until we hit NSObject
    NSMutableArray *array = [NSMutableArray array];
    Class subclass = [self class];
    while (subclass != [NSObject class]) {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(subclass,&propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            // Add property name to array
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            [array addObject:@(propertyName)];
        }
        free(properties);
        properties = nil;
        subclass = [subclass superclass];
    }
    
    // Return array of property names
    return array;
}

@end
