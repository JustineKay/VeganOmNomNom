//
//  InstaPost.m
//  CustomTableViewCells
//
//  Created by Justine Gartner on 9/24/15.
//  Copyright © 2015 Justine Gartner. All rights reserved.
//

#import "InstaPost.h"
#import "APIManager.h"

@implementation InstaPost

-(instancetype)initWithJSON: (NSDictionary *)json{
    
    //call super init, return self
    
    if (self = [super init]){
        
        self.tags = [json objectForKey:@"tags"];
        self.commentCount = [json[@"comments"][@"count"]integerValue];
        self.likeCount = [json[@"likes"][@"count"]integerValue];
        
        self.username = json[@"user"][@"username"];
        self.fullName = json[@"user"][@"full_name"];
        self.caption = json[@"caption"];
        
        NSString *imageURLString = json[@"images"][@"low_resolution"][@"url"];
        UIImage *image = [APIManager createImageFromString:imageURLString];
        self.instaImage = image;
        
        return self;
    
    }
    
    return nil;
    
}

@end
