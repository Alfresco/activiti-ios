/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile iOS App.
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

@import UIKit;
#import "AFAThumbnailManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIImage+AFAThumbnailCreation.h"
#import "AFALogConfiguration.h"

static const int activitiLogLevel = AFA_LOG_LEVEL_VERBOSE; // | AFA_LOG_FLAG_TRACE;
static NSString * const cachedThumbnailsPath = @"CachedThumbnails";

@interface AFAThumbnailManager ()

@property (strong, nonatomic) NSCache           *imageCache;
@property (strong, nonatomic) dispatch_queue_t  imageProcessingQueue;
@property (strong, nonatomic) dispatch_queue_t  ioProcessingQueue;
@property (strong, nonatomic) UIImage           *placeholderThumbnailImage;

@end

@implementation AFAThumbnailManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc] init];
        self.imageCache.name = [NSString stringWithFormat:@"%@.thumbnailsCache", [NSBundle mainBundle].bundleIdentifier];
        self.imageProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.thumbnailsProcessingQueue", [NSBundle mainBundle].bundleIdentifier] UTF8String], DISPATCH_QUEUE_SERIAL);
        self.ioProcessingQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@.thumbnailsIOProcessingQueue", [NSBundle mainBundle].bundleIdentifier] UTF8String], DISPATCH_QUEUE_SERIAL);
        self.placeholderThumbnailImage = [UIImage imageNamed:@"image-placeholder-icon"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanupMemoryCache)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}


#pragma mark -
#pragma mark Public interface

- (UIImage *)thumbnailForImage:(UIImage *)largeImage
                      withSize:(CGFloat)imageSize {
    return [UIImage createThumbnailForImage:largeImage
                                   withSize:imageSize];
}

- (UIImage *)thumbnailForImage:(UIImage *)largeImage
                withIdentifier:(NSString *)imageIdentifier
                      withSize:(CGFloat)imageSize
     processingCompletionBlock:(AFAThumbnailProcessingCompletionBlock)completionBlock {
    UIImage *cachedImage = nil;
    if (largeImage) {
        cachedImage = [self.imageCache objectForKey:imageIdentifier];
        
        // Check if the thumbnail for the large image has the same
        // data as the cached image and if that's the case cache
        // the new image data
        if (cachedImage) {
            // If the image has an alpha channel, we will consider it PNG to avoid losing the transparency
            int cachedImageAlphaInfo = CGImageGetAlphaInfo(cachedImage.CGImage);
            BOOL cachedImageHasAlpha = !(cachedImageAlphaInfo == kCGImageAlphaNone ||
                                         cachedImageAlphaInfo == kCGImageAlphaNoneSkipFirst ||
                                         cachedImageAlphaInfo == kCGImageAlphaNoneSkipLast);
            
            int largeImageAlphaInfo = CGImageGetAlphaInfo(largeImage.CGImage);
            BOOL largeImageHasAlpha = !(largeImageAlphaInfo == kCGImageAlphaNone ||
                                        largeImageAlphaInfo == kCGImageAlphaNoneSkipFirst ||
                                        largeImageAlphaInfo == kCGImageAlphaNoneSkipLast);
            
            // If one image is a different type than the other re-cache the image
            if ((cachedImageHasAlpha && largeImageHasAlpha) ||
                (!cachedImageHasAlpha && !largeImageHasAlpha)) {
                __weak typeof(self) weakSelf = self;
                
                dispatch_async(self.imageProcessingQueue, ^{
                    __strong typeof(self) strongSelf = weakSelf;
                    
                    UIImage *thumbnailImageForLargeImage = [strongSelf thumbnailForImage:largeImage
                                                                                withSize:imageSize];
                    
                    // If the images are PNGs then compara their specific PNG data
                    if (cachedImageHasAlpha && largeImageHasAlpha) {
                        NSData *cachedImageData = UIImagePNGRepresentation(cachedImage);
                        NSData *largeImageData = UIImagePNGRepresentation(thumbnailImageForLargeImage);
                        if (cachedImageData.length != largeImageData.length) {
                            [self storeImage:thumbnailImageForLargeImage
                                      forKey:imageIdentifier];
                            [self cacheImageToDisk:thumbnailImageForLargeImage
                                     forIdentifier:imageIdentifier];
                            completionBlock(thumbnailImageForLargeImage);
                        }
                    }
                    
                    if (!cachedImageHasAlpha && !largeImageHasAlpha) {
                        NSData *cachedImageData = UIImageJPEGRepresentation(cachedImage, 1.0f);
                        NSData *largeImageData = UIImageJPEGRepresentation(thumbnailImageForLargeImage, 1.0f);
                        
                        if (cachedImageData.length != largeImageData.length) {
                            [self storeImage:thumbnailImageForLargeImage
                                      forKey:imageIdentifier];
                            [self cacheImageToDisk:thumbnailImageForLargeImage
                                     forIdentifier:imageIdentifier];
                            completionBlock(thumbnailImageForLargeImage);
                        }
                    }
                });
            }
        } else {
            cachedImage = self.placeholderThumbnailImage;
            
            if (completionBlock) {
                __weak typeof(self) weakSelf = self;
                dispatch_async(self.imageProcessingQueue, ^{
                    __strong typeof(self) strongSelf = weakSelf;
                    
                    if (strongSelf) {
                        UIImage *processedImage = [strongSelf thumbnailForImage:largeImage
                                                                       withSize:imageSize];
                        [self storeImage:processedImage
                                  forKey:imageIdentifier];
                        [self cacheImageToDisk:processedImage
                                 forIdentifier:imageIdentifier];
                        
                        completionBlock(processedImage);
                    }
                });
            }
        }
    }
    
    return cachedImage;
}

