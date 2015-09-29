//
//  VegaNomSearchResult.m
//  TalkinToTheNet
//
//  Created by Justine Gartner on 9/21/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "VegaNomSearchResult.h"

@implementation VegaNomSearchResult

-(instancetype)initWithAPIResponse: (NSDictionary *)business{
    
    if (self = [super init]){
        
        self.venueName = business[@"name"];
        
        self.venueAddress = business[@"location"][@"display_address"];
        
        self.venueAvatar = business[@"image_url"];
        
        return self;
    }
    
    return nil;
}

@end
