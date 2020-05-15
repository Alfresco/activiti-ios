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

#import "ASDKPeopleFormFieldDetailsViewController.h"

// Categories
#import "UIFont+ASDKGlyphicons.h"
#import "NSString+ASDKFontGlyphicons.h"
#import "UIView+ASDKViewAnimations.h"
#import "UIViewController+ASDKAlertAddition.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKLocalizationConstants.h"

// Controllers
#import "ASDKPeopleFormFieldPeoplePickerViewController.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelUser.h"

// Managers
#import "ASDKBootstrap.h"
#import "ASDKServiceLocator.h"
#import "ASDKFormColorSchemeManager.h"
#import "ASDKKVOManager.h"

// Cells
#import "ASDKPeopleTableViewCell.h"

// Views
#import "ASDKNoContentView.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

typedef NS_ENUM(NSInteger, ASDKPeoplePickerControllerState) {
    AFAPeoplePickerControllerStateIdle,
    AFAPeoplePickerControllerStateInProgress,
};


@interface ASDKPeopleFormFieldDetailsViewController ()

@property (strong, nonatomic) ASDKPeopleFormFieldPeoplePickerViewController         *peoplePickerViewController;
@property (weak, nonatomic) IBOutlet UITableView                                    *peopleTableView;
@property (weak, nonatomic) IBOutlet ASDKNoContentView                              *noContentView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem                              *addBarButtonItem;

// Internal state properties
@property (strong, nonatomic) ASDKModelFormField                                    *currentFormField;

@property (strong, nonatomic) ASDKKVOManager                                        *kvoManager;

@end

@implementation ASDKPeopleFormFieldDetailsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self handleBindingsForNetworkConnectivity];
    }
    
    return self;
}

- (void)dealloc {
    [self.kvoManager removeObserver:self
                         forKeyPath:NSStringFromSelector(@selector(networkReachabilityStatus))];
}


#pragma mark -
#pragma mark Life cycle

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshContent];
}

- (IBAction)unwindFormFieldPeoplePickerController:(UIStoryboardSegue *)segue {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([kSegueIDFormPeoplePicker isEqualToString:segue.identifier]) {
        self.peoplePickerViewController = (ASDKPeopleFormFieldPeoplePickerViewController *)segue.destinationViewController;
        self.peoplePickerViewController.currentFormField = self.currentFormField;
    }
}


#pragma mark -
#pragma mark Actions

- (void)refreshContent {
    // Display the no content view if appropiate
    self.noContentView.hidden = (self.currentFormField.values.count > 0) ? YES : NO;
    self.noContentView.iconImageView.image = [UIImage imageNamed:@"contributors-large-icon"
                                                        inBundle:[NSBundle bundleForClass:self.class]
                                   compatibleWithTraitCollection:nil];
    if ([self isReadonlyForm]) {
        self.noContentView.descriptionLabel.text = ASDKLocalizedStringFromTable(kLocalizationPeoplePickerControllerNoContributorsNotEditableText, ASDKLocalizationTable, @"No people involved not editable text");
    } if (ASDKNetworkReachabilityStatusNotReachable == self.networkReachabilityStatus ||
          ASDKNetworkReachabilityStatusUnknown == self.networkReachabilityStatus) {
        self.noContentView.descriptionLabel.text = ASDKLocalizedStringFromTable(kLocalizationFormFieldNoNetworkConnectionText, ASDKLocalizationTable, @"No network connection available");
    } else {
        self.noContentView.descriptionLabel.text = ASDKLocalizedStringFromTable(kLocalizationPeoplePickerControllerNoContributorsText, ASDKLocalizationTable, @"No people involved text");
    }
    
    [self setRightBarButton];
    [self.peopleTableView reloadData];
}

- (BOOL)isReadonlyForm {
    if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType ||
        ASDKNetworkReachabilityStatusNotReachable == self.networkReachabilityStatus ||
        ASDKNetworkReachabilityStatusUnknown == self.networkReachabilityStatus) {
        return YES;
    }
    
    return NO;
}


#pragma mark -
#pragma mark ASDKFormFieldDetailsControllerProtocol

- (void)setupWithFormFieldModel:(ASDKModelFormField *)formFieldModel {
    self.currentFormField = formFieldModel;
}

- (IBAction)onAdd:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:kSegueIDFormPeoplePicker
                              sender:sender];
}

