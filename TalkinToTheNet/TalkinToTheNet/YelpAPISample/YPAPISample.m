//
//  YPAPISample.m
//  YelpAPI

#import "YPAPISample.h"
#import "NSURLRequest+OAuth.h"

/**
 Default paths and search terms used in this example
 */
static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kBusinessPath      = @"/v2/business/";
static NSString * const kSearchLimit       = @"20";

@implementation YPAPISample

#pragma mark - Public

- (void)queryTopBusinessInfoForTerm:(NSString *)term location:(NSString *)location completionHandler:(void (^)(NSArray *businesses, NSError *error))completionHandler {

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


#pragma mark - API Request Builders

/**
 Builds a request to hit the search endpoint with the given parameters.
 
 @param term The term of the search, e.g: dinner
 @param location The location request, e.g: San Francisco, CA

 @return The NSURLRequest needed to perform the search
 */
- (NSURLRequest *)_searchRequestWithTerm:(NSString *)term location:(NSString *)location {
  NSDictionary *params = @{
                           @"term": term,
                           @"location": location,
                           @"limit": kSearchLimit
                           };

  return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
}

@end
