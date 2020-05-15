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

#import "NSDate+AFAStringTransformation.h"
#import "AFALocalizationConstants.h"
@import UIKit;

@implementation NSDate (AFAStringTransformation)


#pragma mark -
#pragma mark Public interface

- (NSString *)listCreationDate {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MMM dd, YYYY"];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)listEndedDate {
    return [self listCreationDate];
}

- (NSString *)processInstanceCreationDate {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setLocalizedDateFormatFromTemplate:@"MMMMddYYYY"];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dueDateFormattedString {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *fromDate = nil;
    NSDate *toDate = nil;
    
    [calendar rangeOfUnit:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMonth | NSCalendarUnitYear
                startDate:&fromDate
                 interval:NULL
                  forDate:self];
    [calendar rangeOfUnit:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMonth | NSCalendarUnitYear
                startDate:&toDate
                 interval:NULL forDate:[NSDate date]];
    
    NSDateComponents *taskDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMonth | NSCalendarUnitYear
                                                       fromDate:fromDate
                                                         toDate:toDate
                                                        options:0];
    NSInteger dayDiffNumber = taskDateComponents.day;
    NSInteger hourDiffNumber = taskDateComponents.hour;
    NSInteger monthDiffNumber = taskDateComponents.month;
    NSInteger yearDiffNumber = taskDateComponents.year;
    
    // Handle future dates
    if (!dayDiffNumber &&
        !monthDiffNumber &&
        !yearDiffNumber &&
        hourDiffNumber < 0) { // In a few hours
        return [NSString stringWithFormat:NSLocalizedString(kLocalizationTimeInFutureTextFormat, @"in x units format"),
                labs(hourDiffNumber) + 1,
                labs(hourDiffNumber) + 1 > 1 ? NSLocalizedString(kLocalizationTimeUnitHoursText, @"hours time unit") : NSLocalizedString(kLocalizationTimeUnitHourText, "hour time unit")];
    } else if (dayDiffNumber < 0 &&
               !monthDiffNumber &&
               !yearDiffNumber) { // In the next days
        return [NSString stringWithFormat:NSLocalizedString(kLocalizationTimeInFutureTextFormat, @"in x units format"),
                labs(dayDiffNumber) + 1,
                labs(dayDiffNumber) + 1 > 1 ? NSLocalizedString(kLocalizationTimeUnitDaysText, @"days time unit") : NSLocalizedString(kLocalizationTimeUnitDayText, @"day time unit")];
    } else if (monthDiffNumber < 0 &&
               !yearDiffNumber) { // In the next months
        return [NSString stringWithFormat:NSLocalizedString(kLocalizationTimeInFutureTextFormat, @"in x units format"),
                labs(monthDiffNumber) + (labs(dayDiffNumber) >= 14 ? 1 : 0),
                labs(monthDiffNumber) + (labs(dayDiffNumber) >= 14 ? 1 : 0) > 1 ? NSLocalizedString(kLocalizationTimeUnitMonthsText, @"months time unit") : NSLocalizedString(kLocalizationTimeUnitMonthText, @"month time unit")];
    } else if (yearDiffNumber < 0) { //In the next years
        return [NSString stringWithFormat:NSLocalizedString(kLocalizationTimeInFutureTextFormat, @"in x units format"),
                labs(yearDiffNumber) + (labs(monthDiffNumber) >= 6 ? 1 : 0),
                labs(yearDiffNumber) + (labs(monthDiffNumber) >= 6 ? 1 : 0) > 1 ? NSLocalizedString(kLocalizationTimeUnitYearsText, @"years time unit") : NSLocalizedString(kLocalizationTimeUnitYearText, @"year time unit")];
    }
    
    //Handle past dates
    if (!dayDiffNumber &&
        hourDiffNumber > 0) { // Few hours ago
        return [NSString stringWithFormat:NSLocalizedString(kLocalizationTimeInPastTextFormat, @"in x units format"),
                labs(hourDiffNumber),
                labs(hourDiffNumber) > 1 ? NSLocalizedString(kLocalizationTimeUnitHoursText, @"hours time unit") : NSLocalizedString(kLocalizationTimeUnitHourText, "hour time unit")];
    } else if (dayDiffNumber > 0 &&
               !monthDiffNumber &&
               !yearDiffNumber) { // Few days ago
        return [NSString stringWithFormat:NSLocalizedString(kLocalizationTimeInPastTextFormat, @"in x units format"),
                labs(dayDiffNumber),
                labs(dayDiffNumber) > 1 ? NSLocalizedString(kLocalizationTimeUnitDaysText, @"days time unit") : NSLocalizedString(kLocalizationTimeUnitDayText, @"day time unit")];
    } else if (monthDiffNumber > 0 &&
               !yearDiffNumber) { // Few months ago
        return [NSString stringWithFormat:NSLocalizedString(kLocalizationTimeInPastTextFormat, @"in x units format"),
                labs(monthDiffNumber),
                labs(monthDiffNumber) > 1 ? NSLocalizedString(kLocalizationTimeUnitMonthsText, @"months time unit") : NSLocalizedString(kLocalizationTimeUnitMonthText, @"month time unit")];
    } else if (yearDiffNumber > 0) { // Few years ago
        return [NSString stringWithFormat:NSLocalizedString(kLocalizationTimeInPastTextFormat, @"in x units format"),
                labs(yearDiffNumber),
                labs(yearDiffNumber) > 1 ? NSLocalizedString(kLocalizationTimeUnitYearsText, @"years time unit") : NSLocalizedString(kLocalizationTimeUnitYearText, @"year time unit")];
    }
    
    return nil;
}

