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

#import "ASDKNetworkProxyBaseTest.h"
#import "ASDKModelFormPreProcessorResponse.h"
#import "ASDKFormDataAccessor.h"

typedef void (^ASDKFormDescriptionCompletionBlock) (ASDKModelFormDescription *formDescription, NSError *error);
typedef NS_ENUM(NSInteger, ASDKFormPreProcessorTestType) {
    ASDKFormPreProcessorTestTypeNoProcessing,
    ASDKFormPreProcessorTestTypeAmountHyperlink,
    ASDKFormPreProcessorTestTypeDropdown,
    ASDKFormPreProcessorTestTypeDropdownDynamicTable
};


@interface ASDKFormDataAccessorMock : ASDKBaseTest <NSCopying>

@property (weak, nonatomic) id<ASDKDataAccessorDelegate> delegate;

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate;
- (void)fetchRestFieldValuesForTaskID:(NSString *)taskID
                      withFormFieldID:(NSString *)fieldID;
- (void)fetchRestFieldValuesForTaskID:(NSString *)taskID
                      withFormFieldID:(NSString *)fieldID
                         withColumnID:(NSString *)columnID;
- (void)fetchFormVariablesForTaskID:(NSString *)taskID;

@end

@implementation ASDKFormDataAccessorMock

- (instancetype)initWithDelegate:(id<ASDKDataAccessorDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ASDKFormDataAccessorMock *copy = [[ASDKFormDataAccessorMock alloc] initWithDelegate:self.delegate];
    return copy;
}

- (void)fetchRestFieldValuesForTaskID:(NSString *)taskID
                      withFormFieldID:(NSString *)fieldID {
    if (self.delegate) {
        ASDKDataAccessorResponseCollection *responseCollection =
        [[ASDKDataAccessorResponseCollection alloc] initWithCollection:[self jSONRestFieldValuesFromJSON:@"TaskFormRestFieldValuesResponse"]
                                                          isCachedData:NO
                                                                 error:nil];
        
        [self.delegate dataAccessor:(id<ASDKServiceDataAccessorProtocol>)self
                didLoadDataResponse:responseCollection];
    }
}

- (void)fetchRestFieldValuesForTaskID:(NSString *)taskID
                      withFormFieldID:(NSString *)fieldID
                         withColumnID:(NSString *)columnID {
    if (self.delegate) {
        ASDKDataAccessorResponseCollection *responseCollection =
        [[ASDKDataAccessorResponseCollection alloc] initWithCollection:[self jSONRestFieldValuesFromJSON:@"TaskFormRestFieldValuesResponse"]
                                                          isCachedData:NO
                                                                 error:nil];
        
        [self.delegate dataAccessor:(id<ASDKServiceDataAccessorProtocol>)self
                didLoadDataResponse:responseCollection];
    }
}

- (void)fetchFormVariablesForTaskID:(NSString *)taskID {
    if (self.delegate) {
        ASDKDataAccessorResponseCollection *responseCollection =
        [[ASDKDataAccessorResponseCollection alloc] initWithCollection:[self jSONRestFieldValuesFromJSON:@"TaskFormRestFieldValuesResponse"]
                                                          isCachedData:NO
                                                                 error:nil];
        
        [self.delegate dataAccessor:(id<ASDKServiceDataAccessorProtocol>)self
                didLoadDataResponse:responseCollection];
    }
}

- (NSArray *)jSONRestFieldValuesFromJSON:(NSString *)jsonFilename {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t processingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue", [NSBundle mainBundle].bundleIdentifier, NSStringFromClass([self class])] UTF8String], DISPATCH_QUEUE_SERIAL);
    
    __block NSArray *restFieldValues = nil;
    NSDictionary *formDescriptionResponse = [self contentDictionaryFromJSON:jsonFilename];
    
    dispatch_group_enter(group);
    
    ASDKTaskFormParserOperationWorker *taskFormParserWorker = [ASDKTaskFormParserOperationWorker new];
    [taskFormParserWorker
     parseContentDictionary:formDescriptionResponse
     ofType:CREATE_STRING(ASDKTaskFormParserContentTypeRestFieldValues)
     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
         restFieldValues = (NSArray *)parsedObject;
         dispatch_group_leave(group);
     } queue:processingQueue];
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    return restFieldValues;
}

@end


@interface ASDKFormPreProcessorMock : ASDKFormPreProcessor

@property (strong, nonatomic) ASDKFormDataAccessorMock *fetchRestFieldValuesForTaskFormDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessorMock *fetchRestFieldValuesForDynamicTableInTaskFormDataAccessor;
@property (strong, nonatomic) ASDKFormDataAccessorMock *fetchFormVariablesDataAccessor;

@end

@implementation ASDKFormPreProcessorMock

