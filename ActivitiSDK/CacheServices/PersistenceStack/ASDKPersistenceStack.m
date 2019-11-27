/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import "ASDKPersistenceStack.h"

// Constants
#import "ASDKPersistenceStackConstants.h"
#import "ASDKLogConfiguration.h"

// Models
#import "ASDKModelServerConfiguration.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@implementation ASDKPersistenceStack


#pragma mark -
#pragma mark Life cycle

- (instancetype)initWithServerConfiguration:(ASDKModelServerConfiguration *)serverConfiguration
                               errorHandler:(ASDKPersistenceErrorHandlerBlock)errorHandlerBlock {
    self = [super init];
    if (self) {
        NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"CacheServicesDataModel"
                                                                   withExtension:@"momd"];
        if (!modelURL) {
            ASDKLogError(@"Cannot initialize persistence stack. Reason:%@", [self persistenceStackInitializationError]);
            return nil;
        }
        
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSPersistentContainer *persistentContainer = [[NSPersistentContainer alloc] initWithName:[ASDKPersistenceStack persistenceStackModelNameForServerConfiguration: serverConfiguration]
                                                                              managedObjectModel:managedObjectModel];
        
        [persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *description, NSError *error) {
            persistentContainer.viewContext.automaticallyMergesChangesFromParent = YES;
            persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
            if (errorHandlerBlock) {
                errorHandlerBlock(error);
            }
        }];
        
        _persistentContainer = persistentContainer;
    }
    
    return self;
}

+ (NSString *)persistenceStackModelNameForServerConfiguration:(ASDKModelServerConfiguration *)serverConfiguration {
    if (serverConfiguration.hostAddressString.length &&
        serverConfiguration.serviceDocument.length) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9_]+"
                                                                               options:kNilOptions
                                                                                 error:nil];
        
        
        NSString *normalizedHostName = [regex stringByReplacingMatchesInString:serverConfiguration.hostAddressString
                                                                       options:kNilOptions
                                                                         range:NSMakeRange(0, serverConfiguration.hostAddressString.length)
                                                                  withTemplate:@""];
        NSString *normalizedUserName;
        if (serverConfiguration.username.length) {
            normalizedHostName = [regex stringByReplacingMatchesInString:serverConfiguration.username
                 options:kNilOptions
                   range:NSMakeRange(0, serverConfiguration.username.length)
            withTemplate:@""];
        }
        
        NSString *normalizedServiceDocument = [regex stringByReplacingMatchesInString:serverConfiguration.serviceDocument
                                                                              options:kNilOptions
                                                                                range:NSMakeRange(0, serverConfiguration.serviceDocument.length)
                                                                         withTemplate:@""];
        
        if (normalizedUserName) {
            return [NSString stringWithFormat:@"%@@%@@%@", normalizedHostName, normalizedServiceDocument, normalizedUserName];
        } else {
            return [NSString stringWithFormat:@"%@@%@", normalizedHostName, normalizedServiceDocument];
        }
    }
    
    return kASDKPersistenceStackNameDefault;
}


#pragma mark -
#pragma mark Public interface

- (NSManagedObjectContext *)viewContext {
    return self.persistentContainer.viewContext;
}

- (NSManagedObjectContext *)backgroundContext {
    return [self.persistentContainer newBackgroundContext];
}

- (void)performForegroundTask:(ASDKPersistenceTaskBlock)taskBlock {
    __weak typeof(self) weakSelf = self;
    [[self viewContext] performBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        taskBlock([strongSelf viewContext]);
    }];
}

- (void)performBackgroundTask:(ASDKPersistenceTaskBlock)taskBlock {
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *managedObjectContext) {
        taskBlock(managedObjectContext);
    }];
}
- (void)saveContext {
    NSError *error = nil;
    if ([[self viewContext] hasChanges]) {
        if (![[self viewContext] save:&error]) {
            ASDKLogError(@"Cannot save view context. Reason:%@.\nCore Data stack error:%@", [self saveViewContextOperationError], error.localizedDescription);
            [[self viewContext] rollback];
        }
    }
}


#pragma mark -
#pragma mark Error reporting and handling

- (NSError *)persistenceStackInitializationError {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey            : @"Cannot initialize Core Data stack",
                               NSLocalizedFailureReasonErrorKey     : @"Cannot load the necessary schema details.",
                               NSLocalizedRecoverySuggestionErrorKey: @"Check the resource path for the schema object."};
    return [NSError errorWithDomain:ASDKPersistenceStackErrorDomain
                               code:kASDKPersistenceStackInitializationErrorCode
                           userInfo:userInfo];
}

- (NSError *)saveViewContextOperationError {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey            : @"Cannot save view context",
                               NSLocalizedFailureReasonErrorKey     : @"An error occured during the save operation. Rolling back changes.",
                               NSLocalizedRecoverySuggestionErrorKey: @"Investigate the detailed error responses thrown by Core Data during the save operation."};
    return [NSError errorWithDomain:ASDKPersistenceStackErrorDomain
                               code:kASDKPersistenceStackSaveViewContextErrorCode
                           userInfo:userInfo];
}

@end
