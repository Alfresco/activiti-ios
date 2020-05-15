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

#import "AFATableControllerContentCellFactory.h"

// Constants
#import "AFAUIConstants.h"
#import "AFABusinessConstants.h"
#import "AFALogConfiguration.h"

// Categories
#import "UIColor+AFATheme.h"

// Managers
#import "AFAThumbnailManager.h"
#import "AFAServiceRepository.h"
#import "AFATaskServices.h"

// Cells
#import "AFAContentFileTableViewCell.h"
#import "AFASimpleSectionHeaderCell.h"

static const int activitiLogLevel = AFA_LOG_LEVEL_VERBOSE; // | AFA_LOG_FLAG_TRACE;

@interface AFATableControllerContentCellFactory ()

@property (strong, nonatomic) NSMutableDictionary *thumbnailOperationsDict;
@property (strong, nonatomic) AFAThumbnailManager *thumbnailManager;
@property (strong, nonatomic) AFATaskServices     *downloadContentThumbnailService;

@end

@implementation AFATableControllerContentCellFactory

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _thumbnailOperationsDict = [NSMutableDictionary new];
        _thumbnailManager = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeThumbnailManager];
        _downloadContentThumbnailService = [AFATaskServices new];
    }
    
    return self;
}


#pragma mark -
#pragma mark AFATableViewCellFactory Delegate

