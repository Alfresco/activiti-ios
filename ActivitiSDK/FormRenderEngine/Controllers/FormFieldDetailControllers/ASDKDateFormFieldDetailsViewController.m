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

#import "ASDKDateFormFieldDetailsViewController.h"

typedef NS_ENUM(NSInteger, ASDKDatePickerComponentType) {
    ASDKDatePickerComponentTypeUndefined = -1,
    ASDKDatePickerComponentTypeDate = 0,
    ASDKDatePickerComponentTypeDateTime
};

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLocalizationConstants.h"
#import "ASDKModelConfiguration.h"

// Models
#import "ASDKModelDateFormField.h"
#import "ASDKModelFormFieldOption.h"
#import "ASDKModelFormFieldValue.h"

@interface ASDKDateFormFieldDetailsViewController ()

@property (strong, nonatomic) ASDKModelDateFormField    *currentFormField;
@property (weak, nonatomic) IBOutlet UILabel            *selectedDate;
@property (weak, nonatomic) IBOutlet UIDatePicker       *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker       *timePicker;
@property (weak, nonatomic) IBOutlet UIToolbar          *segmentedControlToolbar;

- (IBAction)datePickerAction:(id)sender;

@end


@implementation ASDKDateFormFieldDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Update the navigation bar title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.currentFormField.fieldName;
    titleLabel.font = [UIFont fontWithName:@"Avenir-Book"
                                      size:17];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    // Show or hide the time picker component
    BOOL displayTimePicker = (ASDKModelFormFieldRepresentationTypeDateTime == self.currentFormField.representationType ||
                              ASDKModelFormFieldRepresentationTypeDateTime == self.currentFormField.formFieldParams.representationType) ? YES : NO;
    if (displayTimePicker) {
        self.segmentedControlToolbar.hidden = NO;
    }
    
    // Enable or disable user interaction
    BOOL isUserInteractionEnabled = (self.currentFormField.isReadOnly ||
                                     ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) ? NO : YES;
    self.datePicker.userInteractionEnabled = isUserInteractionEnabled;
    self.timePicker.userInteractionEnabled = isUserInteractionEnabled;
    
    // Adjust date picker time zones if values read through a display form field
    if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) {
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        self.datePicker.timeZone = timeZone;
        self.timePicker.timeZone = timeZone;
    } else {
        NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
        self.datePicker.timeZone = timeZone;
        self.timePicker.timeZone = timeZone;
    }
    
    // Set min and max values for date picker components if applicable
    if (self.currentFormField.minValue.length) {
        NSDate *minimumDate = [self dateFromString:self.currentFormField.minValue];
        
        self.datePicker.minimumDate = minimumDate;
        if (displayTimePicker) {
            self.timePicker.minimumDate = minimumDate;
        }
    }
    
    if (self.currentFormField.maxValue.length) {
        NSDate *maximumDate = [self dateFromString:self.currentFormField.maxValue];
        
        self.datePicker.maximumDate = maximumDate;
        if (displayTimePicker) {
            self.timePicker.maximumDate = maximumDate;
        }
    }
    
    [self updateRightBarButtonState];
    
    // Setup label and date picker
    if (self.currentFormField.metadataValue) {
        self.selectedDate.text = self.currentFormField.metadataValue.attachedValue;
        NSDate *storedDate = [self dateFromString:self.currentFormField.metadataValue.attachedValue];
        if (storedDate) {
            [self.datePicker setDate:storedDate];
            [self.timePicker setDate:storedDate];
        }
    } else if (self.currentFormField.values){
        //format date in saved form (2016-02-23T23:00:Z)
        NSDate *storedDate = [self dateFromString:self.currentFormField.values.firstObject];
        if (storedDate) {
            [self.datePicker setDate:storedDate];
            [self.timePicker setDate:storedDate];
        }
        self.selectedDate.text = [self stringFromDate:storedDate];
    } else {
        self.selectedDate.text = ASDKLocalizedStringFromTable(kLocalizationFormDateComponentPickDateLabelText, ASDKLocalizationTable, @"Pick a date");
    }
}

- (void)updateRightBarButtonState {
    if (self.currentFormField.isReadOnly ||
        ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) {
        return;
    }
    
    UIBarButtonItem *rightBarButtonItem = nil;
    if (self.currentFormField.metadataValue) {
        rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASDKLocalizedStringFromTable(kLocalizationFormOptionClearText, ASDKLocalizationTable, @"Clear text")
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(onCleanCurrentDateOption)];
    } else {
        rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ASDKLocalizedStringFromTable(kLocalizationFormDateComponentPickTodayText, ASDKLocalizationTable, @"Pick today text")
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(onPickTodayDateOption)];
    }
    
    rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}


#pragma mark -
#pragma mark ASDKFormFieldDetailsControllerProtocol

- (void)setupWithFormFieldModel:(ASDKModelFormField *)formFieldModel {
    self.currentFormField = (ASDKModelDateFormField *)formFieldModel;
}


#pragma mark - 
#pragma mark Actions

