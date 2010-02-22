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

#import "FlipsideViewController.h"
#import "TIMongooseEngine.h"

@class MyMongooseDataProvider, TIMongooseFileBasedDataProvider;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, TIMongooseEngineDelegate, UIAlertViewDelegate> {
    UILabel *_startStoppedLabel;
    UISegmentedControl *_stopRestartSegmentedControl;
    UISegmentedControl *_startSegmentedControl;
    UILabel *_ipAddressLabelLabel;
    UILabel *_ipAddressLabel;
    UILabel *_portsLabelLabel;
    UILabel *_portsLabel;
    
    TIMongooseEngine *_mongooseEngine;
    MyMongooseDataProvider *_mongooseDataProvider;
    TIMongooseFileBasedDataProvider *_mongooseFileBasedDataProvider;
}

@property (nonatomic, retain) IBOutlet UILabel *startStoppedLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *stopRestartSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *startSegmentedControl;
@property (nonatomic, retain) IBOutlet UILabel *ipAddressLabel;
@property (nonatomic, retain) IBOutlet UILabel *ipAddressLabelLabel;
@property (nonatomic, retain) IBOutlet UILabel *portsLabel;
@property (nonatomic, retain) IBOutlet UILabel *portsLabelLabel;
@property (nonatomic, readonly) TIMongooseEngine *mongooseEngine;
@property (retain) MyMongooseDataProvider *mongooseDataProvider;
@property (retain) TIMongooseFileBasedDataProvider *mongooseFileBasedDataProvider;

- (IBAction)showInfo;
- (IBAction)startStopAction:(id)sender;

@end
