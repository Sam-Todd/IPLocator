//
//  ViewController.m
//  IPLocator
//
//  Created by Samantha Todd on 10/7/16.
//  Copyright © 2016 Samantha Todd. All rights reserved.
//

#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#import <arpa/inet.h>
#import "SearchViewController.h"
#import "IPHelper.h"
#import "GetLocationOperation.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UITextField *startAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *endAddressTextField;
@property (weak, nonatomic) IBOutlet UIButton *locateButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong) NSMutableArray *requestQueue;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL hasPromptedWithConnectionError;  // Keep track of error alerts; don't want to keep showing.
@property (nonatomic, strong) NSMutableDictionary *placedPins;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startAddressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.endAddressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.activityIndicatorView.hidden = YES;
    self.requestQueue = [[NSMutableArray alloc] init];
    self.hasPromptedWithConnectionError = NO;
    self.placedPins = [[NSMutableDictionary alloc] init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)locateButtonPressed:(id)sender {
    [self.view endEditing:YES];
    
    // Get all IPs in range and make API call for each.
    // IP addresses can be represented by an int.
    NSString *startIP = self.startAddressTextField.text;
    long long startInt = [IPHelper longFromIP:startIP];
    NSString *endIP = self.endAddressTextField.text;
    long long endInt = [IPHelper longFromIP:endIP];
    if (startInt == -1 || endInt == -1) {
        // Error, invalid IP address.
        [self showAlertWithMessage:@"One or more of the IP addresses are invalid. Please make sure both addesses are in the format w.x.y.z, where w, x, y and z are each between 0 and 255."];
        return;
    }
    
    if (endInt < startInt) {
        // This is also an error.
        [self showAlertWithMessage:@"The starting address is greater than the ending address."];
        return;
    }
    
    // From startInt to endInt, convert to IP string and add the request to the queue.
    // We will use a timer to pull from the front of the request queue every 30 seconds, as the API documentation says that more than two queries per second will result in queries put in the queue and slowed down to 1/sec.
    // In addition, the loop should run on a background thread, since it could potentially be a lot of IP addresses and we don't want to block the UI.
    // We also need to start the spinner so the user has some indication that we are working.
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
    self.locateButton.enabled = NO;
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (self.requestQueue.count > 0) {
                GetLocationOperation *op = self.requestQueue[0];
                [self.requestQueue removeObjectAtIndex:0];
                [op execute];
            }
        }];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Start the timer
        BOOL willMakeRequest = NO;
        for (long long i = startInt; i <= endInt; i++) {
            // Let's check the dictionary to make sure we don't already have this IP address.
            if (!self.placedPins[@(i)]) {
                NSString *currentIP = [IPHelper ipFromLong:i];
                GetLocationOperation *op = [[GetLocationOperation alloc] initWithIP:currentIP];
                op.delegate = self;
                [self.requestQueue addObject:op];
                willMakeRequest = YES;
            }
        }
        
        if (!willMakeRequest) {
            // Remember, we started the spinner and disabled the button. The condition under which is stops spinning and becomes reenabled is the completion of a request. But if we don't need to make any requests, the spinner never stops. So do it here.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicatorView stopAnimating];
                self.activityIndicatorView.hidden = YES;
                self.locateButton.enabled = YES;
            });
        }
        
        // Clear the map - but let's keep pins that are within our new range to potentially reduce the number of requests.
        // There could be a lot of pins, so let's loop on the background thread - but the removal of pins needs to be done on the main thread.
        for (NSNumber *ip in [self.placedPins allKeys]) {
            long ipLong = [ip longValue];
            if (ipLong < startInt || ipLong > endInt) {
                MKPointAnnotation *annotation = self.placedPins[ip];
                //NSLog(@"Removed annotation for IP: %@", annotation.title);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mapView removeAnnotation:annotation];
                });
                [self.placedPins removeObjectForKey:ip];
            }
        }
    });
}

- (void)dropPinAtLongitude:(double)longitude andLatitude:(double)latitude forIPAddress:(NSString *)ip withSubtitle:(NSString *)subtitle {
    CLLocationCoordinate2D location;
    location.latitude = latitude;
    location.longitude = longitude;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.title = ip;
    annotation.subtitle = subtitle;
    [annotation setCoordinate:location];
    [self.mapView addAnnotation:annotation];
    
    // Add it to our dictionary.
    [self.placedPins setObject:annotation forKey:@([IPHelper longFromIP:ip])];
    
    // If it's the first annotation, let's take the user there so it doesn't appear that nothing happened if the pins are off the screen.
    if (self.mapView.annotations.count == 1) {
        [self zoomToPin:annotation];
    }
    
    // If it's the last annotation (i.e. the request queue is empty) we should stop the spinner and make the button pressable again.
    if (self.requestQueue.count == 0) {
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
        self.locateButton.enabled = YES;
    }
}

- (void)connectionDidEncounterError:(NSError *)error {
    // Show an alert
    if (!self.hasPromptedWithConnectionError) {
        self.hasPromptedWithConnectionError = YES;
        [self showAlertWithMessage:[NSString stringWithFormat:@"%@ Some data may not be loaded.", error.localizedDescription]];
    }
    
    // If the queue is empty, this was the last request and we should indicate this on the UI.
    if (self.requestQueue.count == 0) {
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
        self.locateButton.enabled = YES;
    }
}

- (void)zoomToPin:(MKPointAnnotation *)pin {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 100.0;
    span.longitudeDelta = 100.0;
    region.span = span;
    region.center = pin.coordinate;
    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
