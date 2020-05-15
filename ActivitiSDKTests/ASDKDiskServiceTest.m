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
@import ActivitiSDK.Private;

@interface ASDKDiskServiceTest : ASDKBaseTest

@property (strong, nonatomic) ASDKDiskServices *diskServices;
@property (strong, nonatomic) NSString *contentID;
@property (strong, nonatomic) NSString *contentName;

@end

@implementation ASDKDiskServiceTest

- (void)setUp {
    [super setUp];
    
    self.contentID = @"4000";
    self.contentName = @"file.png";
    self.diskServices = [ASDKDiskServices new];
    [ASDKDiskServices deleteLocalData];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItCreatesDownloadPathForContent {
    // given
    NSString *contentPath = [self documentsContentPathForContentIdentifier:self.contentID
                                                               contentName:self.contentName];
    id content = OCMPartialMock([ASDKModelContent new]);
    OCMStub([content modelID]).andReturn(self.contentID);
    OCMStub([content contentName]).andReturn(self.contentName);
    
    // when
    NSString *downloadPathForContent = [self.diskServices downloadPathForContent:content];
    
    // then
    XCTAssertTrue([contentPath isEqualToString:downloadPathForContent]);
}

- (void)testThatItCreatesDownloadPathForResourceWithIdentifier {
    // given
    NSString *contentPath = [self documentsContentPathForContentIdentifier:self.contentID
                                                               contentName:self.contentName];
    
    // when
    NSString *downloadPathForContent = [self.diskServices downloadPathForResourceWithIdentifier:self.contentID
                                                                                       filename:self.contentName];
    
    // then
    XCTAssertTrue([contentPath isEqualToString:downloadPathForContent]);
}

- (void)testThatItChecksForExistenceOfFileForContentModel {
    // given
    id content = OCMPartialMock([ASDKModelContent new]);
    OCMStub([content modelID]).andReturn(self.contentID);
    OCMStub([content contentName]).andReturn(self.contentName);
    
    // when
    if (![self createRandomFileInDocumentsDirectoryForContentID:self.contentID
                                                   contentName:self.contentName]) {
        XCTFail(@"%@ - An error occured while creating test file", NSStringFromSelector(_cmd));
    }
    
    // then
    XCTAssertTrue([self.diskServices doesFileAlreadyExistsForContent:content]);
}

- (void)testThatItChecksForAbsenceOfFileForContentModel {
    // given
    id content = OCMPartialMock([ASDKModelContent new]);
    OCMStub([content modelID]).andReturn(self.contentID);
    OCMStub([content contentName]).andReturn(self.contentName);
    
    // then
    XCTAssertFalse([self.diskServices doesFileAlreadyExistsForContent:content]);
}

- (void)testThatItChecksForExistenceOfContentIdentifierAndFilename {
    // when
    if (![self createRandomFileInDocumentsDirectoryForContentID:self.contentID
                                                    contentName:self.contentName]) {
        XCTFail(@"%@ - An error occured while creating test file", NSStringFromSelector(_cmd));
    }
    
    // then
    XCTAssertTrue([self.diskServices doesFileAlreadyExistsForResouceWithIdentifier:self.contentID
                                                                          filename:self.contentName]);
}

- (void)testThatItChecksForAbscenceOfContentIdentifierAndFilename {
    XCTAssertFalse([self.diskServices doesFileAlreadyExistsForResouceWithIdentifier:self.contentID
                                                                           filename:self.contentName]);
}

- (void)testThatItReturnsCorrectSizeOfFileAtPath {
    // given
    id content = OCMPartialMock([ASDKModelContent new]);
    OCMStub([content modelID]).andReturn(self.contentID);
    OCMStub([content contentName]).andReturn(self.contentName);
    NSString *contentPath = [self documentsContentPathForContentIdentifier:self.contentID
                                                               contentName:self.contentName];
    
    // when
    if (![self createRandomFileInDocumentsDirectoryForContentID:self.contentID
                                                    contentName:self.contentName]) {
        XCTFail(@"%@ - An error occured while creating test file", NSStringFromSelector(_cmd));
    }
    
    // then
    XCTAssertEqual([self.diskServices sizeOfFileAtPath:contentPath], 1024);
}

- (void)testThatItGuessesMimeTypeFromRandomData {
    // given
    NSData *randomData = [self createRandomNSDataOfSize:1024];
    
    // then
    XCTAssertTrue([[ASDKDiskServices mimeTypeByGuessingFromData:randomData] isEqualToString:@"application/octet-stream"]);
}

- (void)testThatItGuessesMimeTypeFromPNGData {
    // given
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"alfresco-icon" ofType:@"png"];
    
    // when
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    
    // then
    XCTAssertTrue([[ASDKDiskServices mimeTypeByGuessingFromData:imageData] isEqualToString:@"image/png"]);
}

