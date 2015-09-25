//
//  InstagramPostsTableViewCell.h
//  TalkinToTheNet
//
//  Created by Justine Gartner on 9/25/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstagramPostsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *instaPostImageView;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;

@end
