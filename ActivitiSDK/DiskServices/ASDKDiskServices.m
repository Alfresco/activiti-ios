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

#import "ASDKDiskServices.h"
#import "ASDKModelContent.h"
#import "ASDKDiskServicesConstants.h"
#import "ASDKLogConfiguration.h"
#import <MobileCoreServices/MobileCoreServices.h>


#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const int activitiSDKLogLevel = ASDK_LOG_LEVEL_VERBOSE; // | ASDK_LOG_FLAG_TRACE;

@implementation ASDKDiskServices


#pragma mark -
#pragma mark Public interface

- (NSString *)downloadPathForContent:(ASDKModelContent *)content {
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = documentsPaths.firstObject;
    NSString *contentPath = [[[[documentsPath stringByAppendingPathComponent:kASDKNamePath]
                               stringByAppendingPathComponent:kASDKDownloadedContentPath]
                              stringByAppendingPathComponent:content.modelID]
                             stringByAppendingPathComponent:content.contentName];
    
    return contentPath;
}

- (NSString *)downloadPathForContentThumbnail:(ASDKModelContent *)content {
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = documentsPaths.firstObject;
    NSString *contentPath = [[[[[documentsPath stringByAppendingPathComponent:kASDKNamePath]
                                stringByAppendingPathComponent:kASDKDownloadedContentPath]
                               stringByAppendingPathComponent:content.modelID]
                              stringByAppendingPathComponent:kASDKDownloadedThumbnailContentPath]
                             stringByAppendingPathComponent:[content.contentName stringByDeletingPathExtension]];
    
    return contentPath;
}

- (NSString *)downloadPathForResourceWithIdentifier:(NSString *)resourceID
                                           filename:(NSString *)filename {
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = documentsPaths.firstObject;
    NSString *contentPath = [[[[documentsPath stringByAppendingPathComponent:kASDKNamePath]
                               stringByAppendingPathComponent:kASDKDownloadedContentPath]
                              stringByAppendingPathComponent:resourceID]
                             stringByAppendingPathComponent:filename];
    
    return contentPath;
}

- (BOOL)doesFileAlreadyExistsForContent:(ASDKModelContent *)content {
    NSString *downloadPathForContent = [self downloadPathForContent:content];
    BOOL doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:downloadPathForContent];
    
    if (!doesFileExist) {
        [self createIntermediateDirectoryStructureForPath:downloadPathForContent];
    }
    
    return doesFileExist;
}

- (BOOL)doesThumbnailAlreadyExistsForContent:(ASDKModelContent *)content {
    NSString *downloadPathForThumbnail = [self downloadPathForContentThumbnail:content];
    BOOL doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:downloadPathForThumbnail];
    
    if (!doesFileExist) {
        [self createIntermediateDirectoryStructureForPath:downloadPathForThumbnail];
    }
    
    return doesFileExist;
}

- (BOOL)doesFileAlreadyExistsForResouceWithIdentifier:(NSString *)resourceID
                                             filename:(NSString *)filename {
    NSString *downloadPathForContent = [self downloadPathForResourceWithIdentifier:resourceID
                                                                          filename:filename];
    BOOL doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:downloadPathForContent];
    
    if (!doesFileExist) {
        NSError *error = nil;
        // Make sure we create the directory structure needed for the download
        [[NSFileManager defaultManager] createDirectoryAtPath:[downloadPathForContent stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            ASDKLogError(@"Encountered an error while generating the folder structure for resource with path :%@. Reason:%@", downloadPathForContent, error.localizedDescription);
        }
    }
    
    return doesFileExist;
}

- (NSUInteger)sizeOfFileAtPath:(NSString *)filePath {
    NSError *error = nil;
    NSUInteger fileSize = (NSUInteger)[[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error] fileSize];
    
    if (error) {
        ASDKLogError(@"An error occured while trying to get the size for file at path:%@", filePath);
    }
    
    return fileSize;
}

- (NSString *)sizeStringForByteCount:(long long)byteCount {
    double convertedValue = byteCount;
    int multiplyFactor = 0;
    
    NSArray *tokens = @[@"bytes",@"KB",@"MB",@"GB",@"TB"];
    
    while (convertedValue >= 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, tokens[multiplyFactor]];
}

+ (NSString *)generateFilenameForFileWithMIMEType:(NSString *)mimeType {
    // Get an extension for a UTI
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(mimeType), NULL);
    CFStringRef extension = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
    CFRelease(uti);
    
    NSString *filename = [NSString stringWithFormat:@"%@.%@", [self userDefaultsFilenameIncrementedValue], extension];
    CFRelease(extension);
    
    return filename;
}

