// Copyright (c) 2010 Tim Isted
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MainViewController.h"
#import "MainView.h"
#import "TIMongoose.h"
#import "MyMongooseDataProvider.h"

#pragma mark ___MainViewController Implementation___
@implementation MainViewController

@synthesize startStoppedLabel = _startStoppedLabel;
@synthesize stopRestartSegmentedControl = _stopRestartSegmentedControl, startSegmentedControl = _startSegmentedControl;
@synthesize ipAddressLabel = _ipAddressLabel, portsLabel = _portsLabel;
@synthesize ipAddressLabelLabel = _ipAddressLabelLabel, portsLabelLabel = _portsLabelLabel;
@synthesize mongooseDataProvider = _mongooseDataProvider, mongooseFileBasedDataProvider = _mongooseFileBasedDataProvider;

#pragma mark -
#pragma mark Accessors
- (MyMongooseDataProvider *)mongooseDataProvider
{
    if( !_mongooseDataProvider ) {
        _mongooseDataProvider = [[MyMongooseDataProvider alloc] init];
    }
    
    return _mongooseDataProvider;
}

- (TIMongooseFileBasedDataProvider *)mongooseFileBasedDataProvider
{
    if( !_mongooseFileBasedDataProvider ) {
        _mongooseFileBasedDataProvider = [[TIMongooseFileBasedDataProvider alloc] init];
    }
    
    return _mongooseFileBasedDataProvider;
}

- (TIMongooseEngine *)mongooseEngine
{
    if( !_mongooseEngine ) {
        _mongooseEngine = [[TIMongooseEngine alloc] initWithDelegate:self];
        [_mongooseEngine setDataProvider:[self mongooseDataProvider]];
        [_mongooseEngine setSupportsNameBasedVirtualHosts:YES];
        [_mongooseEngine setDataProvider:[self mongooseDataProvider] forHost:@"mongoose.local"];
        [_mongooseEngine setDataProvider:[self mongooseFileBasedDataProvider] forHost:@"mongooseFile.local"];
    }
    
    return _mongooseEngine;
}

- (void)dealloc
{
    [_mongooseEngine release];
    [_mongooseDataProvider release];
    [_mongooseFileBasedDataProvider release];
    [_startStoppedLabel release];
    [_stopRestartSegmentedControl release];
    [_startSegmentedControl release];
    [_ipAddressLabel release];
    [_ipAddressLabelLabel release];
    [_portsLabel release];
    [_portsLabelLabel release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[self mongooseEngine] stopMongoose];
}

#pragma mark -
#pragma mark Actions
- (void)_setEnabled:(BOOL)shouldEnable allSegmentsForSegmentedControl:(UISegmentedControl *)aControl
{
    for( int i = 0; i < [aControl numberOfSegments]; i++ )
        [aControl setEnabled:shouldEnable forSegmentAtIndex:i];
}

- (void)_disableControls
{
    [self _setEnabled:NO allSegmentsForSegmentedControl:[self startSegmentedControl]];
    [self _setEnabled:NO allSegmentsForSegmentedControl:[self stopRestartSegmentedControl]];
}

- (void)_enableControls
{
    [self _setEnabled:YES allSegmentsForSegmentedControl:[self startSegmentedControl]];
    [self _setEnabled:YES allSegmentsForSegmentedControl:[self stopRestartSegmentedControl]];
}

- (IBAction)startStopAction:(id)sender
{
    if( sender == [self stopRestartSegmentedControl] ) {
        switch( [sender selectedSegmentIndex] ) {
            case 0: // Stop
                [[self mongooseEngine] stopMongoose];
                break;
            
            case 1: // Restart
                [[self mongooseEngine] restartMongoose];
                break;
        }
    }
    else if( sender == [self startSegmentedControl] ) {
        switch( [sender selectedSegmentIndex] ) {
            case 0: // Start
                [[self mongooseEngine] startMongooseOnPortsInString:[[NSUserDefaults standardUserDefaults] valueForKey:@"kMongoosePorts"]];
                //[self.mongooseEngine startMongooseOnPorts:8080,4343,7863,7953,0];
                break;
        }
    }
}

#pragma mark -
#pragma mark TIMongooseEngine Delegate Methods
- (void)mongooseEngineAboutToStartMongoose:(TIMongooseEngine *)engine
{
    //NSLog(@"Mongoose Engine about to start");
    [self _disableControls];
}

- (void)mongooseEngineFailedToStartMongoose:(TIMongooseEngine *)engine
{
    NSLog(@"Failed to start mongoose engine");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Sorry, couldn't start\nthe server." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [self _enableControls];
}

- (void)mongooseEngine:(TIMongooseEngine *)engine failedToSetPorts:(NSString *)ports
{
    NSLog(@"Failed to set ports so stopping server");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Sorry, couldn't use the\nspecified port(s).\nPlease set a different port\nand try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [[self mongooseEngine] stopMongoose];
}

- (void)mongooseEngine:(TIMongooseEngine *)engine didStartMongooseOnPorts:(NSString *)ports
{
    //NSLog(@"Mongoose Engine started on ports: %@", ports);
    [[self startStoppedLabel] setText:NSLocalizedString(@"Running", @"Running")];
    [[self startStoppedLabel] setTextColor:[UIColor greenColor]];
    [[self startSegmentedControl] setHidden:YES];
    [[self stopRestartSegmentedControl] setHidden:NO];
    [[self portsLabel] setText:ports];
    [[self portsLabelLabel] setHidden:NO];
    [[self portsLabel] setHidden:NO];
    [self _enableControls];
}

- (void)mongooseEngine:(TIMongooseEngine *)engine didStartListeningOnIPAddress:(NSString *)ipAddress
{
    //NSLog(@"Mongoose Engine started on ip address: %@", ipAddress);
    [[self ipAddressLabel] setText:ipAddress];
    [[self ipAddressLabelLabel] setHidden:NO];
    [[self ipAddressLabel] setHidden:NO];
}

- (void)mongooseEngineAboutToStopMongoose:(TIMongooseEngine *)engine
{
    //NSLog(@"Mongoose Engine about to stop");
    [self _disableControls];
}

- (void)mongooseEngineDidStopMongoose:(TIMongooseEngine *)engine
{
    //NSLog(@"Mongoose Engine stopped");
    [[self startStoppedLabel] setText:NSLocalizedString(@"Stopped", @"Stopped")];
    [[self startStoppedLabel] setTextColor:[UIColor redColor]];
    [[self stopRestartSegmentedControl] setHidden:YES];
    [[self startSegmentedControl] setHidden:NO];
    [[self portsLabel] setHidden:YES];
    [[self portsLabelLabel] setHidden:YES];
    [[self ipAddressLabel] setHidden:YES];
    [[self ipAddressLabelLabel] setHidden:YES];
    
    [self _enableControls];
}

#pragma mark -
#pragma mark Flipside View
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo
{	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

@end