- (void)setFetchRestFieldValuesForTaskFormDataAccessor:(ASDKFormDataAccessor *)fetchRestFieldValuesForTaskFormDataAccessor {
    _fetchRestFieldValuesForTaskFormDataAccessor = [[ASDKFormDataAccessorMock alloc] initWithDelegate:fetchRestFieldValuesForTaskFormDataAccessor.delegate];
}

- (void)setFetchRestFieldValuesForDynamicTableInTaskFormDataAccessor:(ASDKFormDataAccessorMock *)fetchRestFieldValuesForDynamicTableInTaskFormDataAccessor {
    _fetchRestFieldValuesForDynamicTableInTaskFormDataAccessor = [[ASDKFormDataAccessorMock alloc] initWithDelegate:fetchRestFieldValuesForDynamicTableInTaskFormDataAccessor.delegate];
}

- (void)setFetchFormVariablesDataAccessor:(ASDKFormDataAccessor *)fetchFormVariablesDataAccessor {
    _fetchFormVariablesDataAccessor = [[ASDKFormDataAccessorMock alloc] initWithDelegate:fetchFormVariablesDataAccessor.delegate];
}

@end


@interface ASDKFormPreProcessorTest : ASDKNetworkProxyBaseTest <ASDKFormPreProcessorDelegate>

@property (strong, nonatomic) ASDKFormPreProcessorMock          *formPreProcessorMock;
@property (strong, nonatomic) ASDKTaskFormParserOperationWorker *taskFormParserWorker;

@property (assign, nonatomic) ASDKFormPreProcessorTestType      formPreProcessorTestType;
@property (strong, nonatomic) XCTestExpectation                 *taskFormFieldsExpectationNoProcessing;
@property (strong, nonatomic) XCTestExpectation                 *taskFormFieldExpectationAmountHyperlinkFields;
@property (strong, nonatomic) XCTestExpectation                 *taskFormFieldExpectationDropdown;
@property (strong, nonatomic) XCTestExpectation                 *taskFormFieldExpectationDropdownInDynamicTable;
@property (strong, nonatomic) NSArray                           *formFieldsWithNoProcessing;


@end

@implementation ASDKFormPreProcessorTest

