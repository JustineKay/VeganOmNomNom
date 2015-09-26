//
//  InstagramDetailViewController.m
//  TalkinToTheNet
//
//  Created by Justine Gartner on 9/25/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "InstagramDetailViewController.h"
#import "APIManager.h"

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
    
}

-(void)fetchInstagramData{
    
    NSString *venueNameTagURL = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?client_id=ac0ee52ebb154199bfabfb15b498c067", self.venueNameTag];
    
    NSURL *instagramURL = [NSURL URLWithString:venueNameTagURL];
 
    [APIManager GetRequestWithURL:instagramURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.searchResults.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InstagramPostsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InstaPostCellIdentifier" forIndexPath:indexPath];
    
    InstaPost *post = self.searchResults[indexPath.row];
    
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", post.username];
    cell.likesLabel.text = [NSString stringWithFormat:@"Likes: %ld",post.likeCount];
    cell.captionLabel.text = post.caption[@"text"];
    
    cell.imageView.image = post.instaImage;
    
    return cell;
}


@end
