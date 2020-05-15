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

#import <Foundation/Foundation.h>

typedef void (^AFAThumbnailProcessingCompletionBlock)(UIImage *processedThumbnailImage);

@interface AFAThumbnailManager : NSObject

/**
 *  Returns a local placeholder image
 *
 *  @return     Local placeholder image
 */
- (UIImage *)placeholderThumbnailImage;

/**
 *  Returns a cached image object for the specified identifier and if that's not available
 *  it returns the default thumbnail image.
 *
 *  @param imageIdentifier Image identifier for which the cache check is performed
 *
 *  @return                Cached image for identifier
 */
- (UIImage *)thumbnailImageForIdentifier:(NSString *)imageIdentifier;

/**
 *  Given a large sized image object and a desired size (square thumbnails) the method 
 *  creates and returns scaled UIImage object.
 *
 *  @param largeImage The large sized image object
 *  @param imageSize Specifies the maximum width and height in pixels of a thumbnail.
 *                   Remember to pass the size with consideration to the screen scale
 *                   (eg: for retina the scale is 2)
 *
 *  @return          Scaled thumbnail image for display-only purposes
 */
- (UIImage *)thumbnailForImage:(UIImage *)largeImage
                      withSize:(CGFloat)imageSize;

/**
 *  Given a large sized image object and a desired size (square thumbnails) the method
 *  creates, caches or returns from cache a scaled UIImage object. The lazy created object
 *  is returned via a processing completion block. After the call, a placeholder is imediately 
 *  returned until the thumbnail is created
 *
 *  @param largeImage      The large sized image object
 *  @param imageSize       Specifies the maximum width and height in pixels of a thumbnail.
 *                         Remember to pass the size with consideration to the screen scale
 *                         (eg: for retina the scale is 2)
 *  @param imageIdentifier String used to identify the passed image in the cache
 *  @param completionBlock UIImage object returned after lazy creation
 *
 *  @return Scaled thumbnail image for display-only purposes
 */
- (UIImage *)thumbnailForImage:(UIImage *)largeImage
                withIdentifier:(NSString *)imageIdentifier
                      withSize:(CGFloat)imageSize
     processingCompletionBlock:(AFAThumbnailProcessingCompletionBlock)completionBlock;

/**
 *  Cleans the thumbnail images stored in the internal NSCache
 */
- (void)cleanupMemoryCache;

@end
