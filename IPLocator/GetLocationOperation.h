//
//  GetLocationOperation.h
//  IPLocator
//
//  Created by Samantha Todd on 10/7/16.
//  Copyright © 2016 Samantha Todd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define API_KEY @"740fbcc1514c91f114387f405e3b7754c6ccdc179b0303ad6787147b9e005ce6"

@protocol GetLocationOperationDelegate <NSObject>

- (void)dropPinAtLongitude:(double)longitude andLatitude:(double)latitude forIPAddress:(NSString *)ip withSubtitle:(NSString *)subtitle;
- (void)connectionDidEncounterError:(NSError *)error;

@end

@interface GetLocationOperation : NSObject <NSURLConnectionDelegate>

@property (nonatomic, weak) id<GetLocationOperationDelegate> delegate;

- (id)initWithIP:(NSString *)ip;
- (void)execute;

@end
