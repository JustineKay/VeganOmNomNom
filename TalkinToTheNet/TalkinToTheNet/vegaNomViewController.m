//
//  vegaNomViewController.m
//  TalkinToTheNet
//
//  Created by Justine Gartner on 9/21/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.

//CustomFont: FreightSansCmpPro-Light , FreightSansCmpPro
//CustomFont: District Pro , DistrictPro-Thin

#import "vegaNomViewController.h"
#import "APIManager.h"
#import "VegaNomSearchResult.h"
#import "NSURLRequest+OAuth.h"
#import "InstagramDetailViewController.h"
#import "InstaPost.h"
#import <NYAlertViewController/NYAlertViewController.h>
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>
#import "MapKit/MapKit.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface vegaNomViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *whatTextField;
@property (weak, nonatomic) IBOutlet UITextField *whereTextField;
@property (nonatomic) NSMutableArray *searchResults;
@property (nonatomic) NSArray *businesses;
@property (nonatomic) NSString *searchTerm;
@property (nonatomic) NSString *location;

@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation vegaNomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.whatTextField.delegate = self;
    self.whereTextField.delegate = self;
    self.locationManager.delegate = self;
    
    //start with map centered at the following coordinates
    //with a span from the center point
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(40.7, -74);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.25, 0.25);
    
    [self.mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    };
    
}


-(void)makeNewYelpRequestWithSearchTerm: (NSString *)searchTerm andLocation: (NSString *)location callbackBlock: (void(^)())block{
    
    NSString *searchTerms = [NSString stringWithFormat:@"vegan,%@", searchTerm];
    
    [APIManager getYelpAPIRequestForTerm:searchTerms location:location completionHandler:^(NSArray *businesses, NSError *error) {
        
        if (error) {
            NSLog(@"An error happened during the request: %@", error);
            
            [self presentAlertViewForError];
            
        } else if (businesses) {
            
            NSLog(@"businesses: %@", businesses);
            self.businesses = businesses;
            
            self.searchResults = [[NSMutableArray alloc] init];
            
            for (NSDictionary *business in businesses) {
                
                VegaNomSearchResult *venue = [[VegaNomSearchResult alloc] initWithAPIResponse:business];
                
                [self.searchResults addObject:venue];
                
                block();
            }
            
        }else {
            NSLog(@"No business was found");
            
            [self presentAlertViewForNoBusinessesFound];
            
            block ();
            
            
        }
        
    }];
    
}

#pragma mark - Alert View methods

-(void)presentAlertViewForNoLocation{
    
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
    [self setUpCustomAlertViewController:alertViewController
                               withTitle:@"Oops"
                                 message:@"Please enter a valid city and state."
                               andAction:@"OK"];
    
    [self presentViewController:alertViewController animated:YES completion:nil];
    
}


-(void)presentAlertViewForNoBusinessesFound{
    
    
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
    [self setUpCustomAlertViewController:alertViewController
                               withTitle:@"No businesses found."
                                 message:@"Please try your search again"
                               andAction:@"OK"];
    
    [self presentViewController:alertViewController animated:YES completion:nil];
    
}

-(void)presentAlertViewForError{
    
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
    [self setUpCustomAlertViewController:alertViewController
                               withTitle:@"Error"
                                 message:@"Please try your search again"
                               andAction:@"OK"];
    
    [self presentViewController:alertViewController animated:YES completion:nil];
}

-(void)setUpCustomAlertViewController: (NYAlertViewController *)alertViewController
                            withTitle: (NSString *)title
                              message: (NSString *)message
                            andAction: (NSString *)actionTitle{
    
    // Set a title and message
    alertViewController.title = title;
    alertViewController.message = message;
    
    // Customize appearance as desired
    alertViewController.buttonCornerRadius = 20.0f;
    alertViewController.view.tintColor = self.view.tintColor;
    
    alertViewController.titleFont = [UIFont fontWithName:@"DistrictPro-Thin" size:19.0f];
    alertViewController.messageFont = [UIFont fontWithName:@"DistrictPro-Thin" size:16.0f];
    alertViewController.buttonTitleFont = [UIFont fontWithName:@"DistrictPro-Thin" size:alertViewController.buttonTitleFont.pointSize];
    alertViewController.cancelButtonTitleFont = [UIFont fontWithName:@"DistrictPro-Thin" size:alertViewController.cancelButtonTitleFont.pointSize];
    
    alertViewController.swipeDismissalGestureEnabled = YES;
    alertViewController.backgroundTapDismissalGestureEnabled = YES;
    
    // Add alert actions
    [alertViewController addAction:[NYAlertAction actionWithTitle:actionTitle
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }]];
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
    
    NSString *venueAddress = [APIManager createAddressFromArray:currentResult.venueAddress];
    
    cell.detailTextLabel.text = venueAddress;
    
    UIImage *venueAvatar = [APIManager createImageFromString:currentResult.venueAvatar];
    
    cell.imageView.image = venueAvatar;
    
    return cell;
}

#pragma mark - textFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    //dismiss keyboard
    [self.view endEditing:YES];
    
    self.searchTerm = self.whatTextField.text;
    self.location = self.whereTextField.text;
    
    if ([self.location isEqualToString:@""]){
        
        [self presentAlertViewForNoLocation];
        
    }else{
        
        [self makeNewYelpRequestWithSearchTerm:self.searchTerm andLocation: self.location callbackBlock:^{
            
            [self.tableView reloadData];
            
            [self updateMap];
            
            self.searchTerm = nil;
            self.location = nil;
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

#pragma mark - map view methods

-(void)updateMap{
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for (NSDictionary *business in self.businesses) {
        [self addMapAnnotationForVenue:business];
    }
}

-(void)addMapAnnotationForVenue: (NSDictionary *)venue{
    
    MKPointAnnotation *mapPin = [[MKPointAnnotation alloc] init];
    
    double lat = [venue[@"location"][@"coordinate"][@"latitude"]doubleValue];
    double lng = [venue[@"location"][@"coordinate"][@"longitude"]doubleValue];
    
    CLLocationCoordinate2D latLng = CLLocationCoordinate2DMake(lat, lng);
    
    CLLocationCoordinate2D center = latLng;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.25, 0.25);
    [self.mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];
    
    mapPin.coordinate = latLng;
    mapPin.title = venue[@"name"];
    mapPin.subtitle = [self findIfVenueIsClosedOrOpen:venue[@"is_closed"]];
    
    [self.mapView addAnnotation:mapPin];
}

-(NSString *)findIfVenueIsClosedOrOpen: (BOOL)isClosed{
    
    NSString *openOrClosed;
 
    if (isClosed) {
        openOrClosed = @"Currently Closed";
    }else{
        
        openOrClosed = @"OPEN";
    }
    return openOrClosed;
}

@end
