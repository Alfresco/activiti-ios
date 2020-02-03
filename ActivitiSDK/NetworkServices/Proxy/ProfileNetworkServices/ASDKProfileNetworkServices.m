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

#import "ASDKProfileNetworkServices.h"

// Constants
#import "ASDKLogConfiguration.h"
#import "ASDKNetworkServiceConstants.h"

// Categories
#import "NSURLSessionTask+ASDKAdditions.h"

// Models
#import "ASDKAuthenticateRequestRepresentation.h"
#import "ASDKProfileInformationRequestRepresentation.h"
#import "ASDKProfilePasswordRequestRepresentation.h"
#import "ASDKModelPaging.h"
#import "ASDKModelFileContent.h"

// Managers
#import "ASDKCSRFTokenStorage.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@interface ASDKProfileNetworkServices ()

@property (strong, nonatomic) NSMutableArray *networkOperations;

@end

@implementation ASDKProfileNetworkServices


#pragma mark -
#pragma mark Life cycle

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.networkOperations = [NSMutableArray array];
    }
    
    return self;
}


#pragma mark -
#pragma mark ASDKProfileNetworkService Protocol

- (void)authenticateUser:(NSString *)username
            withPassword:(NSString *)password
     withCompletionBlock:(ASDKProfileAutheticationCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(username);
    NSParameterAssert(password);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    // Use the HTTP with CSRF request serializer type for the authentication call then reinstall the default authentication provider
    self.requestOperationManager.requestSerializer = [self requestSerializerOfType:(ASDKNetworkServiceRequestSerializerTypeHTTPWithCSRFToken)];
    
    ASDKAuthenticateRequestRepresentation *autheticateRequestRepresentation = [ASDKAuthenticateRequestRepresentation new];
    autheticateRequestRepresentation.username = username;
    autheticateRequestRepresentation.password = password;
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager POST:[self.servicePathFactory authenticationServicePath]
                            parameters:[autheticateRequestRepresentation jsonDictionary]
                              progress:nil
                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Reinstate the authentication request serializer
        strongSelf.requestOperationManager.requestSerializer = strongSelf.requestOperationManager.authenticationProvider;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        // Check status code
        NSInteger statusCode = [task statusCode];
        if (ASDKHTTPCode200OK == statusCode) {
            ASDKLogVerbose(@"User authenticated successfully for request: %@",
                           [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
            
            dispatch_async(strongSelf.resultsQueue, ^{
                completionBlock(YES, nil);
            });
        } else {
            ASDKLogError(@"Failed to authenticate user for request: %@",
                         [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
            
            dispatch_async(strongSelf.resultsQueue, ^{
                completionBlock(NO, nil);
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Reinstate the authentication request serializer
        strongSelf.requestOperationManager.requestSerializer = strongSelf.requestOperationManager.authenticationProvider;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        ASDKLogError(@"Failed to authenticate user for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(NO, error);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)fetchProfileWithCompletionBlock:(ASDKProfileCompletionBlock)completionBlock {
    // Check mandatory data
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    __block NSURLSessionDataTask *dataTask =
    [self.requestOperationManager GET:[self.servicePathFactory profileServicePath]
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        ASDKLogVerbose(@"Profile data fetched successfully for request: %@",
                       [task stateDescriptionForResponse:responseDictionary]);
        
        // Parse response data
        NSString *parserContentType = CREATE_STRING(ASDKProfileParserContentTypeProfile);
        
        [strongSelf.parserOperationManager
         parseContentDictionary:responseDictionary
         ofType:parserContentType
         withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
            if (error) {
                ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(nil, error);
                });
            } else {
                ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(parsedObject, nil);
                });
            }
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        // Remove operation reference
        [strongSelf.networkOperations removeObject:dataTask];
        
        ASDKLogError(@"Failed to fetch profile data for request: %@",
                     [task stateDescriptionForError:error]);
        
        dispatch_async(strongSelf.resultsQueue, ^{
            completionBlock(nil, error);
        });
    }];
    
    // Keep network operation reference to be able to cancel it
    [self.networkOperations addObject:dataTask];
}

- (void)updateProfileWithModel:(ASDKModelProfile *)profileModel
               completionBlock:(ASDKProfileCompletionBlock)completionBlock {
    // Check mandatory fields
    NSParameterAssert(profileModel.userFirstName &&
                      profileModel.userLastName &&
                      profileModel.email &&
                      profileModel.companyName &&
                      completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    // Populate a request representation with the needed information
    ASDKProfileInformationRequestRepresentation *profileInformationRequestRepresentation = [ASDKProfileInformationRequestRepresentation new];
    profileInformationRequestRepresentation.userID = profileModel.modelID;
    profileInformationRequestRepresentation.userFirstName = profileModel.userFirstName;
    profileInformationRequestRepresentation.userLastName = profileModel.userLastName;
    profileInformationRequestRepresentation.email = profileModel.email;
    profileInformationRequestRepresentation.companyName = profileModel.companyName;
    profileInformationRequestRepresentation.password = profileModel.password;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[strongSelf.servicePathFactory profileServicePath]
                                      parameters:[profileInformationRequestRepresentation jsonDictionary]
                                        progress:nil
                                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            ASDKLogVerbose(@"Profile data was updated successfully for request: %@",
                           [task stateDescriptionForResponse:responseDictionary]);
            
            // Parse response data
            NSString *parserContentType = CREATE_STRING(ASDKProfileParserContentTypeProfile);
            
            [weakSelf.parserOperationManager
             parseContentDictionary:responseDictionary
             ofType:parserContentType
             withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                if (error) {
                    ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                    dispatch_async(weakSelf.resultsQueue, ^{
                        completionBlock(nil, error);
                    });
                } else {
                    ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                    dispatch_async(weakSelf.resultsQueue, ^{
                        completionBlock(parsedObject, nil);
                    });
                }
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to fetch profile data for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)fetchProfileImageWithCompletionBlock:(ASDKProfileImageCompletionBlock)completionBlock {
    // Check mandatory data
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager GET:[strongSelf.servicePathFactory profilePicturePath]
                               parameters:nil
                                 progress:nil
                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            UIImage *profileImage = nil;
            if ([responseObject isKindOfClass:[UIImage class]]) {
                ASDKLogVerbose(@"Profile picture fetched successfully for request: %@.",
                               [task stateDescriptionForResponse:nil]);
                profileImage = (UIImage *)responseObject;
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(profileImage, nil);
                });
            } else {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid image format received", @""),
                                           NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Image cannot be parsed from response because a different format than expected was received:%@", NSStringFromClass([responseObject class])]};
                NSError *imageFormatError = [NSError errorWithDomain:ASDKNetworkServiceErrorDomain
                                                                code:ASDKNetworkServiceErrorInvalidResponseFormat
                                                            userInfo:userInfo];
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(nil, imageFormatError);
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to fetch profile picture for request:%@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(nil, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)updateProfileWithNewPassword:(NSString *)updatedPassword
                         oldPassword:(NSString *)oldPassword
                     completionBlock:(ASDKProfilePasswordCompletionBlock)completionBlock {
    // Check mandatory fields
    NSParameterAssert(updatedPassword &&
                      oldPassword &&
                      completionBlock);
    
    // Populate a request representation with the needed information
    ASDKProfilePasswordRequestRepresentation *profilePasswordRequestRepresentation = [ASDKProfilePasswordRequestRepresentation new];
    profilePasswordRequestRepresentation.updatedPassword = updatedPassword;
    profilePasswordRequestRepresentation.oldPassword = oldPassword;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [self.requestOperationManager POST:[strongSelf.servicePathFactory profilePasswordPath]
                                parameters:[profilePasswordRequestRepresentation jsonDictionary]
                                  progress:nil
                                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            // Check status code
            NSInteger statusCode = [task statusCode];
            if (ASDKHTTPCode200OK == statusCode) {
                ASDKLogVerbose(@"Profile password was updated successfully for request: %@",
                               [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(YES, nil);
                });
            } else {
                ASDKLogError(@"Profile password failed to update successfully for request: %@",
                             [task stateDescriptionForResponse:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    completionBlock(NO, nil);
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to update profile password for request: %@",
                         [task stateDescriptionForError:error]);
            
            dispatch_async(weakSelf.resultsQueue, ^{
                completionBlock(NO, error);
            });
        }];
        
        // Keep network operation reference to be able to cancel it
        [strongSelf.networkOperations addObject:dataTask];
    });
}

- (void)uploadProfileImageWithModel:(ASDKModelFileContent *)file
                        contentData:(NSData *)contentData
                      progressBlock:(ASDKProfileContentProgressBlock)progressBlock
                    completionBlock:(ASDKProfileImageContentUploadCompletionBlock)completionBlock {
    // Check mandatory properties
    NSParameterAssert(file);
    NSParameterAssert(contentData);
    NSParameterAssert(completionBlock);
    NSParameterAssert(self.resultsQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.resultsQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        __block NSURLSessionDataTask *dataTask =
        [strongSelf.requestOperationManager POST:[strongSelf.servicePathFactory profilePictureUploadPath]
                                      parameters:nil
                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSError *error = nil;
            
            [formData appendPartWithFileData:contentData
                                        name:kASDKAPIContentUploadMultipartParameter
                                    fileName:file.fileName
                                    mimeType:file.mimeType];
            
            if (error) {
                ASDKLogError(@"An error occured while appending multipart form data from file %@.", file.modelFileURL);
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            // If a progress block is provided report transfer progress information
            if (progressBlock) {
                NSUInteger percentProgress = (NSUInteger) (uploadProgress.completedUnitCount * 100 / uploadProgress.totalUnitCount);
                
                dispatch_async(weakSelf.resultsQueue, ^{
                    progressBlock(percentProgress, nil);
                });
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            ASDKLogVerbose(@"Profile picture succesfully uploaded for request: %@",
                           [task stateDescriptionForResponse:responseDictionary]);
            
            // Parse response data
            NSString *parserContentType = CREATE_STRING(ASDKProfileParserContentTypeContent);
            [weakSelf.parserOperationManager parseContentDictionary:responseDictionary
                                                             ofType:parserContentType
                                                withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
                if (error) {
                    ASDKLogError(kASDKAPIParserManagerConversionErrorFormat, parserContentType, error.localizedDescription);
                    dispatch_async(weakSelf.resultsQueue, ^{
                        completionBlock(nil, error);
                    });
                } else {
                    ASDKLogVerbose(kASDKAPIParserManagerConversionFormat, parserContentType, parsedObject);
                    dispatch_async(weakSelf.resultsQueue, ^{
                        completionBlock(parsedObject, nil);
                    });
                }
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // Remove operation reference
            [weakSelf.networkOperations removeObject:dataTask];
            
            ASDKLogError(@"Failed to upload profile picture for request: %@",
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
