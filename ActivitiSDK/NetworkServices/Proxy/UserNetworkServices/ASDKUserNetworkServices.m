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

#import "ASDKUserNetworkServices.h"

// Constants
#import "ASDKLogConfiguration.h"
#import "ASDKNetworkServiceConstants.h"

// Categories
#import "NSURLSessionTask+ASDKAdditions.h"

// Model
#import "ASDKUserRequestRepresentation.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKUserNetworkServices ()

@property (strong, nonatomic) NSMutableArray *networkOperations;

@end

@implementation ASDKUserNetworkServices

#pragma mark -
#pragma mark Life cycle

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.networkOperations = [NSMutableArray array];
    }
    
    return self;
}

- (void)fetchUsersWithUserRequestRepresentation:(ASDKUserRequestRepresentation *)userRequest
                                completionBlock:(ASDKUsersCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(userRequest);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager GET:[strongSelf.servicePathFactory userListServicePath]
                                     parameters:[userRequest jsonDictionary]
                                       progress:nil
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            ASDKLogVerbose(@"Users fetched successfully for request: %@",
                           [task stateDescriptionForResponse:responseDictionary]);
            
            // Parse response data
            NSString *parserContentType = CREATE_STRING(ASDKUserParserContentTypeUserList);
            [weakSelf.parserOperationManager
             parseContentDictionary:responseDictionary
             ofType:parserContentType
             withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                if (error) {
                    ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                    dispatch_async(weakSelf.resultsQueue, ^{
                        completionBlock(nil, error, paging);
                    });
                } else {
                    ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                    dispatch_async(weakSelf.resultsQueue, ^{
                        completionBlock(parsedObject, nil, paging);
                    });
                }
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to fetch users list for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error, nil);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)fetchPictureForUserID:(NSString *)userID
              completionBlock:(ASDKUsersPictureCompletionBlock)completionBlock {
    // Check mandatory data
    NSParameterAssert(userID);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager GET:[NSString stringWithFormat:[strongSelf.servicePathFactory userProfileImageServicePathFormat], userID]
                                     parameters:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            UIImage *profileImage = (UIImage *)responseObject;
            ASDKLogVerbose(@"Profile picture fetched successfully for request: %@", [task stateDescriptionForResponse:nil]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(profileImage, nil);
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to fetch profile picture for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)cancelAllNetworkOperations {
    [self.networkOperations makeObjectsPerformSelector:@selector(cancel)];
    [self.networkOperations removeAllObjects];
}

@end