- (void)setRightBarButton {
    if ([self isReadonlyForm]) {
        [self.addBarButtonItem setEnabled:NO];
        [self.addBarButtonItem setTitle:nil];
    } else {
        UIBarButtonItem *rightBarButtonItem = nil;
        if (self.currentFormField.values.count > 0) {
            rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                               target:self action:@selector(onAdd:)];
        } else {
            rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self action:@selector(onAdd:)];
        }
        rightBarButtonItem.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        
        self.addBarButtonItem = rightBarButtonItem;
    }
}

#pragma mark -
#pragma mark Tableview Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.currentFormField.values.count;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASDKPeopleTableViewCell *peopleCell = [tableView dequeueReusableCellWithIdentifier:kASDKCellIDFormFieldPeopleAddPeople];
    id userInformation = self.currentFormField.values[indexPath.row];
    
    // User information might not contain the concrete user model class
    // and if that's the case, build a string representation out of the
    // pased information
    if ([userInformation isKindOfClass:[ASDKModelUser class]]) {
        [peopleCell setUpCellWithUser:userInformation];
    } else {
        [peopleCell setupCellWithUserNameString:userInformation];
    }
    
    if ([self isReadonlyForm]) {
        peopleCell.userInteractionEnabled = NO;
    }
    
    return peopleCell;
}

- (NSArray *)tableView:(UITableView *)tableView
editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *deleteButton =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                       title:[@"" stringByPaddingToLength:2
                                                               withString:@"\u3000"
                                                          startingAtIndex:0]
                                     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                         __strong typeof(self) strongSelf = weakSelf;
                                         
                                         NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.currentFormField.values];
                                         [tmpArray removeObjectAtIndex:indexPath.row];
                                         strongSelf.currentFormField.values = [tmpArray copy];
                                         
                                         // Notify the value transaction delegate there has been a change with the provided form field model
                                         if ([strongSelf.valueTransactionDelegate respondsToSelector:@selector(updatedMetadataValueForFormField:inCell:)]) {
                                             [strongSelf.valueTransactionDelegate updatedMetadataValueForFormField:strongSelf.currentFormField
                                                                                                      inCell:nil];
                                         }
                                         
                                         [tableView reloadData];
                                         [strongSelf refreshContent];
                                     }];
    
    // Tint the image with white
    UIImage *trashIcon = [UIImage imageNamed:@"trash-icon"
                                    inBundle:[NSBundle bundleForClass:self.class]
               compatibleWithTraitCollection:nil];
    UIGraphicsBeginImageContextWithOptions(trashIcon.size, NO, trashIcon.scale);
    [[UIColor whiteColor] set];
    [trashIcon drawInRect:CGRectMake(0, 0, trashIcon.size.width, trashIcon.size.height)];
    trashIcon = UIGraphicsGetImageFromCurrentImageContext();
    
    // Draw the image and background
    
    ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
    ASDKFormColorSchemeManager *colorSchemeManager = [sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKFormColorSchemeManagerProtocol)];
    
    CGSize rowActionSize = CGSizeMake([tableView rectForRowAtIndexPath:indexPath].size.width, [tableView rectForRowAtIndexPath:indexPath].size.height);
    UIGraphicsBeginImageContextWithOptions(rowActionSize, YES, [[UIScreen mainScreen] scale]);
    CGContextRef context=UIGraphicsGetCurrentContext();
    [colorSchemeManager.formViewBackgroundColorForDistructiveOperation set];
    CGContextFillRect(context, CGRectMake(0, 0, rowActionSize.width, rowActionSize.height));
    
    [trashIcon drawAtPoint:CGPointMake(trashIcon.size.width + trashIcon.size.width / 4.0f, rowActionSize.height / 2.0f - trashIcon.size.height / 2.0f)];
    [deleteButton setBackgroundColor:[UIColor colorWithPatternImage:UIGraphicsGetImageFromCurrentImageContext()]];
    UIGraphicsEndImageContext();
    
    return @[deleteButton];
}


#pragma mark -
#pragma mark KVO Bindings

- (void)handleBindingsForNetworkConnectivity {
    self.kvoManager = [ASDKKVOManager managerWithObserver:self];
    
    __weak typeof(self) weakSelf = self;
    [self.kvoManager observeObject:self
                        forKeyPath:NSStringFromSelector(@selector(networkReachabilityStatus))
                           options:NSKeyValueObservingOptionNew
                             block:^(id observer, id object, NSDictionary *change) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [weakSelf refreshContent];
                                 });
                             }];
}

@end
