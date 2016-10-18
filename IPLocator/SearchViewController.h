//
//  ViewController.h
//  IPLocator
//
//  Created by Samantha Todd on 10/7/16.
//  Copyright © 2016 Samantha Todd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GetLocationOperation.h"

@interface SearchViewController : UIViewController <MKMapViewDelegate, GetLocationOperationDelegate>


@end