+ (NSString *)mimeTypeByGuessingFromData:(NSData *)data {
    char bytes[12] = {0};
    [data getBytes:&bytes length:12];
    
    const char bmp[2] = {'B', 'M'};
    const char gif[3] = {'G', 'I', 'F'};
    const char jpg[3] = {0xff, 0xd8, 0xff};
    const char psd[4] = {'8', 'B', 'P', 'S'};
    const char iff[4] = {'F', 'O', 'R', 'M'};
    const char webp[4] = {'R', 'I', 'F', 'F'};
    const char ico[4] = {0x00, 0x00, 0x01, 0x00};
    const char tif_ii[4] = {'I','I', 0x2A, 0x00};
    const char tif_mm[4] = {'M','M', 0x00, 0x2A};
    const char png[8] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};
    const char jp2[12] = {0x00, 0x00, 0x00, 0x0c, 0x6a, 0x50, 0x20, 0x20, 0x0d, 0x0a, 0x87, 0x0a};
    
    
    if (!memcmp(bytes, bmp, 2)) {
        return @"image/x-ms-bmp";
    } else if (!memcmp(bytes, gif, 3)) {
        return @"image/gif";
    } else if (!memcmp(bytes, jpg, 3)) {
        return @"image/jpeg";
    } else if (!memcmp(bytes, psd, 4)) {
        return @"image/psd";
    } else if (!memcmp(bytes, iff, 4)) {
        return @"image/iff";
    } else if (!memcmp(bytes, webp, 4)) {
        return @"image/webp";
    } else if (!memcmp(bytes, ico, 4)) {
        return @"image/vnd.microsoft.icon";
    } else if (!memcmp(bytes, tif_ii, 4) || !memcmp(bytes, tif_mm, 4)) {
        return @"image/tiff";
    } else if (!memcmp(bytes, png, 8)) {
        return @"image/png";
    } else if (!memcmp(bytes, jp2, 12)) {
        return @"image/jp2";
    }
    
    return @"application/octet-stream"; // default type
    
}

+ (void)deleteLocalData {
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = documentsPaths.firstObject;
    NSString *contentPath = [[documentsPath stringByAppendingPathComponent:kASDKNamePath]
                             stringByAppendingPathComponent:kASDKDownloadedContentPath];
    
    // Clear downloaded content
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager isDeletableFileAtPath:contentPath]) {
        [fileManager removeItemAtPath:contentPath
                                error:&error];
        if (error) {
            ASDKLogError(@"Cannot delete local content cached data. Reason:%@", error.localizedDescription);
        }
    } else {
        ASDKLogWarn(@"There is no content to be deleted or cannot delete local cached data due to privilege issues.");
    }
    
    // Clear cached logs
    DDFileLogger *fileLogger = nil;
    error = nil;
    for (id logger in [DDLog allLoggers]) {
        if ([logger isKindOfClass:[DDFileLogger class]]) {
            fileLogger = logger;
            break;
        }
    }
    
    [fileLogger rollLogFileWithCompletionBlock:^{
        NSArray *paths = [fileLogger.logFileManager unsortedLogFileInfos];
        for( DDLogFileInfo *logFileInfo in paths ){
            if (logFileInfo.isArchived) {
                [[NSFileManager defaultManager] removeItemAtPath:logFileInfo.filePath
                                                           error:nil];
                [logFileInfo reset];
                ASDKLogVerbose(@"Deleting log file: %@", logFileInfo.filePath);
            }
        }
    }];
}

+ (NSString *)remainingDiskSpaceOnThisDevice {
    NSString *remainingSpace = nil;
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory()
                                                                                       error:&error];
    if (error) {
        ASDKLogWarn(@"Unable to retrieve attributes of root file path for computing the available disk space. Reason:%@", error.localizedDescription);
    }
    
    if (attributes) {
        long long freeSpaceSize = [attributes[NSFileSystemFreeSize] longLongValue];
        remainingSpace = [NSByteCountFormatter stringFromByteCount:freeSpaceSize
                                                        countStyle:NSByteCountFormatterCountStyleFile];
    }
    return remainingSpace;
}

+ (NSString *)usedDiskSpaceForDownloads {
    NSString *usedSpace = nil;
    NSError *error = nil;
    
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = documentsPaths.firstObject;
    NSString *contentPath = [[documentsPath stringByAppendingPathComponent:kASDKNamePath]
                             stringByAppendingPathComponent:kASDKDownloadedContentPath];
    
    NSArray *folderContents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:contentPath
                                                                                  error:&error];
    __block unsigned long long int folderSize = 0;
    
    [folderContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[contentPath stringByAppendingPathComponent:obj]
                                                                                        error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }];
    
    if (error) {
        ASDKLogWarn(@"Unable to retrieve attributes for downloads file path for computing the used disk space. Reason:%@", error.localizedDescription);
    }
    
    usedSpace = [NSByteCountFormatter stringFromByteCount:folderSize
                                               countStyle:NSByteCountFormatterCountStyleFile];
    
    return usedSpace;
}


#pragma mark -
#pragma mark Private interface

+ (NSString *)userDefaultsFilenameIncrementedValue {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastFileNameUsed = [userDefaults objectForKey:kASDKFilenameGeneratorLastValueUsed];
    
    if (!lastFileNameUsed) {
        lastFileNameUsed = [NSString stringWithFormat:kASDKFilenameGeneratorFormat, (long)0];
    }
    
    NSInteger lastFileCount = [[[lastFileNameUsed componentsSeparatedByString:@"_"] lastObject] integerValue];
    lastFileCount += 1;
    
    lastFileNameUsed = [NSString stringWithFormat:kASDKFilenameGeneratorFormat, (long)lastFileCount];
    
    [userDefaults setObject:lastFileNameUsed
                     forKey:kASDKFilenameGeneratorLastValueUsed];
    [userDefaults synchronize];
    
    return lastFileNameUsed;
}

- (void)createIntermediateDirectoryStructureForPath:(NSString *)path {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error) {
        ASDKLogError(@"Encountered an error while generating the folder structure for content with path :%@. Reason:%@", path, error.localizedDescription);
    }
}

@end
