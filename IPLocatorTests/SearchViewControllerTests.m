//
//  IPLocatorTests.m
//  IPLocatorTests
//
//  Created by Samantha Todd on 10/7/16.
//  Copyright © 2016 Samantha Todd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SearchViewController.h"
#import "IPHelper.h"

@interface SearchViewController (XCTests)

@property (weak, nonatomic) IBOutlet UITextField *startAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *endAddressTextField;
@property (weak, nonatomic) IBOutlet UIButton *locateButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong) NSMutableArray *requestQueue;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL hasPromptedWithConnectionError;  // Keep track of error alerts; don't want to keep showing.
@property (nonatomic, strong) NSMutableDictionary *placedPins;

- (void)dropPinAtLongitude:(double)longitude andLatitude:(double)latitude forIPAddress:(NSString *)ip withSubtitle:(NSString *)subtitle;

@end

@interface SearchViewControllerTests : XCTestCase

@end

@implementation SearchViewControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDropPinAtLocation {
    SearchViewController *searchController = [[SearchViewController alloc] init];
    MKMapView *map = [[MKMapView alloc] init];
    searchController.mapView = map;
    [searchController viewDidLoad]; // initialize properties
    [searchController dropPinAtLongitude:20.0 andLatitude:20.0 forIPAddress:@"1.2.3.4" withSubtitle:@"Test Subtitle"];
    // Dropping the pin should add it to the map's annotations array, as well as add it to its dictionary.
    MKPointAnnotation *annotation = searchController.placedPins[@([IPHelper longFromIP:@"1.2.3.4"])];
    XCTAssert(annotation != nil);
    XCTAssert([searchController.mapView.annotations containsObject:annotation]);
}

@end
