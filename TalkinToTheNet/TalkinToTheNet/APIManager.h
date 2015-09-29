//
//  APIManager.h
//  API-Practice
//
//  Created by Justine Gartner on 9/20/15.
//  Copyright © 2015 Justine Gartner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APIManager : NSObject

+ (void)getYelpAPIRequestForTerm:(NSString *)term location:(NSString *)location completionHandler:(void (^)(NSArray *businesses, NSError *error))completionHandler;

+ (NSURLRequest *)_searchRequestWithTerm:(NSString *)term location:(NSString *)location;

+ (void)GetInstagramAPIRequestWithURL: (NSURL *)url
        completionHandler: (void(^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

+ (UIImage *)createImageFromString:(NSString *)urlString;

+ (NSString *)createAddressFromArray: (NSArray *)addressArray;

+ (NSString *)createTagFromVenueName: (NSString *)venueName;

@end
