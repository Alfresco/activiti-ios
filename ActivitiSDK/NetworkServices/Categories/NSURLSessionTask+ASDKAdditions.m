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

#import "NSURLSessionTask+ASDKAdditions.h"
#import "ASDKNetworkServiceConstants.h"

@implementation NSURLSessionTask (ASDKAdditions)

- (NSInteger)statusCode {
    NSInteger statusCode = 0;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)self.response;
    
    if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        statusCode = httpResponse.statusCode;
    }
    
    return statusCode;
}

- (NSString *)requestDescription {
    return [NSString stringWithFormat:kASDKAPIResponseFormat,
            self.originalRequest.HTTPMethod,
            self.originalRequest.URL.absoluteString,
            [[NSString alloc] initWithData:self.originalRequest.HTTPBody encoding:NSUTF8StringEncoding]];
}

- (NSString *)stateDescriptionForResponse:(id)responseObject
                                withError:(NSError *)error {
    NSString *requestStatusString = nil;
    NSString *responseString = nil;
    
    if (!error) {
        responseString = [NSString stringWithFormat:kASDKAPISuccessfulResponseFormat, responseObject];
        requestStatusString = [NSString stringWithFormat:@"%@%@", [self requestDescription], responseString];
    } else {
        responseString = [NSString stringWithFormat:kASDKAPIFailedResponseFormat, error.localizedDescription];
        requestStatusString = [NSString stringWithFormat:@"%@%@", [self requestDescription], responseString];
    }
    
    return requestStatusString;
}

- (NSString *)stateDescriptionForResponse:(id)responseObject {
    return [self stateDescriptionForResponse:responseObject
                                   withError:self.error];
}

- (NSString *)stateDescriptionForError:(NSError *)error {
    return [self stateDescriptionForResponse:nil
                                   withError:error];
}

@end