- (BOOL)tableView:(UITableView *)tableView
shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
              cellForIndexPath:(NSIndexPath *)indexPath
                      forModel:(id<AFATableViewModelDelegate>)model {
    ASDKModelContent *content = [model itemAtIndexPath:indexPath];
    AFAContentFileTableViewCell *contentFileCell = [tableView dequeueReusableCellWithIdentifier:kCellIDContentFile
                                                                                   forIndexPath:indexPath];
    [contentFileCell setUpCellWithContent:content];
    
    // First, check the thumbnail manager for cached images
    UIImage *thumbnailImage = nil;
    thumbnailImage = [self.thumbnailManager thumbnailImageForIdentifier:content.modelID];
    if (thumbnailImage != [self.thumbnailManager placeholderThumbnailImage]) {
        contentFileCell.fileThumbnailImageView.image = thumbnailImage;
    } else {
        // Only start a thumbnail download operation for those cells that don't have
        // already an operation in progress and the thumbnail status permits it
        if (!self.thumbnailOperationsDict[indexPath] &&
            content.thumbnailStatus == ASDKModelContentAvailabilityTypeCreated) {
            self.thumbnailOperationsDict[indexPath] = content.modelID;
            
            __weak typeof(self) weakSelf = self;
            [self.downloadContentThumbnailService
             requestTaskContentThumbnailDownloadForContent:content
             allowCachedResults:YES
             withProgressBlock:nil
             withCompletionBlock:^(NSURL *downloadedContentURL, BOOL isLocalContent, NSError *error) {
                 __strong typeof(self) strongSelf = weakSelf;
                 
                 // Remove operation reference for the current indexpath once it has completed
                 strongSelf.thumbnailOperationsDict[indexPath] = nil;
                 
                 if (!error) {
                     UIImage *downloadedThumbnailImage = [[UIImage alloc] initWithContentsOfFile:downloadedContentURL.path];
                     
                     [strongSelf.thumbnailManager thumbnailForImage:downloadedThumbnailImage
                                                     withIdentifier:content.modelID
                                                           withSize:CGRectGetHeight(contentFileCell.fileThumbnailImageView.frame) * [UIScreen mainScreen].scale
                                          processingCompletionBlock:^(UIImage *processedThumbnailImage) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  AFAContentFileTableViewCell *cellToUpdate = [tableView cellForRowAtIndexPath:indexPath];
                                                  cellToUpdate.fileThumbnailImageView.image = processedThumbnailImage;
                                              });
                                          }];
                 } else {
                     AFALogError(@"Unable to retrieve thumbnail image for content with ID:%@. Reason:%@", content.modelID, error.localizedDescription);
                 }
             }];
        }
    }
    
    return contentFileCell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
         forModel:(id<AFATableViewModelDelegate>)model {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
             forModel:(id<AFATableViewModelDelegate>)model {
    // First check if we have to display a section header
    NSString *titleForHeaderInSection = [self titleForSection:section
                                                      inModel:model];
    
    if (titleForHeaderInSection) {
        AFASimpleSectionHeaderCell *simpleSectionHeaderCell = [tableView dequeueReusableCellWithIdentifier:kCellIDProcessInstanceDetailsTaskHeader];
        simpleSectionHeaderCell.sectionTitleLabel.text = titleForHeaderInSection;
        [simpleSectionHeaderCell setUpWithThemeColor:self.appThemeColor];
        
        return simpleSectionHeaderCell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
            forModel:(id<AFATableViewModelDelegate>)model {
    // First check if we have to display a section header
    
    CGFloat headerHeight = [self titleForSection:section
                                         inModel:model] ? 44.0f : .0f;
    return headerHeight;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(NSArray *)tableView:(UITableView *)tableView
editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *deleteButton =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                       title:[@"" stringByPaddingToLength:2
                                                               withString:@"\u3000"
                                                          startingAtIndex:0]
                                     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                         __strong typeof(self) strongSelf = weakSelf;
                                         
                                         AFATableControllerCellActionBlock actionBlock = [strongSelf actionForCellOfType:AFAContentCellTypeDeleteContent];
                                         
                                         if (actionBlock) {
                                             actionBlock(@{kCellFactoryCellParameterCellIdx : @(indexPath.row)});
                                         }
                                     }];
    
    // Tint the image with white
    UIImage *trashIcon = [UIImage imageNamed:@"trash-icon"];
    UIGraphicsBeginImageContextWithOptions(trashIcon.size, NO, trashIcon.scale);
    [[UIColor whiteColor] set];
    [trashIcon drawInRect:CGRectMake(0, 0, trashIcon.size.width, trashIcon.size.height)];
    trashIcon = UIGraphicsGetImageFromCurrentImageContext();
    
    // Draw the image and background
    CGSize rowActionSize = CGSizeMake([tableView rectForRowAtIndexPath:indexPath].size.width, [tableView rectForRowAtIndexPath:indexPath].size.height);
    UIGraphicsBeginImageContextWithOptions(rowActionSize, YES, [[UIScreen mainScreen] scale]);
    CGContextRef context=UIGraphicsGetCurrentContext();
    [[UIColor distructiveOperationBackgroundColor] set];
    CGContextFillRect(context, CGRectMake(0, 0, rowActionSize.width, rowActionSize.height));
    
    [trashIcon drawAtPoint:CGPointMake(trashIcon.size.width + trashIcon.size.width / 4.0f, rowActionSize.height / 2.0f - trashIcon.size.height / 2.0f)];
    [deleteButton setBackgroundColor:[UIColor colorWithPatternImage:UIGraphicsGetImageFromCurrentImageContext()]];
    UIGraphicsEndImageContext();
    
    return @[deleteButton];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AFATableControllerCellActionBlock actionBlock = [self actionForCellOfType:AFAContentCellTypeDownloadContent];
    if (actionBlock) {
        actionBlock(@{kCellFactoryCellParameterCellIndexpath : indexPath});
        
        // Deselect the content cell
        [tableView deselectRowAtIndexPath:indexPath
                                 animated:NO];
    }
}


#pragma mark -
#pragma mark Public interface

- (NSInteger)cellTypeForDeleteContent {
    return AFAContentCellTypeDeleteContent;
}

- (NSInteger)cellTypeForDownloadContent {
    return AFAContentCellTypeDownloadContent;
}


#pragma mark -
#pragma mark Convenience methods

- (NSString *)titleForSection:(NSInteger)section
                      inModel:(id<AFATableViewModelDelegate>)model {
    NSString *titleForHeaderInSection = nil;
    
    if ([model respondsToSelector:@selector(titleForHeaderInSection:)]) {
        titleForHeaderInSection = [model titleForHeaderInSection:section];
    }
    
    return titleForHeaderInSection;
}

@end