- (void)setUp {
    [super setUp];
    self.taskFormParserWorker = [ASDKTaskFormParserOperationWorker new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItProcessesFormFieldsInTaskFormThatDontRequireProcessing {
    // given
    self.formPreProcessorTestType = ASDKFormPreProcessorTestTypeNoProcessing;
    ASDKModelFormDescription *formDescription = [self formFieldDescriptionFromJSON:@"TaskAllFieldsFormResponse"];
    NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject:formDescription.formFields];
    self.formFieldsWithNoProcessing = [NSKeyedUnarchiver unarchiveObjectWithData:buffer];
    
    // expect
    self.taskFormFieldsExpectationNoProcessing = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    self.formPreProcessorMock = [[ASDKFormPreProcessorMock alloc] initWithDelegate:self];
    [self.formPreProcessorMock setupWithTaskID:OCMOCK_ANY
                            withFormFields:formDescription.formFields
                   withDynamicTableFieldID:nil];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItProcessesDropdownFormFieldWithRestURL {
    // given
    self.formPreProcessorTestType = ASDKFormPreProcessorTestTypeDropdown;
    ASDKModelFormDescription *formDescription = [self formFieldDescriptionFromJSON:@"FormDropdownWithRestURLResponse"];
    
    // expect
    self.taskFormFieldExpectationDropdown = [self expectationWithDescription:[NSString stringWithFormat:@"%@.processDropdownFormField", NSStringFromSelector(_cmd)]];
    
    // when
    self.formPreProcessorMock = [[ASDKFormPreProcessorMock alloc] initWithDelegate:self];
    [self.formPreProcessorMock setupWithTaskID:OCMOCK_ANY
                                withFormFields:formDescription.formFields
                       withDynamicTableFieldID:nil];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItProcessesDropdownFormFieldWithRestURLInDynamicTable {
    self.formPreProcessorTestType = ASDKFormPreProcessorTestTypeDropdownDynamicTable;
    ASDKModelFormDescription *formDescription = [self formFieldDescriptionFromJSON:@"FormDropdownWithRestURLResponse"];
    
    // expect
    self.taskFormFieldExpectationDropdownInDynamicTable = [self expectationWithDescription:[NSString stringWithFormat:@"%@.processDropdownFormFieldInDynamicTable", NSStringFromSelector(_cmd)]];
    
    // when
    self.formPreProcessorMock = [[ASDKFormPreProcessorMock alloc] initWithDelegate:self];
    NSArray *dynamicTableColumnDefinitions = [(ASDKModelDynamicTableFormField *)formDescription.formFields.lastObject columnDefinitions];
    [self.formPreProcessorMock setupWithTaskID:OCMOCK_ANY
                                withFormFields:dynamicTableColumnDefinitions
                       withDynamicTableFieldID:OCMOCK_ANY];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

//- (void)testThatItProcessesDropdownFormFieldWithRestURL {
//    // given
//    ASDKModelFormDescription *formDescription = [self formFieldDescriptionFromJSON:@"FormDropdownWithRestURLResponse"];
//
//    [[[self.requestOperationManagerMock stub] andDo:^(NSInvocation *invocation) {
//        ASDKTestRequestSuccessBlock successBlock;
//        NSUInteger successBlockParameterIdxInMethodSignature = 5;
//        [invocation getArgument:&successBlock
//                        atIndex:successBlockParameterIdxInMethodSignature];
//        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
//        [invocation setReturnValue:&dataTask];
//
//        successBlock(dataTask, [self contentDictionaryFromJSON:@"TaskFormRestFieldValuesResponse"]);
//    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
//
//    self.formNetworkService.requestOperationManager = self.requestOperationManagerMock;
//    self.formPreProcessor.formNetworkServices = self.formNetworkService;
//
//    // expect
//    XCTestExpectation *dropdownFormFieldExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.processDropdownFormField", NSStringFromSelector(_cmd)]];
//    XCTestExpectation *dropdownFormFieldInDynamicTableExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.processDropdownFormFieldInDynamicTable", NSStringFromSelector(_cmd)]];
//
//    // when
//    [self.formPreProcessor setupWithTaskID:OCMOCK_ANY
//                            withFormFields:formDescription.formFields
//                   withDynamicTableFieldID:nil
//                 preProcessCompletionBlock:^(NSArray *formFields, NSError *error) {
//                     ASDKModelFormField *dropDownFormField = [[(ASDKModelFormField *)formFields.firstObject formFields] firstObject];
//
//                     XCTAssert(dropDownFormField.formFieldOptions.count == 10);
//                     XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions.firstObject name] isEqualToString:@"Leanne Graham"]);
//                     XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions.firstObject modelID] isEqualToString:@"1"]);
//                     XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions[9] name] isEqualToString:@"Clementina DuBuque"]);
//                     XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions[9] modelID] isEqualToString:@"10"]);
//
//                     [dropdownFormFieldExpectation fulfill];
//                 }];
//
//    NSArray *dynamicTableColumnDefinitions = [(ASDKModelDynamicTableFormField *)formDescription.formFields.lastObject columnDefinitions];
//    [self.formPreProcessor setupWithTaskID:OCMOCK_ANY
//                            withFormFields:dynamicTableColumnDefinitions
//                   withDynamicTableFieldID:OCMOCK_ANY
//                 preProcessCompletionBlock:^(NSArray *formFields, NSError *error) {
//                     ASDKModelFormField *dropDownFormField = (ASDKModelFormField *)formFields.firstObject;
//
//                     XCTAssert(dropDownFormField.formFieldOptions.count == 10);
//                     XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions.firstObject name] isEqualToString:@"Leanne Graham"]);
//                     XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions.firstObject modelID] isEqualToString:@"1"]);
//                     XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions[9] name] isEqualToString:@"Clementina DuBuque"]);
//                     XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions[9] modelID] isEqualToString:@"10"]);
//
//                     [dropdownFormFieldInDynamicTableExpectation fulfill];
//                 }];
//
//    [self waitForExpectationsWithTimeout:.5f
//                                 handler:nil];
//}

- (void)testThatItProcessesTaskReadonlyAmountAndHyperlinkFields {
    // given
    self.formPreProcessorTestType = ASDKFormPreProcessorTestTypeAmountHyperlink;
    ASDKModelFormDescription *formDescription = [self formFieldDescriptionFromJSON:@"FormReadOnlyAmountFieldAndHyperLinkResponse"];
    
    // expect
    self.taskFormFieldExpectationAmountHyperlinkFields = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    // when
    self.formPreProcessorMock = [[ASDKFormPreProcessorMock alloc] initWithDelegate:self];
    [self.formPreProcessorMock setupWithTaskID:OCMOCK_ANY
                            withFormFields:formDescription.formFields
                   withDynamicTableFieldID:nil];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (ASDKModelFormDescription *)formFieldDescriptionFromJSON:(NSString *)jsonFilename {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t processingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.`%@ProcessingQueue", [NSBundle mainBundle].bundleIdentifier, NSStringFromClass([self class])] UTF8String], DISPATCH_QUEUE_SERIAL);
    
    __block ASDKModelFormDescription *formDescription = nil;
    NSDictionary *formDescriptionResponse = [self contentDictionaryFromJSON:jsonFilename];
    
    dispatch_group_enter(group);
    
    [self.taskFormParserWorker
     parseContentDictionary:formDescriptionResponse
     ofType:CREATE_STRING(ASDKTaskFormParserContentTypeFormModels)
     withCompletionBlock:^(id parsedObject, NSError *error, ASDKModelPaging *paging) {
         formDescription = (ASDKModelFormDescription *)parsedObject;
         dispatch_group_leave(group);
     } queue:processingQueue];
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    return formDescription;
}


#pragma mark -
#pragma mark ASDKFormPreProcessorDelegate

- (void)didProcessedFormFieldsWithResponse:(ASDKModelFormPreProcessorResponse *)preProcessorResponse {
    if (ASDKFormPreProcessorTestTypeNoProcessing == self.formPreProcessorTestType) {
        [self handleFormPreprocessorNoProcessingResponse:preProcessorResponse];
    } else if (ASDKFormPreProcessorTestTypeAmountHyperlink == self.formPreProcessorTestType) {
        [self handleFormPreProcessorAmountHyperlinkResponse:preProcessorResponse];
    } else if (ASDKFormPreProcessorTestTypeDropdown == self.formPreProcessorTestType) {
        [self handleFormPreProcessorDropdownResponse:preProcessorResponse];
    } else if (ASDKFormPreProcessorTestTypeDropdownDynamicTable == self.formPreProcessorTestType) {
        [self handleFormPreProcessorDropdownDynamicTableResponse:preProcessorResponse];
    }
}

- (void)didProcessedCachedFormFieldsWithResponse:(ASDKModelFormPreProcessorResponse *)preProcessorResponse {
}


#pragma mark -
#pragma mark Response handlers

- (void)handleFormPreprocessorNoProcessingResponse:(ASDKModelFormPreProcessorResponse *)preProcessorResponse {
    if ([preProcessorResponse.processedFormFields isEqualToArray:self.formFieldsWithNoProcessing]) {
        [self.taskFormFieldsExpectationNoProcessing fulfill];
    }
}

- (void)handleFormPreProcessorAmountHyperlinkResponse:(ASDKModelFormPreProcessorResponse *)preProcessorResponse {
    NSArray *processedFormFields = preProcessorResponse.processedFormFields;
    
    ASDKModelAmountFormField *amountFormField = (ASDKModelAmountFormField *)[(ASDKModelFormField *)processedFormFields.firstObject formFields].firstObject;
    ASDKModelHyperlinkFormField *hyperlinkFormField = (ASDKModelHyperlinkFormField *)[(ASDKModelFormField *)processedFormFields.firstObject formFields].lastObject;
    
    XCTAssert([amountFormField.currency isEqualToString:@"$"]);
    XCTAssertTrue(amountFormField.enableFractions);
    
    XCTAssert([hyperlinkFormField.hyperlinkURL isEqualToString:@"http://www.alfresco.com"]);
    XCTAssert([hyperlinkFormField.displayText isEqualToString:@"Alfresco site"]);
    
    [self.taskFormFieldExpectationAmountHyperlinkFields fulfill];
}

- (void)handleFormPreProcessorDropdownResponse:(ASDKModelFormPreProcessorResponse *)preProcessorResponse {
    NSArray *formFields = preProcessorResponse.processedFormFields;
    ASDKModelFormField *dropDownFormField = [[(ASDKModelFormField *)formFields.firstObject formFields] firstObject];
    //
    XCTAssert(dropDownFormField.formFieldOptions.count == 10);
    XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions.firstObject name] isEqualToString:@"Leanne Graham"]);
    XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions.firstObject modelID] isEqualToString:@"1"]);
    XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions[9] name] isEqualToString:@"Clementina DuBuque"]);
    XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions[9] modelID] isEqualToString:@"10"]);
    
    [self.taskFormFieldExpectationDropdown fulfill];
}

- (void)handleFormPreProcessorDropdownDynamicTableResponse:(ASDKModelFormPreProcessorResponse *)preProcessorResponse {
    NSArray *formFields = preProcessorResponse.processedFormFields;
    ASDKModelFormField *dropDownFormField = (ASDKModelFormField *)formFields.firstObject;
    
    XCTAssert(dropDownFormField.formFieldOptions.count == 10);
    XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions.firstObject name] isEqualToString:@"Leanne Graham"]);
    XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions.firstObject modelID] isEqualToString:@"1"]);
    XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions[9] name] isEqualToString:@"Clementina DuBuque"]);
    XCTAssert([[(ASDKModelFormFieldOption *)dropDownFormField.formFieldOptions[9] modelID] isEqualToString:@"10"]);
    
    [self.taskFormFieldExpectationDropdownInDynamicTable fulfill];
}

@end
