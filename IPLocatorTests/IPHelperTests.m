//
//  IPHelperTests.m
//  IPLocator
//
//  Created by Samantha Todd on 10/7/16.
//  Copyright © 2016 Samantha Todd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IPHelper.h"

#define MID_IP_LONG 2147483649  // The long representation of 128.0.0.1
#define MAX_IP_LONG 4294967295  // 255.255.255.255

@interface IPHelperTests : XCTestCase

@end

@implementation IPHelperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


// We will test the two methods in the public interface. octetIsValid: is tested via longFromIP:
- (void)testIPFromLong_negative {
    NSString *ip = [IPHelper ipFromLong:-1];
    XCTAssert(ip == nil, @"IP was %@, should be nil", ip);
}

- (void)testIPFromLong_zero {
    NSString *ip = [IPHelper ipFromLong:0];
    XCTAssert([ip isEqualToString:@"0.0.0.0"], @"IP was %@, should be 0.0.0.0", ip);
}

- (void)testIPFromLong_mid {
    // somewhere in the middle of the valid IP range
    NSString *ip = [IPHelper ipFromLong:MID_IP_LONG];
    XCTAssert([ip isEqualToString:@"128.0.0.1"], @"IP was %@, should be 128.0.0.1", ip);
}

- (void)testIPFromLong_max {
    NSString *ip = [IPHelper ipFromLong:MAX_IP_LONG];     // 255.255.255.255
    XCTAssert([ip isEqualToString:@"255.255.255.255"], @"IP was %@, should be 255.255.255.255", ip);
}

- (void)testIPFromLong_tooLarge {
    // long that is too large to map to a valid IP address.
    long long arg = 4311744511;
    NSString *ip = [IPHelper ipFromLong:arg];    // 256.255.255.255
    XCTAssert(ip == nil, @"IP was %@, should be nil", ip);
}

- (void)testLongFromIP_invalid {
    long long ipLong = [IPHelper longFromIP:@"0.1.3."];
    XCTAssert(ipLong == -1, @"ipLong was %lli, should be -1", ipLong);
}

- (void)testLongFromIP_min {
    long long
    ipLong = [IPHelper longFromIP:@"0.0.0.0"];
    XCTAssert(ipLong == 0, @"ipLong was %lli, should be 0", ipLong);
}

- (void)testLongFromIP_mid {
    // Mid-range IP.
    long long ipLong = [IPHelper longFromIP:@"128.0.0.1"];
    XCTAssert(ipLong == MID_IP_LONG, @"ipLong was %lli, should be %li", ipLong, MID_IP_LONG);
}

- (void)testLongFromIP_max {
    long long ipLong = [IPHelper longFromIP:@"255.255.255.255"];
    XCTAssert(ipLong == MAX_IP_LONG, @"ipLong was %lli, should be %li", ipLong, MAX_IP_LONG);
}

- (void)testLongFromIP_tooLarge {
    long long ipLong = [IPHelper longFromIP:@"256.255.255.255"];
    XCTAssert(ipLong == -1, @"ipLong was %lli, should be -1", ipLong);
}

@end
