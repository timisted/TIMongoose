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

#import "mongoose.h"
#import "TIMongooseOperation.h"

#pragma mark Forward Declarations
@class TIMongooseEngine, TIMongooseDataProvider;

#pragma mark -
#pragma mark ___TIMongooseEngineDelegate Definition___
@protocol TIMongooseEngineDelegate
@optional
/* Mongoose Engine information methods relating to start, stop and failure */
- (void)mongooseEngineAboutToStartMongoose:(TIMongooseEngine *)engine;
- (void)mongooseEngineFailedToStartMongoose:(TIMongooseEngine *)engine;
- (void)mongooseEngine:(TIMongooseEngine *)engine failedToSetPorts:(NSString *)ports;
- (void)mongooseEngine:(TIMongooseEngine *)engine didStartMongooseOnPorts:(NSString *)ports;
- (void)mongooseEngine:(TIMongooseEngine *)engine didStartListeningOnIPAddress:(NSString *)ipAddress;
- (void)mongooseEngineAboutToStopMongoose:(TIMongooseEngine *)engine;
- (void)mongooseEngineDidStopMongoose:(TIMongooseEngine *)engine;
@end

#pragma mark -
#pragma mark ___TIMongooseEngine Interface___
@interface TIMongooseEngine : NSObject <TIMongooseOperationDelegate> {
@private
    NSObject <TIMongooseEngineDelegate> *_delegate;
    struct mg_context *_mongooseContext;
    TIMongooseOperation *_mongooseOperation;
    NSOperationQueue *_operationQueue;
}

#pragma mark Designated Intializer
/* The delegate must conform to the TIMongooseEngineDelegate protocol, though
   none of the methods are required. */
- (id)initWithDelegate:(NSObject <TIMongooseEngineDelegate>*)aDelegate;

#pragma mark Server Setup
/* By default, the server works with only one data provider, used for any requested 
   host domain/IP etc. Set supportsNameBasedVirtualHosts to YES to work with one
   data provider per requested host. */
- (void)setSupportsNameBasedVirtualHosts:(BOOL)aBool;
- (BOOL)supportsNameBasedVirtualHosts;

#pragma mark Data Providers
/* Use these methods for non-virtual-domain-based hosting.
   The data provider will be used for any host requested.
   Also use this method to specify a provider for IP-based requests. */
- (void)setDataProvider:(TIMongooseDataProvider *)aProvider;
- (TIMongooseDataProvider *)dataProvider;

/* Use these methods for virtual-domain-based hosting.
   To specify the default provider, use the methods above. */
- (void)setDataProvider:(TIMongooseDataProvider *)aProvider forHost:(NSString *)aHost;
- (TIMongooseDataProvider *)dataProviderForHost:(NSString *)aHost;

#pragma mark Server Controls
/* Set the path of an SSL certificate. Must be used before starting Mongoose on a secure
   port like 443. */
- (void)setSslCertificateFilePath:(NSString *)aPath;

/* Each of these methods returns immediately; use the delegate callbacks to determine
   whether the start/stop completed successfully. */
- (void)startMongooseOnPort:(int)aPort;

/* Provide a list of ports, ending with 0. */
- (void)startMongooseOnPorts:(int)firstPort, ...;

/* Provide a string containing a comma-separated list of ports (not ending with a 0). */
- (void)startMongooseOnPortsInString:(NSString *)aPortString;

- (void)stopMongoose;
- (void)restartMongoose;

#pragma mark Miscellaneous
/* Returns the local ip address of the machine; works on iPhone, Simulator and Mac Desktop.
   Will return an external ip if available. */
- (NSString *)localIPAddress;

#pragma mark Properties
@property (nonatomic, assign) struct mg_context *mongooseContext;
@property (nonatomic, assign) NSObject <TIMongooseEngineDelegate> *delegate;
@property (retain) TIMongooseOperation *mongooseOperation;
@property (retain) NSOperationQueue *operationQueue;

@end


// Needed to shut-up compiler warnings on simulator :(
#if TARGET_IPHONE_SIMULATOR
@interface NSHost
+ (NSHost *)currentHost;
- (NSArray *)addresses;
@end
#endif