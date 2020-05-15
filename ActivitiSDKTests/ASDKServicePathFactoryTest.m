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

#import "ASDKBaseTest.h"

@interface ASDKServicePathFactoryTest : ASDKBaseTest

@property (strong, nonatomic) ASDKServicePathFactory *servicePathFactory;

@end

@implementation ASDKServicePathFactoryTest

- (void)setUp {
    [super setUp];
 
    NSString *hostAddress = @"localhost";
    NSString *serviceDocumentPath = @"activiti-app";
    NSString *port = @"9999";
    BOOL overSecureLayer = NO;
    
    self.servicePathFactory = [[ASDKServicePathFactory alloc] initWithHostAddress:hostAddress
                                                              serviceDocumentPath:serviceDocumentPath
                                                                             port:port
                                                                  overSecureLayer:overSecureLayer];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItCreatesBaseURL {
    // given
    NSString *hostnameAddress = @"http://localhost:9999";
    NSURL *baseURL = [NSURL URLWithString:@"activiti-app" relativeToURL:
                      [NSURL URLWithString:[hostnameAddress stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    
    // then
    XCTAssertTrue([self isURL:baseURL
              equivalentToURL:self.servicePathFactory.baseURL]);
}

- (void)testThatItCreatesBaseURLOverSecureConnection {
    // given
    self.servicePathFactory = [[ASDKServicePathFactory alloc] initWithHostAddress:@"localhost"
                                                              serviceDocumentPath:@"activiti-app"
                                                                             port:@"9999"
                                                                  overSecureLayer:YES];
    
    NSString *hostnameAddress = @"https://localhost:9999";
    NSURL *baseURL = [NSURL URLWithString:@"activiti-app" relativeToURL:
                      [NSURL URLWithString:[hostnameAddress stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    
    // then
    XCTAssertTrue([self isURL:baseURL
              equivalentToURL:self.servicePathFactory.baseURL]);
}

- (void)testThatItCreatesServerInformationPath {
    XCTAssertTrue([[self.servicePathFactory serverInformationServicePath] isEqualToString:@"api/enterprise/app-version"]);
}

- (void)testThatItCreatesRuntimeAppDefinitionsPath {
    XCTAssertTrue([[self.servicePathFactory runtimeAppDefinitionsServicePath] isEqualToString:@"api/enterprise/runtime-app-definitions"]);
}

- (void)testThatItCreatesProfilePath {
    XCTAssertTrue([[self.servicePathFactory profileServicePath] isEqualToString:@"api/enterprise/profile"]);
}

- (void)testThatItCreatesProfilePicturePath {
    XCTAssertTrue([[self.servicePathFactory profilePicturePath] isEqualToString:@"api/enterprise/profile-picture"]);
}

- (void)testThatItCreatesProfilePasswordPath {
    XCTAssertTrue([[self.servicePathFactory profilePasswordPath] isEqualToString:@"api/enterprise/profile-password"]);
}

- (void)testThatItCreatesProfilePictureUploadPath {
    XCTAssertTrue([[self.servicePathFactory profilePictureUploadPath] isEqualToString:@"api/enterprise/profile-picture"]);
}

- (void)testThatItCreatesTaskListPath {
    XCTAssertTrue([[self.servicePathFactory taskListServicePath] isEqualToString:@"api/enterprise/tasks/query"]);
}

- (void)testThatItCreatesTaskListFromFilterPath {
    XCTAssertTrue([[self.servicePathFactory taskListFromFilterServicePath] isEqualToString:@"api/enterprise/tasks/filter"]);
}

- (void)testThatItCreatesTaskDetailsPath {
    XCTAssertTrue([[self.servicePathFactory taskDetailsServicePathFormat] isEqualToString:@"api/enterprise/tasks/%@"]);
}

- (void)testThatItCreatesTaskContentPath {
    XCTAssertTrue([[self.servicePathFactory taskContentServicePathFormat] isEqualToString:@"api/enterprise/tasks/%@/content"]);
}

- (void)testThatItCreatesTaskCommentPath {
    XCTAssertTrue([[self.servicePathFactory taskCommentServicePathFormat] isEqualToString:@"api/enterprise/tasks/%@/comments"]);
}

- (void)testThatItCreatesTaskActionCompletePath {
    XCTAssertTrue([[self.servicePathFactory taskActionCompleteServicePathFormat] isEqualToString:@"api/enterprise/tasks/%@/action/complete"]);
}

- (void)testThatItCreatesTaskContentUploadPath {
    XCTAssertTrue([[self.servicePathFactory taskContentUploadServicePathFormat] isEqualToString:@"api/enterprise/tasks/%@/raw-content"]);
}

- (void)testThatItCreatesTaskContentDownloadPath {
    XCTAssertTrue([[self.servicePathFactory taskContentDownloadServicePathFormat] isEqualToString:@"api/enterprise/content/%@/raw"]);
}

- (void)testThatItCreatesTaskUserInvolvePath {
    XCTAssertTrue([[self.servicePathFactory taskUserInvolveServicePathFormat] isEqualToString:@"api/enterprise/tasks/%@/action/involve"]);
}

- (void)testThatItCreatesTaskUserRemoveInvolvedPath {
    XCTAssertTrue([[self.servicePathFactory taskUserRemoveInvolvedServicePathFormat] isEqualToString:@"api/enterprise/tasks/%@/action/remove-involved"]);
}

- (void)testThatItCreatesTaskCreationPath {
    XCTAssertTrue([[self.servicePathFactory taskCreationServicePath] isEqualToString:@"api/enterprise/tasks"]);
}

- (void)testThatItCreatesTaskClaimPath {
    XCTAssertTrue([[self.servicePathFactory taskClaimServicePathFormat] isEqualToString:@"api/enterprise/tasks/%@/action/claim"]);
}

- (void)testThatItCreatesTaskUnclaimPath {
    XCTAssertTrue([[self.servicePathFactory taskUnclaimServicePathFormat] isEqualToString:@"api/enterprise/tasks/%@/action/unclaim"]);
}

- (void)testThatItCreatesTaskAssignPath {
    XCTAssertTrue([[self.servicePathFactory taskAssignServicePathFormat] isEqualToString:@"api/enterprise/tasks/%@/action/assign"]);
}

- (void)testThatItCreatesTaskAuditLogPath {
    XCTAssertTrue([[self.servicePathFactory taskAuditLogServicePathFormat] isEqualToString:@"app/rest/tasks/%@/audit"]);
}

- (void)testThatItCreatesTaskChecklistPath {
    XCTAssertTrue([[self.servicePathFactory taskCheckListServicePathFormat] isEqualToString:@"api/enterprise/tasks/%@/checklist"]);
}

- (void)testThatItCreatesFilterListPath {
    XCTAssertTrue([[self.servicePathFactory taskFilterListServicePath] isEqualToString:@"api/enterprise/filters/tasks"]);
}

- (void)testThatItCreatesProcessInstanceFilterListPath {
    XCTAssertTrue([[self.servicePathFactory processInstanceFilterListServicePath] isEqualToString:@"api/enterprise/filters/processes"]);
}

- (void)testThatItCreatesContentPath {
    XCTAssertTrue([[self.servicePathFactory contentServicePathFormat] isEqualToString:@"api/enterprise/content/%@"]);
}

- (void)testThatItCreatesProcessDefinitionStartFormPath {
    XCTAssertTrue([[self.servicePathFactory processDefinitionStartFormServicePathFormat] isEqualToString:@"api/enterprise/process-definitions/%@/start-form"]);
}

- (void)testThatItCreatesProcessInstanceStartFormPath {
    XCTAssertTrue([[self.servicePathFactory processInstanceStartFormServicePathFormat] isEqualToString:@"api/enterprise/process-instances/%@/start-form"]);
}

- (void)testThatItCreatesTaskFormPath {
    XCTAssertTrue([[self.servicePathFactory taskFormServicePathFormat] isEqualToString:@"api/enterprise/task-forms/%@"]);
}

- (void)testThatItCreatesContentFieldUploadPath {
    XCTAssertTrue([[self.servicePathFactory contentFieldUploadServicePath] isEqualToString:@"api/enterprise/content/raw"]);
}

- (void)testThatItCreatesRestFieldValueServicePath {
    XCTAssertTrue([[self.servicePathFactory restFieldValuesServicePathFormat] isEqualToString:@"api/enterprise/task-forms/%@/form-values/%@"]);
}

- (void)testThatItCreatesDynamicTableRestFieldValuePath {
    XCTAssertTrue([[self.servicePathFactory dynamicTableRestFieldValuesServicePathFormat] isEqualToString:@"api/enterprise/task-forms/%@/form-values/%@/%@"]);
}

- (void)testThatItCreatesStartFormCompletionPath {
    XCTAssertTrue([[self.servicePathFactory startFormCompletionPath] isEqualToString:@"api/enterprise/process-instances"]);
}

- (void)testThatItCreatesStartFormRestFieldValuesPath {
    XCTAssertTrue([[self.servicePathFactory startFormRestFieldValuesServicePathFormat] isEqualToString:@"api/enterprise/process-definitions/%@/start-form-values/%@"]);
}

- (void)testThatItCreatesStartFormDynamicTableRestFieldValuePath {
    XCTAssertTrue([[self.servicePathFactory startFormDynamicTableRestFieldValuesServicePathFormat] isEqualToString:@"api/enterprise/process-definitions/%@/start-form-values/%@/%@"]);
}

- (void)testThatItCreatesSaveFormPath {
    XCTAssertTrue([[self.servicePathFactory saveFormServicePathFormat] isEqualToString:@"api/enterprise/task-forms/%@/save-form"]);
}

- (void)testThatItCreatesProcessDefinitionListPath {
    XCTAssertTrue([[self.servicePathFactory processDefinitionListServicePathFormat] isEqualToString:@"api/enterprise/process-definitions"]);
}

- (void)testThatItCreatesStartProcessInstancePath {
    XCTAssertTrue([[self.servicePathFactory startProcessInstanceServicePath] isEqualToString:@"api/enterprise/process-instances"]);
}

- (void)testThatItCreatesProcessInstancesListPath {
    XCTAssertTrue([[self.servicePathFactory processInstancesListServicePath] isEqualToString:@"api/enterprise/process-instances/filter"]);
}

- (void)testThatItCreatesProcessInstanceDetailsPath {
    XCTAssertTrue([[self.servicePathFactory processInstanceDetailsServicePathFormat] isEqualToString:@"api/enterprise/process-instances/%@"]);
}

- (void)testThatItCreatesProcessInstanceContentPath {
    XCTAssertTrue([[self.servicePathFactory processInstanceContentServicePathFormat] isEqualToString:@"api/enterprise/process-instances/%@/field-content"]);
}

- (void)testThatItCreatesProcessInstanceCommentPath {
    XCTAssertTrue([[self.servicePathFactory processInstanceCommentServicePathFormat] isEqualToString:@"api/enterprise/process-instances/%@/comments"]);
}

- (void)testThatItCreatesProcessInstanceAuditLogPath {
    XCTAssertTrue([[self.servicePathFactory processInstanceAuditLogServicePathFormat] isEqualToString:@"app/rest/process-instances/%@/audit"]);
}

- (void)testThatItCreatesUserListPath {
    XCTAssertTrue([[self.servicePathFactory userListServicePath] isEqualToString:@"api/enterprise/users"]);
}

- (void)testThatItCreatesUserProfileImagePath {
    XCTAssertTrue([[self.servicePathFactory userProfileImageServicePathFormat] isEqualToString:@"api/enterprise/users/%@/picture"]);
}

- (void)testThatItCreatesAuthenticationPath {
    XCTAssertTrue([[self.servicePathFactory authenticationServicePath] isEqualToString:@"app/authentication"]);
}

- (void)testThatItCreatesTaskQueryPath {
    XCTAssertTrue([[self.servicePathFactory taskQueryServicePath] isEqualToString:@"api/enterprise/tasks/query"]);
}

- (void)testThatItCreatesIntegrationAccountPath {
    XCTAssertTrue([[self.servicePathFactory integrationAccountsServicePath] isEqualToString:@"api/enterprise/account/integration"]);
}

- (void)testThatItCreatesIntegrationNetworkPath {
    XCTAssertTrue([[self.servicePathFactory integrationNetworksServicePathFormat] isEqualToString:@"api/enterprise/integration/%@/networks"]);
}

- (void)testThatItCreatesIntegrationSitesPath {
    XCTAssertTrue([[self.servicePathFactory integrationSitesServicePathFormat] isEqualToString:@"api/enterprise/integration/%@/networks/%@/sites"]);
}

- (void)testThatItCreatesIntegrationSiteContentPath {
    XCTAssertTrue([[self.servicePathFactory integrationSiteContentServicePathFormat] isEqualToString:@"api/enterprise/integration/%@/networks/%@/sites/%@/content"]);
}

- (void)testThatItCreatesIntegrationFolderContentPath {
    XCTAssertTrue([[self.servicePathFactory integrationFolderContentServicePathFormat] isEqualToString:@"api/enterprise/integration/%@/networks/%@/folders/%@/content"]);
}

- (void)testThatItCreatesIntegrationContentUploadPath {
    XCTAssertTrue([[self.servicePathFactory integrationContentUploadServicePath] isEqualToString:@"api/enterprise/content"]);
}

- (void)testThatItCreatesIntegrationContentUploadForTaskPath {
    XCTAssertTrue([[self.servicePathFactory integrationContentUploadForTaskServicePathFormat] isEqualToString:@"api/enterprise/tasks/%@/content?isRelatedContent=true"]);
}

@end
