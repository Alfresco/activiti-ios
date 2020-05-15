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

#import <Foundation/Foundation.h>

@interface NSURLSessionTask (ASDKAdditions)

/**
 *  Casts the NSURLSessionDataTask response property to a NSHTTPURLResponse 
 *  to get the status code if possible.
 *
 *  @return Integer value representing the status code or 0 if the status 
 *          cannot be determined.
 */
- (NSInteger)statusCode;

/**
 *  Returns a string describing details like HTTP method, URL and body
 *  of the request.
 *
 *  @return Formatted string containing the before enumerated details in that 
 *          order.
 */
- (NSString *)requestDescription;

/**
 *  Returns a formatted string containing task information like the used
 *  HTTP method, resource URI, body of the request, response information 
 *  and an optional error.
 *
 *  This method should be used if the error is not nil, otherwise use the 
 *  alternative without an error parameter.
 *
 *  @param responseObject Serialized response object provided by the AFNetworking
 *                        network.
 *  @param error          Error object describing the issue with the current task
 *
 *  @return               Formatted string containing the before enumerated details 
 *                        in that order.
 */
- (NSString *)stateDescriptionForResponse:(id)responseObject
                                withError:(NSError *)error;

/**
 *  Returns a formatted string containing task information like the used 
 *  HTTP method, resource URI, body of the request, and response information.
 *
 *  @param responseObject Serialized response object provided by the AFNetworking 
 *                        network.
 *
 *  @return               Formatted string containing the before enumerated details 
 *                        in that order.
 */
- (NSString *)stateDescriptionForResponse:(id)responseObject;

/**
 *  Returns a formatted string containing task information like the used 
 *  HTTP method, resource URI, body of the request and an error reason describing
 *  why the request failed.
 *
 *  @param error Error object describing the issue with the current task
 *
 *  @return      Formatted string containing the before enumerated details
 *               in that order.
 */
- (NSString *)stateDescriptionForError:(NSError *)error;

@end
