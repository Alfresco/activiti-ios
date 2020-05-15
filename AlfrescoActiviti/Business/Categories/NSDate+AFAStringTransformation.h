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

#import <Foundation/Foundation.h>

@interface NSDate (AFAStringTransformation)

/**
 *  Returns the current date object formatted as a list creation date
 *
 *  @return Formatted string
 */
- (NSString *)listCreationDate;

/**
 *  Return the current date object formatted as a list end date
 *
 *  @return Formatted string
 */
- (NSString *)listEndedDate;

/**
 *  Return the current date object formatted as a process instance creation date
 *
 *  @return Formatted string
 */
- (NSString *)processInstanceCreationDate;

/**
 *  Returns the current date object formatted as a task list due date
 *
 *  @return Formatted string
 */
- (NSString *)dueDateFormattedString;

/**
 *  Returns the current date object formatted as a "Last update:" string
 *
 *  @return Formatted string
 */
- (NSAttributedString *)lastUpdatedFormattedString;

/**
 *  Returns the date object formatted as a comment creation date
 *
 *  @return Formatted string
 */
- (NSString *)commentFormattedString;

/**
 *  Returns a string containing the duration between the current reffererenced
 *  NSDate object and the provided end date parameter
 *
 *  @param endDate The end date for which the interval is computed
 *
 *  @return String containing the time duration between the two dates
 */
- (NSString *)durationStringUntilEndDate:(NSDate *)endDate;

/**
 *  Returns a string containing the transformation from a time interval expressed
 *  in miliseconds
 *
 *  @param interval The time interval for which the transformation is performed
 *
 *  @return String containing the time duration expressed in days, hours, minutes,
 *          seconds
 */
+ (NSString *)durationTimeForInterval:(NSTimeInterval)interval;

@end
