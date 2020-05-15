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

#import "AFACredentialsPageViewController.h"
#import "AFALoginCredentialsViewController.h"
#import "AFAUIConstants.h"
#import "AFALoginCredentialsViewControllerDataSource.h"
#import "AFALoginViewModel.h"

typedef NS_ENUM(NSInteger, AFACredentialsPageType) {
    AFACredentialsPageTypeEmptyPlaceholder = 0,
    AFACredentialsPageTypeCloudCredentials,
    AFACredentialsPageTypePremiseCredentials
};

@interface AFACredentialsPageViewController ()

@property (strong, nonatomic) NSArray *viewControllersList;

@end

@implementation AFACredentialsPageViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        _cloudLoginViewModel = [AFALoginViewModel new];
        _cloudLoginViewModel.authentificationType = AFALoginAuthenticationTypeCloud;
        _premiseLoginViewModel = [AFALoginViewModel new];
        _premiseLoginViewModel.authentificationType = AFALoginAuthenticationTypePremise;
    }
    
    return self;
}


#pragma mark - 
#pragma View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Cloud setup
    AFALoginCredentialsViewControllerDataSource *cloudDataSource = [[AFALoginCredentialsViewControllerDataSource alloc] initWithLoginModel:self.cloudLoginViewModel];
    AFALoginCredentialsViewController *loginCloudCredentialsViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDLoginCredentialsViewController];
    loginCloudCredentialsViewController.dataSource = cloudDataSource;
    
    // Premise setup
    AFALoginCredentialsViewControllerDataSource *premiseDataSource = [[AFALoginCredentialsViewControllerDataSource alloc] initWithLoginModel:self.premiseLoginViewModel];
    AFALoginCredentialsViewController *loginPremiseCredentialsViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDLoginCredentialsViewController];
    loginPremiseCredentialsViewController.dataSource = premiseDataSource;
    
    UIViewController *emptyPlaceholderViewController = [UIViewController new];
    
    self.viewControllersList = @[emptyPlaceholderViewController, loginCloudCredentialsViewController, loginPremiseCredentialsViewController];
    [self setViewControllers:@[emptyPlaceholderViewController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}


#pragma mark -
#pragma mark UIPageViewController DataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger currentIndex = [self.viewControllersList indexOfObject:viewController];
    
    --currentIndex;
    currentIndex = currentIndex % (self.viewControllers.count);
    return [self.viewControllersList objectAtIndex:currentIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger currentIndex = [self.viewControllersList indexOfObject:viewController];
    
    ++currentIndex;
    currentIndex = currentIndex % (self.viewControllersList.count);
    return [self.viewControllersList objectAtIndex:currentIndex];
}


#pragma mark -
#pragma mark Public interface

- (void)showCloudLoginCredentials {
    [self setViewControllers:@[self.viewControllersList[AFACredentialsPageTypeCloudCredentials]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
}

- (void)showPremiseLoginCredentials {
    [self setViewControllers:@[self.viewControllersList[AFACredentialsPageTypePremiseCredentials]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
}

- (void)hideCurrentPageWithCompletionBlock:(void (^)(BOOL finished))completionBlock {
    [self setViewControllers:@[self.viewControllersList[AFACredentialsPageTypeEmptyPlaceholder]]
                   direction:UIPageViewControllerNavigationDirectionReverse
                    animated:YES
                  completion:completionBlock];
}

@end
