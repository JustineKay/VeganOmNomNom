//
//  InstagramDetailViewController.m
//  TalkinToTheNet
//
//  Created by Justine Gartner on 9/25/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "InstagramDetailViewController.h"
#import "APIManager.h"
#import "InstaPostTableViewCell.h"
#import "InstaPostHeaderView.h"
#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface InstagramDetailViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *instagramLogoImageView;

@property (nonatomic) NSMutableArray *searchResults;

@end

@implementation InstagramDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tagLabel.text = [NSString stringWithFormat:@"#%@", self.venueNameTag];
    
    [self fetchInstagramData];
    
    //tell the table view to auto adjust the height of each cell
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
    
    //grab the nib from the main bundle
    UINib *nib = [UINib nibWithNibName:@"InstaPostTableViewCell" bundle:nil];
    
    //register the nib for the cell identifier
    [self.tableView registerNib:nib forCellReuseIdentifier:@"InstaPostCellIdentifier"];
    
    //do the same thing here in one line:
    [self.tableView registerNib:[UINib nibWithNibName:@"InstaPostHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"InstaPostHeaderIdentifier"];
    
}

-(void)fetchInstagramData{
    
    NSString *venueNameTagURL = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?client_id=ac0ee52ebb154199bfabfb15b498c067", self.venueNameTag];
    
    NSURL *instagramURL = [NSURL URLWithString:venueNameTagURL];
 
    [APIManager GetInstagramAPIRequestWithURL:instagramURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        NSArray *results = json[@"data"];

        self.searchResults = [[NSMutableArray alloc] init];
        
        for (NSDictionary *result in results){
            
            InstaPost *post = [[InstaPost alloc] initWithJSON:result];
            
            [self.searchResults addObject:post];
        }
        
        NSLog(@"%@", json);
        
        [self.tableView reloadData];
        
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.searchResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InstagramPostsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InstaPostCellIdentifier" forIndexPath:indexPath];
    
    InstaPost *post = self.searchResults[indexPath.section];
    
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", post.username];
    cell.likesLabel.text = [NSString stringWithFormat:@"Likes: %ld",post.likeCount];
    cell.captionLabel.text = post.caption[@"text"];
    
    UIImage *instagramImage = [APIManager createImageFromString:post.instaImage];
    
    cell.imageView.image = instagramImage;
    
    //set up properties with the xib files before completing the following methods
    
//    [cell.userMediaImageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        cell.userMediaImageView.image = image;
//    }];
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    InstaPostHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"InstaPostHeaderIdentifier"];
    
    InstaPost *post = self.searchResults[section];
    
    headerView.usernameLabel.text = post.username;
    headerView.fullNameLabel.text = post.fullName;
    
    headerView.backgroundView = [[UIView alloc] initWithFrame:headerView.bounds];
    headerView.backgroundView.backgroundColor = [UIColor whiteColor];
    
    
    NSURL *avatarURL = [NSURL URLWithString:post.instaImage];
    
    [headerView.imageView sd_setImageWithURL:avatarURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        headerView.imageView.image = image;
    }];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 60.0;
}



@end