- (NSAttributedString *)lastUpdatedFormattedString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, h:mm a"];
    NSString *title = [NSString stringWithFormat:NSLocalizedString(kLocalizationGeneralUseLastUpdateTextFormat, @"Last update format"), [dateFormatter stringFromDate:[NSDate date]]];
    
    UIColor *titleColor = [UIColor colorWithRed:42 / 255.0f green:41 / 255.0f blue:41 / 255.0f alpha:1.0f];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : titleColor}];
    
    return attributedTitle;
}

- (NSString *)commentFormattedString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    return [dateFormatter stringFromDate:self];
}

- (NSString *)durationStringUntilEndDate:(NSDate *)endDate {
    NSDateComponents *components = nil;
    NSInteger days,hour,minutes = 0;
    NSString *durationString = nil;
    
    components = [[NSCalendar currentCalendar] components: NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute
                                                 fromDate:self
                                                   toDate:endDate
                                                  options:0];
    days = [components day];
    hour=[components hour];
    minutes=[components minute];
    
    if(days > 0){
        durationString = (days > 1) ? [NSString stringWithFormat:@"%ld %@",(long)days, NSLocalizedString(kLocalizationTimeUnitDaysText, @"days time unit")] : [NSString stringWithFormat:@"%ld %@",(long)days, NSLocalizedString(kLocalizationTimeUnitDayText, @"day time unit")];
        return durationString;
    }
    
    if(hour > 0){
        durationString = (hour > 1) ? [NSString stringWithFormat:@"%ld :@",(long)hour, NSLocalizedString(kLocalizationTimeUnitHoursText, @"hours time unit")] : [NSString stringWithFormat:@"%ld %@",(long)hour, NSLocalizedString(kLocalizationTimeUnitHourText, "hour time unit")];
        
        return durationString;
    }
    
    if(minutes > 0){
        durationString = (minutes > 1) ? [NSString stringWithFormat:@"%ld %@",(long)minutes, NSLocalizedString(kLocalizationTimeUnitMinutesText, @"minutes time unit")] : [NSString stringWithFormat:@"%ld %@",(long)minutes, NSLocalizedString(kLocalizationTimeUnitMinuteText, @"minute time unit")];
        
        return durationString;
    }
    
    return @"";
}

+ (NSString *)durationTimeForInterval:(NSTimeInterval) interval {
    unsigned long milliseconds = interval;
    unsigned long seconds = milliseconds / 1000;
    unsigned long minutes = seconds / 60;
    seconds %= 60;
    unsigned long hours = minutes / 60;
    minutes %= 60;
    unsigned long days = hours / 24;
    hours %= 24;

    NSMutableString * result = [NSMutableString new];
    
    if (days) {
        [result appendFormat:@"%lu %@ ", days, days > 1 ? NSLocalizedString(kLocalizationTimeUnitDaysText, @"days time unit") : NSLocalizedString(kLocalizationTimeUnitDaysText, @"days time unit")];
    }
    
    if(hours) {
        [result appendFormat: @"%lu %@ ", hours, hours > 1 ? NSLocalizedString(kLocalizationTimeUnitHoursText, @"hours time unit") : NSLocalizedString(kLocalizationTimeUnitHourText, "hour time unit")];
    }
    
    if (minutes) {
        [result appendFormat: @"%2lu %@ ", minutes, minutes > 1 ? NSLocalizedString(kLocalizationTimeUnitMinutesText, @"minutes time unit") : NSLocalizedString(kLocalizationTimeUnitMinuteText, @"minute time unit")];
    }
    
    // If the time interval is very small display only the second count
    if (!result.length) {
        [result appendFormat:@"%lu %@", seconds, seconds > 1 ? NSLocalizedString(kLocalizationTimeUnitSecondsText, @"seconds time unit") : NSLocalizedString(kLocalizationTimeUnitSecondText, @"second time unit")];
    }
    
    return result;
}

@end
