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

#import "ASDKFormDateFieldCollectionViewCell.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKModelConfiguration.h"
#import "ASDKLocalizationConstants.h"

// Models
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelDateFormField.h"

@interface ASDKFormDateFieldCollectionViewCell ()

@property (strong, nonatomic) ASDKModelDateFormField        *currentFormField;
@property (assign, nonatomic) BOOL                          isRequired;

@end

@implementation ASDKFormDateFieldCollectionViewCell

- (void)setSelected:(BOOL)selected {
    if (ASDKModelFormFieldRepresentationTypeReadOnly != self.currentFormField.representationType) {
        [UIView animateWithDuration:kASDKSetSelectedAnimationTime animations:^{
            self.backgroundColor = selected ? self.colorSchemeManager.formViewHighlightedCellBackgroundColor : [UIColor whiteColor];
        }];
    }
}


#pragma mark -
#pragma mark ASDKFormCellProtocol

- (void)setupCellWithFormField:(ASDKModelFormField *)formField {
    self.currentFormField = (ASDKModelDateFormField *)formField;
    self.descriptionLabel.text = formField.fieldName;
    
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType) {
        NSString *formFieldValue = [self formattedDateStringForDateStringValue:formField.values.firstObject];
        self.selectedDateLabel.text = formFieldValue ? formFieldValue : ASDKLocalizedStringFromTable(kLocalizationFormValueEmpty, ASDKLocalizationTable, @"Empty value text");
        self.selectedDateLabel.textColor = self.colorSchemeManager.formViewFilledInValueColor;
        self.disclosureIndicatorLabel.hidden = YES;
        self.trailingToDisclosureConstraint.priority = UILayoutPriorityFittingSizeLevel;
    } else {
        self.isRequired = formField.isRequired;

        // If a previously selected option is available display it
        if (formField.metadataValue) {
            self.selectedDateLabel.text = formField.metadataValue.attachedValue;
        } else  {
            self.selectedDateLabel.text = [self formattedDateStringForDateStringValue:formField.values.firstObject];
        }
        self.disclosureIndicatorLabel.hidden = NO;
        
        [self validateCellStateForText:self.selectedDateLabel.text];
    }
}

- (NSString *)formattedDateStringForDateStringValue:(NSString *)dateValue {
    NSString *labelText = nil;
    
    if (dateValue.length) {
        //format date in saved form (2016-02-23T23:00:Z)
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        dateFormatter.dateFormat = kASDKServerLongDateFormat;
        NSDate *storedDate = [dateFormatter dateFromString:dateValue];
        
        // try other date formatter
        if (!storedDate) {
            //format date in saved form (2016-02-23T23:00:000Z)
            dateFormatter.dateFormat = kASDKServerFullDateFormat;
            storedDate = [dateFormatter dateFromString:dateValue];
        }
        
        if (!storedDate) {
            dateFormatter.dateFormat = kBaseModelDateFormat;
            storedDate = [dateFormatter dateFromString:dateValue];
        }
        
        // Select the appropiate display date formatter
        NSDateFormatter *displayDateFormatter = [[NSDateFormatter alloc] init];
        displayDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        if (self.currentFormField.dateDisplayFormat.length) {
            displayDateFormatter.dateFormat = self.currentFormField.dateDisplayFormat;
        } else {
            if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) {
                if (ASDKModelFormFieldRepresentationTypeDateTime == self.currentFormField.formFieldParams.representationType) {
                    displayDateFormatter.dateFormat = kASDKServerMediumDateFormat;
                } else {
                    displayDateFormatter.dateFormat = kASDKServerShortDateFormat;
                }
            } else {
                if (ASDKModelFormFieldRepresentationTypeDateTime == self.currentFormField.representationType) {
                    displayDateFormatter.dateFormat = kASDKServerMediumDateFormat;
                } else {
                    displayDateFormatter.dateFormat = kASDKServerShortDateFormat;
                }
            }
        }
        labelText = [displayDateFormatter stringFromDate:storedDate];
    }
    
    return labelText;
}


#pragma mark -
#pragma mark Cell states & validation

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.descriptionLabel.text = nil;
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
    self.selectedDateLabel.text = nil;
}

- (void)markCellValueAsInvalid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewInvalidValueColor;
}

- (void)markCellValueAsValid {
    self.descriptionLabel.textColor = self.colorSchemeManager.formViewValidValueColor;
}

- (void)cleanInvalidCellValue {
    self.selectedDateLabel.text = nil;
}

- (void)validateCellStateForText:(NSString *)text {
    // Check input in relation to the requirement of the field
    if (self.isRequired) {
        if (!text.length) {
            [self markCellValueAsInvalid];
        } else {
            [self markCellValueAsValid];
        }
    }
}

@end
