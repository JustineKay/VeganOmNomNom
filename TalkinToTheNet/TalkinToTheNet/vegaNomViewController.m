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
#import "InstagramDetailViewController.h"
#import "InstaPost.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface vegaNomViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *whatTextField;
@property (weak, nonatomic) IBOutlet UITextField *whereTextField;
@property (nonatomic) NSMutableArray *searchResults;
@property (nonatomic) NSString *searchTerm;
@property (nonatomic) NSString *location;

//Not currently using CLLocationManager, but plan to implement in next version
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
    
}



-(void)makeNewYelpRequestWithSearchTerm: (NSString *)searchTerm andLocation: (NSString *)location callbackBlock: (void(^)())block{
    
    //NSString *location = @"New York, NY";
    NSString *searchTerms = [NSString stringWithFormat:@"vegan,%@", searchTerm];
    
    YPAPISample *yelpAPIRequest = [[YPAPISample alloc] init];
    
    [yelpAPIRequest queryTopBusinessInfoForTerm:searchTerms location:location completionHandler:^(NSArray *businesses, NSError *error) {
        
        if (error) {
            NSLog(@"An error happened during the request: %@", error);
            
        } else if (businesses) {
            
            self.searchResults = [[NSMutableArray alloc] init];
            
            for (NSDictionary *business in businesses) {
                
                NSString *venue = [business objectForKey:@"name"];
                
                NSDictionary *location = [business objectForKey:@"location"];
                
                NSArray *addressArray = [location objectForKey:@"display_address"];
                
                NSString *venueAddress = [APIManager createAddressFromArray:addressArray];
                
                NSString *venueImage = [business objectForKey:@"image_url"];
                
                UIImage *image = [APIManager createImageFromString:venueImage];
            
                VegaNomSearchResult *venueObject = [[VegaNomSearchResult alloc] init];
                
                venueObject.venueName = venue;
                venueObject.address = venueAddress;
                venueObject.avatar = image;
                
                [self.searchResults addObject:venueObject];
                
                block();
            }
            
        }else {
            NSLog(@"No business was found");
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
    cell.detailTextLabel.text = currentResult.address;
    cell.imageView.image = currentResult.avatar;
    
    return cell;
}

#pragma mark - textFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    //dismiss keyboard
    [self.view endEditing:YES];
    
    
    if (self.whatTextField.text == nil || self.whereTextField.text == nil) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Oops!"
                                                                       message:@"Please enter a search term"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        alert.view.tintColor = [UIColor yellowColor];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        [self makeNewYelpRequestWithSearchTerm:self.searchTerm andLocation: self.location callbackBlock:^{
            [self.tableView reloadData];
        }];
        
        
    }else if (self.whereTextField.text == nil){
        
        self.searchTerm = self.whatTextField.text;
        self.location = @"NewYork, NY";
        
        [self makeNewYelpRequestWithSearchTerm:self.searchTerm andLocation: self.location callbackBlock:^{
            [self.tableView reloadData];
        }];
    
    
    }else{
        
        self.searchTerm = self.whatTextField.text;
        self.location = self.whereTextField.text;
        
        [self makeNewYelpRequestWithSearchTerm:self.searchTerm andLocation: self.location callbackBlock:^{
            [self.tableView reloadData];
        }];
        
    }
    
    
    
    return YES;
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    VegaNomSearchResult *currentResult = self.searchResults [indexPath.row];
    
    NSString *currentResultTagName = [APIManager createTagFromVenueName:currentResult.venueName];
    
    InstagramDetailViewController *detailViewController = segue.destinationViewController;
    
    detailViewController.venueNameTag = currentResultTagName;
    
}

@end
