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

#import "UIImage+AFAThumbnailCreation.h"
#import <ImageIO/ImageIO.h>
#import "AFALogConfiguration.h"

static const int activitiLogLevel = AFA_LOG_LEVEL_VERBOSE; // | AFA_LOG_FLAG_TRACE;

@implementation UIImage (AFAThumbnailCreation)

+ (UIImage *)createThumbnailForImage:(UIImage *)image
                            withSize:(CGFloat)imageSize {
    NSMutableData *imageData = [[NSMutableData alloc] initWithData:UIImageJPEGRepresentation(image, 1.0)];
    
    CFMutableDataRef dataRef = (__bridge CFMutableDataRef)imageData;
    CGImageSourceRef imgSrc  = CGImageSourceCreateWithData(dataRef, NULL);
    
    UIImage *scaledImage = nil;
    
    if (imgSrc == NULL){
        AFALogError(@"Error creating image source for thumbnail generation. Image source is nil");
    } else {
        
        NSDictionary *options = @{(__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                  (__bridge NSString *)kCGImageSourceCreateThumbnailWithTransform: @YES,
                                  (__bridge NSString *)kCGImageSourceThumbnailMaxPixelSize : @(imageSize)};
        
        CFDictionaryRef cfOptions     = (__bridge CFDictionaryRef)options;
        CGImageRef img                = CGImageSourceCreateThumbnailAtIndex(imgSrc, 0, cfOptions);
        CFStringRef type              = CGImageSourceGetType(imgSrc);
        CGImageDestinationRef imgDest = CGImageDestinationCreateWithData(dataRef, type, 1, NULL);
        
        CGImageDestinationAddImage(imgDest, img, NULL);
        CGImageDestinationFinalize(imgDest);
        
        scaledImage = [UIImage imageWithCGImage:img];
        
        CFRelease(imgSrc);
        CGImageRelease(img);
        CFRelease(imgDest);
    }
    
    return scaledImage;
}

@end