- (UIImage *)thumbnailImageForIdentifier:(NSString *)imageIdentifier {
    UIImage *thumbnailImage = [self cachedImageForForKey:imageIdentifier];
    
    if (!thumbnailImage) {
        thumbnailImage = [self cachedDiskImageForIdentifier:imageIdentifier];
    }
    
    if (!thumbnailImage) {
        thumbnailImage = self.placeholderThumbnailImage;
    }
    
    return thumbnailImage;
}

- (void)cleanupMemoryCache {
    [self.imageCache removeAllObjects];
}


#pragma mark -
#pragma mark Private interface

- (void)storeImage:(UIImage *)image
            forKey:(NSString *)key {
    if (!image || !key) {
        return;
    }
    
    // Compute the cost requirements to save the image in cache
    NSUInteger imageCosts = [self costsForImage:image];
    
    [self.imageCache setObject:image
                        forKey:key
                          cost:imageCosts];
}

- (UIImage *)cachedImageForForKey:(NSString *)key {
    // First check the in-memory cache
    UIImage *image = [self.imageCache objectForKey:key];
    if (image) {
        return image;
    }
    
    return image;
}

- (NSUInteger)costsForImage:(UIImage *)image {
    return image.size.height * image.size.width * image.scale * image.scale;
}

- (NSString *)cacheNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

- (void)cacheImageToDisk:(UIImage *)image
           forIdentifier:(NSString *)identifier {
    NSString *thumbnailDownloadPath = [self thumbnailDownloadPathForIdentifier:identifier];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    BOOL doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:thumbnailDownloadPath];
    if (!doesFileExist) {
        [self createIntermediateDirectoryStructureForPath:thumbnailDownloadPath];
    }
    
    if (![imageData writeToFile:thumbnailDownloadPath
                     atomically:NO]) {
        AFALogError(@"Cannot cache to disk image with identifier: %@", identifier);
    }
}

- (UIImage *)cachedDiskImageForIdentifier:(NSString *)identifier {
    NSString *thumbnailDownloadPath = [self thumbnailDownloadPathForIdentifier:identifier];
    NSError *error = nil;
    NSData *imageData = [NSData dataWithContentsOfFile:thumbnailDownloadPath
                                               options:NSDataReadingUncached
                                                 error:&error];
    if (error.code != NSFileReadNoSuchFileError) {
        AFALogError(@"Encountered an error while loading disk cached image with identifier: %@", identifier);
    }
    
    if (imageData) {
      return [UIImage imageWithData:imageData];
    } else {
        return nil;
    }
}

- (NSString *)thumbnailDownloadPathForIdentifier:(NSString *)identifier {
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = documentsPaths.firstObject;
    NSString *thumbnailPath = [[documentsPath stringByAppendingPathComponent:cachedThumbnailsPath] stringByAppendingPathComponent:identifier];
    
    return thumbnailPath;
}

- (void)createIntermediateDirectoryStructureForPath:(NSString *)path {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error) {
        AFALogError(@"Encountered an error while generating the folder structure for content with path :%@. Reason:%@", path, error.localizedDescription);
    }
}

@end
