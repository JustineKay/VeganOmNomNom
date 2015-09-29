//
//  APIManager.m
//  API-Practice
//
//  Created by Justine Gartner on 9/20/15.
//  Copyright © 2015 Justine Gartner. All rights reserved.
//

#import "APIManager.h"
#import "NSURLRequest+OAuth.h"

/**
 Default paths and search terms used in this example
 */
static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kBusinessPath      = @"/v2/business/";
static NSString * const kSearchLimit       = @"20";

@implementation APIManager

#pragma mark - Yelp API Request Public

+ (void)getYelpAPIRequestForTerm:(NSString *)term location:(NSString *)location completionHandler:(void (^)(NSArray *businesses, NSError *error))completionHandler {
    
    NSLog(@"Querying the Search API with term \'%@\' and location \'%@'", term, location);
    
    //Make a first request to get the search results with the passed term and location
    NSURLRequest *searchRequest = [self _searchRequestWithTerm:term location:location];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (!error && httpResponse.statusCode == 200) {
            
            NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSArray *businessArray = searchResponseJSON[@"businesses"];
            
            if ([businessArray count] > 0) {
                NSDictionary *firstBusiness = [businessArray firstObject];
                NSString *firstBusinessID = firstBusiness[@"id"];
                NSLog(@"%lu businesses found, querying business info for the top result: %@", (unsigned long)[businessArray count], firstBusinessID);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(businessArray, nil);
                });
                
            } else {
                completionHandler(nil, error); // No business was found
            }
        } else {
            completionHandler(nil, error); // An error happened or the HTTP response is not a 200 OK
        }
    }] resume];
}


#pragma mark - Yelp API Request Builders

/**
 Builds a request to hit the search endpoint with the given parameters.
 
 @param term The term of the search, e.g: dinner
 @param location The location request, e.g: San Francisco, CA
 
 @return The NSURLRequest needed to perform the search
 */
+ (NSURLRequest *)_searchRequestWithTerm:(NSString *)term location:(NSString *)location {
    NSDictionary *params = @{
                             @"term": term,
                             @"location": location,
                             @"limit": kSearchLimit
                             };
    
    return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
}

#pragma  mark - Instagam API Request

+ (void)GetInstagramAPIRequestWithURL: (NSURL *)url
        completionHandler: (void(^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completionHandler(data, response, error);
            
        });
    }];
    
    [task resume];
}




+ (UIImage *)createImageFromString:(NSString *)urlString{
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData  *imageData = [NSData dataWithContentsOfURL:url];
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    return image;
    
}

+ (NSString *)createAddressFromArray: (NSArray *)addressArray{
    
    NSString *venueAddress;
    
    if (addressArray.count == 3) {
        
        venueAddress = [NSString stringWithFormat:@"%@ %@ %@", addressArray[0], addressArray[1], addressArray[2]];
        
    }else if (addressArray.count == 2){
        
        venueAddress = [NSString stringWithFormat:@"%@ %@", addressArray[0], addressArray[1]];
    }else{
    
        venueAddress = addressArray[0];
        
    }
    
    return venueAddress;
}

+ (NSString *)createTagFromVenueName: (NSString *)venueName{
    
    NSString *vNameApostrophe = [venueName stringByReplacingOccurrencesOfString:@"'" withString:@""];
    NSString *vNameAmpersand = [vNameApostrophe stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
    NSString *vNameDash = [vNameAmpersand stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *vNameE = [vNameDash stringByReplacingOccurrencesOfString:@"é" withString:@"e"];
    NSString *vNameSpaces = [vNameE stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *vNameBabyCakesBakery = [vNameSpaces stringByReplacingOccurrencesOfString:@"ErinMcKennasBabyCakes" withString:@"erinmckennasbakery"];
    NSString *vNameExclamation = [vNameBabyCakesBakery stringByReplacingOccurrencesOfString:@"!" withString:@""];
    
    NSString *venueTag = [vNameExclamation lowercaseString];
    
    return venueTag;
}


@end
