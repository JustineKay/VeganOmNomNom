//
//  vegaNomViewController.m
//  TalkinToTheNet
//
//  Created by Justine Gartner on 9/21/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "vegaNomViewController.h"
#import "APIManager.h"
#import "VegaNomSearchResult.h"
#import <CoreLocation/CoreLocation.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface vegaNomViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *whatTextField;
@property (weak, nonatomic) IBOutlet UITextField *whereTextField;
@property (nonatomic) NSMutableArray *searchResults;
@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation vegaNomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.whatTextField.delegate = self;
    self.whereTextField.delegate = self;
    self.locationManager.delegate = self;
    
    //[self.locationManager requestLocation];
    //[self.locationManager startUpdatingLocation];
    
}

-(void)makeNewFourSquareRequestWithSearchTerm: (NSString *)searchTerm callbackBlock: (void(^)())block{
    
    //searchTerm (comes from our parameter)
    
    //url(media=music, term=searchterm)
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/search?media=music&term=%@", searchTerm];
    
    //https://api.foursquare.com/v2/venues/explore?ll=40.7,-74&query=vegan&oauth_token=LBLFB0ZHUZAN1SA4RYQUQ4BT0RB11Z03GZ33D0ZXAFTDXSNV&v=20150922
    
    //encoded url
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:encodedString];
    
    //make the request
    [APIManager GetRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            
            //do something with data
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //NSLog(@"%@", json);
            
            NSArray *results = [json objectForKey:@"results"];
            
            self.searchResults = [[NSMutableArray alloc] init];
            
            for (NSDictionary *result in results) {
                
                NSString *venue = [result objectForKey:@"artistName"];
                NSString *distance = [result objectForKey:@"trackName"];
                NSString *address = [result objectForKey:@"artistName"];
                NSString *phone = [result objectForKey:@"trackName"];
                NSString *hours = [result objectForKey:@"artistName"];
                
                NSString *avatarURL = [result objectForKey:@"artworkUrl100"];
                UIImage *avatarImage = [APIManager createImageFromString:avatarURL];
                
                VegaNomSearchResult *venueObject = [[VegaNomSearchResult alloc] init];
                
                venueObject.venueName = venue;
                venueObject.distance = distance;
                venueObject.address = address;
                venueObject.phoneNumber = phone;
                venueObject.hoursOfOperation = hours;
                venueObject.avatar = avatarImage;
                
                [self.searchResults addObject:venueObject];
                
            }
            
            //NSLog(@"%@", self.searchResults);
            
            //executes the block that we're passing to the method
            block();
        }
    }];
    
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"did update locations");
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"did fail with error");
}


#pragma mark - tableViewDatasource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.searchResults.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"vegaNomCellIdentifier" forIndexPath:indexPath];
    
    VegaNomSearchResult *currentResult = self.searchResults[indexPath.row];
    
    cell.textLabel.text = currentResult.venueName;
    cell.detailTextLabel.text = currentResult.distance;
    cell.imageView.image = currentResult.avatar;
    
    return cell;
}

#pragma mark - textFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    //dismiss keyboard
    [self.view endEditing:YES];
    
    //make an api request
    [self makeNewFourSquareRequestWithSearchTerm:textField.text callbackBlock:^{
        [self.tableView reloadData];
    }];
    
    
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