- (void)reportDateForCurrentFormField:(NSDate *)date {
    if (!date) {
        self.selectedDate.text = ASDKLocalizedStringFromTable(kLocalizationFormDateComponentPickDateLabelText, ASDKLocalizationTable, @"Pick a date");
        self.currentFormField.metadataValue = nil;
    } else {
        NSString *formatedDate = [self stringFromDate:date];
        self.selectedDate.text = formatedDate;
        
        // Propagate the change after the state of the checkbox has changed
        ASDKModelFormFieldValue *formFieldValue = [ASDKModelFormFieldValue new];
        formFieldValue.attachedValue = formatedDate;
        
        self.currentFormField.metadataValue = formFieldValue;
    }
    
    [self updateRightBarButtonState];
    
    // Notify the value transaction delegate there has been a change with the provided form field model
    if ([self.valueTransactionDelegate respondsToSelector:@selector(updatedMetadataValueForFormField:inCell:)]) {
        [self.valueTransactionDelegate updatedMetadataValueForFormField:self.currentFormField
                                                                 inCell:nil];
    }
}

- (IBAction)datePickerAction:(id)sender {
    NSDate *pickedDate = nil;
    
    if (self.currentFormField.dateDisplayFormat.length ||
        ASDKModelFormFieldRepresentationTypeDateTime == self.currentFormField.representationType) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear)
                                                       fromDate:self.datePicker.date];
        NSDateComponents *timeComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute)
                                                       fromDate:self.timePicker.date];
        [dateComponents setHour:timeComponents.hour];
        [dateComponents setMinute:timeComponents.minute];
        
        pickedDate = [calendar dateFromComponents:dateComponents];
    } else {
        pickedDate = self.datePicker.date;
    }
    
    self.datePicker.date = pickedDate;
    self.timePicker.date = pickedDate;
    
    [self reportDateForCurrentFormField:pickedDate];
}

- (void)onPickTodayDateOption {
    NSDate *today = [NSDate date];
    [self reportDateForCurrentFormField:today];
    [self.datePicker setDate:today
                    animated:YES];
    [self.timePicker setDate:today
                    animated:YES];
}

- (void)onCleanCurrentDateOption {
    [self reportDateForCurrentFormField:nil];
}

- (IBAction)didChangedTimeComponent:(UISegmentedControl *)sender {
    if (ASDKDatePickerComponentTypeDate == sender.selectedSegmentIndex) {
        [self showTimePickerComponent:NO];
    } else if (ASDKDatePickerComponentTypeDateTime == sender.selectedSegmentIndex) {
        [self showTimePickerComponent:YES];
    }
}


#pragma mark -
#pragma mark Private interface

- (NSString *)stringFromDate:(NSDate *)date {
    NSString *dateFormat = nil;
    
    if (self.currentFormField.dateDisplayFormat.length) {
        dateFormat = self.currentFormField.dateDisplayFormat;
    } else {
        if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) {
            if (ASDKModelFormFieldRepresentationTypeDateTime == self.currentFormField.formFieldParams.representationType) {
                dateFormat = kASDKServerMediumDateFormat;
            } else {
                dateFormat = kASDKServerShortDateFormat;
            }
        } else {
            if (ASDKModelFormFieldRepresentationTypeDateTime == self.currentFormField.representationType) {
                dateFormat = kASDKServerMediumDateFormat;
            } else {
                dateFormat = kASDKServerShortDateFormat;
            }
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) {
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    } else {
        dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    }
    dateFormatter.dateFormat = dateFormat;
    NSString *formatedDate = [dateFormatter stringFromDate:date];
    
    return formatedDate;
}

- (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) {
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    } else {
        dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    }
    
    if (self.currentFormField.dateDisplayFormat.length) {
        dateFormatter.dateFormat = self.currentFormField.dateDisplayFormat;
    }
    
    NSDate *storedDate = [dateFormatter dateFromString:dateString];
    
    if (!storedDate) {
        dateFormatter.dateFormat = kASDKServerFullDateFormat;
        storedDate = [dateFormatter dateFromString:dateString];
    }
    
    if (!storedDate) {
        dateFormatter.dateFormat = kASDKServerLongDateFormat;
        storedDate = [dateFormatter dateFromString:dateString];
    }
    
    if (!storedDate) {
        dateFormatter.dateFormat = kASDKServerMediumDateFormat;
        storedDate = [dateFormatter dateFromString:dateString];
    }
    
    if (!storedDate) {
        dateFormatter.dateFormat = kASDKServerShortDateFormat;
        storedDate = [dateFormatter dateFromString:dateString];
    }
    
    if (!storedDate) {
        dateFormatter.dateFormat = kBaseModelDateFormat;
        storedDate = [dateFormatter dateFromString:dateString];
    }
    
    return storedDate;
}

- (void)showTimePickerComponent:(BOOL)showTimePicker {
    if (showTimePicker) {
        self.datePicker.hidden = YES;
        self.timePicker.hidden = NO;
    } else {
        self.timePicker.hidden = YES;
        self.datePicker.hidden = NO;
    }
}

@end
