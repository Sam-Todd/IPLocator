//
//  GetLocationOperationTests.m
//  IPLocator
//
//  Created by Samantha Todd on 10/8/16.
//  Copyright © 2016 Samantha Todd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GetLocationOperation.h"

@interface GetLocationOperation (XCTests)

@property (nonatomic, strong) NSMutableURLRequest *request;

@end

@interface GetLocationOperationTests : XCTestCase

@end

@implementation GetLocationOperationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithIP {
    GetLocationOperation *op = [[GetLocationOperation alloc] initWithIP:@"1.2.3.4"];
    NSString *expectedURL = [NSString stringWithFormat:@"http://api.ipinfodb.com/v3/ip-city/?key=%@&ip=1.2.3.4&format=json", API_KEY];
    XCTAssert([op.request.URL.absoluteString isEqualToString:expectedURL]);
}

@end
