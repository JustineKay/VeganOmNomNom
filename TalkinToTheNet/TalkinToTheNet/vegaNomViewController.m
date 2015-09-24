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
#import "NSURLRequest+OAuth.h"
#import "YPAPISample.h"

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



/*-(void)makeNewFourSquareRequestWithSearchTerm: (NSString *)searchTerm callbackBlock: (void(^)())block{
    
    //searchTerm (comes from our parameter)
    
    //url(query=searchterm)
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/explore?ll=40.7,-74&query=%@&oauth_token=LBLFB0ZHUZAN1SA4RYQUQ4BT0RB11Z03GZ33D0ZXAFTDXSNV&v=20150922", searchTerm];
    
    NSLog(@"%@", urlString);
    
    
    //encoded url
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:encodedString];
    
    //make the request
    [APIManager GetRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            
            //do something with data
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", json);
            
            NSDictionary *results = [json objectForKey:@"response"];
            
            self.searchResults = [[NSMutableArray alloc] init];
            
            for (NSDictionary *result in results) {
                
                NSDictionary *groups = [result objectForKey:@"groups"];
                NSLog(@"groups: %@", groups);
                
                NSDictionary *items = [groups objectForKey:@"items"];
                NSDictionary *venueList = [items objectForKey:@"venue"];
                NSDictionary *contact = [venueList objectForKey:@"contact"];
                NSDictionary *location = [venueList objectForKey:@"location"];
                
                NSString *venue = [venueList objectForKey:@"name"];
                
                NSString *distance = [location objectForKey:@"distance"];
                
                NSArray *addressArray = [venueList objectForKey:@"formattedAddress"];
                NSString *addressLine1 = addressArray[0];
                NSString *addressLine2 = addressArray[1];
                NSString *address = [NSString stringWithFormat:@"%@/n%@", addressLine1, addressLine2];
                
                NSString *phone = [contact objectForKey:@"formattedPhone"];
                NSString *twitter = [contact objectForKey:@"twitter"];
                
                VegaNomSearchResult *venueObject = [[VegaNomSearchResult alloc] init];
                
                venueObject.venueName = venue;
                venueObject.distance = distance;
                venueObject.address = address;
                venueObject.phoneNumber = phone;
                venueObject.twitterHandle = twitter;
                
                [self.searchResults addObject:venueObject];
                
            }
            
            NSLog(@"%@", self.searchResults);
            
            //executes the block that we're passing to the method
            block();
        }
    }];
    
}*/

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
    
    return cell;
}

#pragma mark - textFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    //dismiss keyboard
    [self.view endEditing:YES];
    
    //make an api request
    
    NSString *location = @"New York, NY";
    NSString *searchTerms = [NSString stringWithFormat:@"vegan,%@", textField.text];
    
    YPAPISample *yelpAPIRequest = [[YPAPISample alloc] init];
    [yelpAPIRequest queryTopBusinessInfoForTerm:searchTerms location:location completionHandler:^(NSDictionary *jsonResponse, NSError *error) {
        
        if (error) {
            
            NSLog(@"An error happened during the request: %@", error);
            
        } else {
            
            NSLog(@"No business was found");
        
        }
        
        [self.tableView reloadData];
    }];

    
//    [self makeNewFourSquareRequestWithSearchTerm:textField.text callbackBlock:^{
//        [self.tableView reloadData];
//    }];
    
    
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
