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

@protocol ProtocolOne <NSObject>
@end

@protocol ProtocolTwo <NSObject>
@end

@interface MultipleDependencyService : NSObject <ProtocolOne, ProtocolTwo>
@end

@implementation MultipleDependencyService
@end

@interface NoDepedencyService : NSObject
@end

@implementation NoDepedencyService
@end

@interface ASDKServiceLocatorTest : ASDKBaseTest

@property (strong, nonatomic) ASDKServiceLocator *serviceLocator;

@end

@implementation ASDKServiceLocatorTest

- (void)setUp {
    [super setUp];
    
    self.serviceLocator = [ASDKServiceLocator new];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItAddsService {
    // given
    id internalService = OCMClassMock([ASDKNetworkService class]);
    
    // when
    [self.serviceLocator addService:internalService];
    
    // then
    XCTAssertEqual([self.serviceLocator registeredServices].count, 1);
}

- (void)testThatItValidatesRegisteredService {
    // given
    id internalService = OCMClassMock([ASDKNetworkService class]);
    
    // when
    [self.serviceLocator addService:internalService];
    
    // then
    XCTAssertTrue([self.serviceLocator isServiceRegistered:internalService]);
}

- (void)testThatItCannotConfirmRegisteredService {
    // given
    id internalService = OCMClassMock([ASDKFormRenderEngine class]);
    
    // then
    XCTAssertFalse([self.serviceLocator isServiceRegistered:internalService]);
}

- (void)testThatItValidatesRegisteredServiceForProtocol {
    // given
    id internalService = OCMClassMock([ASDKNetworkService class]);
    
    // when
    [self.serviceLocator addService:internalService];
    
    // then
    XCTAssertTrue([self.serviceLocator isServiceRegisteredForProtocol:@protocol(ASDKNetworkServiceProtocol)]);
}

- (void)testThatItRetrievesServiceConformingToCertainProtocol {
    // given
    id internalService = OCMClassMock([ASDKNetworkService class]);
    
    // when
    [self.serviceLocator addService:internalService];
    
    // then
    XCTAssertTrue(internalService == [self.serviceLocator serviceConformingToProtocol:@protocol(ASDKNetworkServiceProtocol)]);
}

- (void)testThatItRemovesServiceConformingToProtocol {
    // given
    id internalService = OCMClassMock([ASDKFormRenderEngine class]);
    
    // when
    [self.serviceLocator addService:internalService];
    [self.serviceLocator removeServiceConformingToProtocol:@protocol(ASDKFormRenderEngineProtocol)];
    
    // then
    XCTAssertTrue(!self.serviceLocator.registeredServices.count);
}

- (void)testThatItRemovesService {
    // given
    id internalService = OCMClassMock([ASDKFormRenderEngine class]);
    
    // when
    [self.serviceLocator addService:internalService];
    [self.serviceLocator removeService:internalService];
    
    // then
    XCTAssertTrue(!self.serviceLocator.registeredServices.count);
}

- (void)testThatItDoesntBreakSingleProtocolConformityRule {
    // given
    id internalService = OCMClassMock([MultipleDependencyService class]);
    
    // when
    [self.serviceLocator addService:internalService];
    
    // then
    XCTAssertTrue(!self.serviceLocator.registeredServices.count);
}

- (void)testThatItDoesNotRegisterServiceWithoutProtocolContract {
    // given
    id internalService = [NoDepedencyService new];
    
    // when
    [self.serviceLocator addService:internalService];
    
    // then
    XCTAssertTrue(!self.serviceLocator.registeredServices.count);
}

- (void)testThatItManagesMultiThreadedAccesAndRegistration {
    // given
    id internalService = OCMClassMock([ASDKFormRenderEngine class]);
    
    // when
    __weak typeof(self) weakSelf = self;
    for (NSInteger idx = 0; idx < 100; idx++) {
        XCTestExpectation *insertExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.insertExpectation", NSStringFromSelector(_cmd)]];
        XCTestExpectation *readExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.readExpectation", NSStringFromSelector(_cmd)]];
        XCTestExpectation *deleteExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@.deleteExpectation", NSStringFromSelector(_cmd)]];
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf.serviceLocator addService:internalService];
            [insertExpectation fulfill];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf.serviceLocator serviceConformingToProtocol:@protocol(ASDKFormRenderEngineProtocol)];
            [readExpectation fulfill];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            [strongSelf.serviceLocator removeService:internalService];
            [deleteExpectation fulfill];
        });
    }
    
    // then
    [self waitForExpectationsWithTimeout:1.0
                                 handler:nil];
}

@end
