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

#import "ASDKDynamicTableColumnTableViewCell.h"

// Constants
#import "ASDKModelConfiguration.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelDynamicTableFormField.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelDynamicTableColumnDefinitionAmountFormField.h"

@implementation ASDKDynamicTableColumnTableViewCell

- (void)setupCellWithColumnDefinitionFormField:(ASDKModelFormField *)columnDefinitionformField
                         dynamicTableFormField:(ASDKModelDynamicTableFormField *)dynamicTableFormField {
    NSInteger representationType = ASDKModelFormFieldRepresentationTypeUndefined;
    self.columnNameLabel.text = columnDefinitionformField.fieldName;
    
    ASDKBootstrap *sdkBootStrap = [ASDKBootstrap sharedInstance];
    ASDKFormColorSchemeManager *colorSchemeManager = [sdkBootStrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKFormColorSchemeManagerProtocol)];
    
    // If dealing with read-only forms extract the representation type from the attached
    // form field params model
    if (ASDKModelFormFieldRepresentationTypeReadOnly == columnDefinitionformField.representationType &&
        !dynamicTableFormField.isTableEditable) {
        representationType = columnDefinitionformField.formFieldParams.representationType;
        // set 'disabled color' for complete forms
        self.columnValueLabel.textColor = colorSchemeManager.formViewFilledInValueColor;
    } else if (ASDKModelFormFieldRepresentationTypeReadOnly == columnDefinitionformField.representationType &&
               dynamicTableFormField.isTableEditable) {
        representationType = columnDefinitionformField.formFieldParams.representationType;
    } else {
        representationType = columnDefinitionformField.representationType;
    }
    
    switch (representationType) {
        case ASDKModelFormFieldRepresentationTypeBoolean: {
            BOOL formFieldValue;
            if (columnDefinitionformField.metadataValue) {
                formFieldValue = columnDefinitionformField.metadataValue.attachedValue ? YES: NO;
            } else {
                formFieldValue = columnDefinitionformField.values.firstObject ? YES : NO;
            }
            self.columnValueLabel.text = formFieldValue ? @"Yes" : @"No";
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeAmount: {
            ASDKModelDynamicTableColumnDefinitionAmountFormField *amountColumnDefinitionFormField = (ASDKModelDynamicTableColumnDefinitionAmountFormField *) columnDefinitionformField;
            NSString *currencySymbol = amountColumnDefinitionFormField.currency.length ? amountColumnDefinitionFormField.currency : @"$";
            NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", amountColumnDefinitionFormField.fieldName, currencySymbol]];
            [labelText addAttribute:NSForegroundColorAttributeName
                              value:colorSchemeManager.formViewAmountFieldSymbolColor
                              range:NSMakeRange((labelText.length) - 3,3)];
            self.columnNameLabel.attributedText = labelText;
            
            if (columnDefinitionformField.metadataValue) {
                self.columnValueLabel.text = columnDefinitionformField.metadataValue.attachedValue;
            } else if (columnDefinitionformField.values) {
                self.columnValueLabel.text = [NSString stringWithFormat:@"%@", amountColumnDefinitionFormField.values.firstObject];
            } else {
                self.columnValueLabel.text = @"";
            }
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeDropdown:
        case ASDKModelFormFieldRepresentationTypeRadio: {
            if (columnDefinitionformField.metadataValue) {
                self.columnValueLabel.text = columnDefinitionformField.metadataValue.option.attachedValue;
            } else if (columnDefinitionformField.values) {
                if ([columnDefinitionformField.values.firstObject isKindOfClass:NSDictionary.class]) {
                    self.columnValueLabel.text = columnDefinitionformField.values.firstObject[@"name"];
                } else {
                    self.columnValueLabel.text = columnDefinitionformField.values.firstObject;
                }
            } else {
                self.columnValueLabel.text = @"";
            }
        }
            break;
            
        case ASDKModelFormFieldRepresentationTypeDate: {
            //format date in saved form (2016-02-23T23:00:00Z)
            if (columnDefinitionformField.metadataValue) {
                self.columnValueLabel.text = columnDefinitionformField.metadataValue.attachedValue;
            } else {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                dateFormatter.dateFormat = kASDKServerFullDateFormat;
                
                NSDate *storedDate = [dateFormatter dateFromString:columnDefinitionformField.values.firstObject];
                
                NSDateFormatter *displayDateFormatter = [[NSDateFormatter alloc] init];
                [displayDateFormatter setDateFormat:kASDKServerShortDateFormat];
                
                self.columnValueLabel.text = [displayDateFormatter stringFromDate:storedDate];
            }
        }
            break;
            
        default: {
            NSString *valueString = columnDefinitionformField.values.firstObject ? columnDefinitionformField.values.firstObject : columnDefinitionformField.metadataValue.attachedValue;
            self.columnValueLabel.text = valueString;
        }
            break;
    }
}

@end
