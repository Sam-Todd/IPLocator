//
//  GetLocationOperation.m
//  IPLocator
//
//  Created by Samantha Todd on 10/7/16.
//  Copyright © 2016 Samantha Todd. All rights reserved.
//

#import "GetLocationOperation.h"

@interface GetLocationOperation ()

@property (nonatomic, strong) NSMutableURLRequest *request;

@end

@implementation GetLocationOperation

- (id)initWithIP:(NSString *)ip {
    if (self = [super init]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.ipinfodb.com/v3/ip-city/?key=%@&ip=%@&format=json", API_KEY, ip]];
        self.request = [[NSMutableURLRequest alloc] initWithURL:url];
        [self.request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [self.request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];
        [self.request setHTTPMethod:@"GET"];
    }
    return self;
}

- (void)execute {
    //NSLog(@"Making request with URL: %@", self.request.URL);
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfig.timeoutIntervalForRequest = 30.0;
    sessionConfig.timeoutIntervalForResource = 60.0;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // handle getting the data
        NSError *jsonError;
        if (error) {
            // We couldn't connect for some reason. This also modifies UI (presents alert) so must be run on main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate connectionDidEncounterError:error];
            });
        }
        else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            double longitude = [dict[@"longitude"] doubleValue];
            double latitude = [dict[@"latitude"] doubleValue];
            // Note: if the IP addresses are located in the same city, they appear to all return the exact same coordinates.
            // Some of the queries won't return anything; we don't want to do anything with those.
            if (dict[@"ipAddress"]) {
                // This request handler is executing on a background thread; all UI updates need to be on the main thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate dropPinAtLongitude:longitude andLatitude:latitude forIPAddress:dict[@"ipAddress"] withSubtitle:[NSString stringWithFormat:@"%@, %@", dict[@"cityName"], dict[@"regionName"]]];
                });
            }
        }
    }];
    [task resume];
}

@end