- (void)testThatItGuessesMimeTypeFromJPGData {
    //given
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"alfresco-icon" ofType:@"jpg"];
    
    // when
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    
    // then
    XCTAssertTrue([[ASDKDiskServices mimeTypeByGuessingFromData:imageData] isEqualToString:@"image/jpeg"]);
}

- (void)testThatItDeletesLocalData {
    // given
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = documentsPaths.firstObject;
    NSString *contentPath = [[documentsPath stringByAppendingPathComponent:kASDKNamePath]
                             stringByAppendingPathComponent:kASDKDownloadedContentPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // when
    if (![self createRandomFileInDocumentsDirectoryForContentID:self.contentID
                                                    contentName:self.contentName]) {
        XCTFail(@"%@ - An error occured while creating test file", NSStringFromSelector(_cmd));
    }
    [ASDKDiskServices deleteLocalData];
    
    // then
    XCTAssertFalse([fileManager fileExistsAtPath:contentPath]);
}

- (void)testThatItCalculatesUsedDiskSpaceForDownloads {
    // when
    [self createRandomFileInDocumentsDirectoryForContentID:self.contentID
                                               contentName:self.contentName];
    
    // then
    NSString *usedDiskSpace = [ASDKDiskServices usedDiskSpaceForDownloads];
    XCTAssertTrue([usedDiskSpace isEqualToString:@"1 KB"]);
}

- (void)testThatItCreatesSizeStringForByteCount {
    XCTAssertTrue([[self.diskServices sizeStringForByteCount:1024] isEqualToString:@"1.00 KB"]);
}

- (void)testThatItGeneratesFilenameForFileWithMIMEType {
    // given
    NSString *mimeType = @"image/jpeg";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSString stringWithFormat:kASDKFilenameGeneratorFormat, (long)0]
                     forKey:kASDKFilenameGeneratorLastValueUsed];
    
    // when
    NSString *filenameIncrementedValueForMimeType = [ASDKDiskServices generateFilenameForFileWithMIMEType:mimeType];
    
    XCTAssertTrue([filenameIncrementedValueForMimeType isEqualToString:@"File_001.jpeg"]);
}


#pragma mark -
#pragma mark Utils

- (NSString *)documentsContentPathForContentIdentifier:(NSString *)contentID
                                           contentName:(NSString *)contentName {
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = documentsPaths.firstObject;
    return [[[[documentsPath stringByAppendingPathComponent:kASDKNamePath]
              stringByAppendingPathComponent:kASDKDownloadedContentPath]
             stringByAppendingPathComponent:contentID]
            stringByAppendingPathComponent:contentName];
}

- (BOOL)createRandomFileInDocumentsDirectoryForContentID:(NSString *)contentID
                                             contentName:(NSString *)contentName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *randomData = [self createRandomNSDataOfSize:1024];
    NSString *contentPath = [self documentsContentPathForContentIdentifier:contentID
                                                               contentName:contentName];
    
    NSError *error = nil;
    [fileManager createDirectoryAtPath:[contentPath stringByDeletingLastPathComponent]
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
    if (!error) {
        [randomData writeToFile:contentPath
                     atomically:NO];
        return YES;
    }
    
    return NO;
}

@end
