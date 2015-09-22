//
//  VegaNomSearchResult.h
//  TalkinToTheNet
//
//  Created by Justine Gartner on 9/21/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VegaNomSearchResult : NSObject

@property (nonatomic) NSString *venueName;
@property (nonatomic) NSString *distance;
@property (nonatomic) UIImage *avatar;
@property (nonatomic) NSString *address;
@property (nonatomic) NSString *phoneNumber;
@property (nonatomic) NSString *hoursOfOperation;

@end
