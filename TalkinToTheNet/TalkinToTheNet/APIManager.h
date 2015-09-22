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

+ (void)GetRequestWithURL: (NSURL *)url
        completionHandler: (void(^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

+ (UIImage *)createImageFromString:(NSString *)urlString;

@end
