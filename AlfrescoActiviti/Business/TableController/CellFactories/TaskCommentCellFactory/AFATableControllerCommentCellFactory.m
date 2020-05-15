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

#import "AFATableControllerCommentCellFactory.h"

// Constans
#import "AFAUIConstants.h"

// Cells
#import "AFACommentHeaderTableViewCell.h"
#import "AFACommentTableViewCell.h"

// Managers
#import "AFAUserServices.h"
#import "AFAServiceRepository.h"
#import "AFAThumbnailManager.h"
@import ActivitiSDK;

@interface AFATableControllerCommentCellFactory ()

@property (strong, nonatomic) AFAUserServices *fetchPictureForUserService;

@end

@implementation AFATableControllerCommentCellFactory

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _fetchPictureForUserService = [AFAUserServices new];
    }
    
    return self;
}


#pragma mark -
#pragma mark AFATableViewCellFactory Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView
              cellForIndexPath:(NSIndexPath *)indexPath
                      forModel:(id<AFATableViewModelDelegate>)model {
    UITableViewCell *cell = nil;
    
    if (!indexPath.row) {
        AFACommentHeaderTableViewCell *commentHeaderCell = [tableView dequeueReusableCellWithIdentifier:kCellIDCommentHeader
                                                                                           forIndexPath:indexPath];
        [commentHeaderCell setupCellWithCommentsPaging:[model itemAtIndexPath:indexPath]];
        
        cell = commentHeaderCell;
    } else {
        AFACommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:kCellIDComment
                                                                               forIndexPath:indexPath];
        // Setup cell with comment
        ASDKModelComment *comment = (ASDKModelComment *)[model itemAtIndexPath:indexPath];
        [commentCell setUpCellWithComment:comment];
        
        // Get a placeholder and make a request for the profile image
        AFAThumbnailManager *thumbnailManager = [[AFAServiceRepository sharedRepository] serviceObjectForPurpose:AFAServiceObjectTypeThumbnailManager];
        commentCell.avatarView.profileImage = [thumbnailManager thumbnailImageForIdentifier:comment.authorModel.modelID];
        
        [self.fetchPictureForUserService requestPictureForUserID:comment.authorModel.modelID
                                                 completionBlock:^(UIImage *profileImage, NSError *error) {
                                                    UIImage *cachedThumbnailImage = [thumbnailManager thumbnailForImage:profileImage
                                                                          withIdentifier:comment.authorModel.modelID
                                                                                withSize:CGRectGetHeight(commentCell.avatarView.frame) * [UIScreen mainScreen].scale
                                                               processingCompletionBlock:^(UIImage *processedThumbnailImage) {
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       [tableView reloadData];
                                                                   });
                                                               }];
                                                     if (cachedThumbnailImage) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             AFACommentTableViewCell *cellToUpdate = [tableView cellForRowAtIndexPath:indexPath];
                                                             cellToUpdate.avatarView.profileImage = cachedThumbnailImage;
                                                         });
                                                     }
                                                 }];
        
        cell = commentCell;
    }
    
    return cell;
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

@end
