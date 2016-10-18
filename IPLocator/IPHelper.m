//
//  IPHelper.m
//  IPLocator
//
//  Created by Samantha Todd on 10/7/16.
//  Copyright © 2016 Samantha Todd. All rights reserved.
//

#import "IPHelper.h"

#define MAX_IP 4294967295       // Corresponds to 255.255.255.255

@implementation IPHelper

+ (NSString *)ipFromLong:(long long)value {
    if (value < 0 || value > MAX_IP) { // this is the IP range from 0.0.0.0 to 255.255.255.255
        return nil;
    }
    // since the only way we can get the input long is from the method below, they will always be within the valid range
    int octect4 = value % 256;
    value /= 256;
    int octet3 = value % 256;
    value /= 256;
    int octet2 = value % 256;
    value /= 256;
    return [NSString stringWithFormat:@"%lli.%i.%i.%i", value, octet2, octet3, octect4];
}

+ (long long)longFromIP:(NSString *)ip {
    NSArray *octets = [ip componentsSeparatedByString:@"."];
    if (octets.count < 4) {     // Must have four groups to be valid IP.
        return -1;
    }
    long long sum = 0;
    for (int i = 0; i < octets.count; i++) {
        NSString *octet = octets[i];
        if (![IPHelper octetIsValid:octet]) {
            return -1;
        }
        sum += [octet intValue] * pow(256.0, octets.count - i - 1);
    }
    return sum;
}

+ (BOOL)octetIsValid:(NSString *)octet {
    if (octet.length < 1) {
        return NO;
    }
    int intRepresentation = [octet intValue];
    if (intRepresentation < 0 || intRepresentation > 255) {
        return NO;
    }
    return YES;
}

@end
