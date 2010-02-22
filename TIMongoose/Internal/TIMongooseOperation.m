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

#import "TIMongooseOperation.h"
#import "TIMongoose.h"
#import "NSString+TIMongooseAdditions.h"

#pragma mark Class Extensions (Private Methods)
@interface TIMongooseOperation ()

- (void)_notifyMongooseAboutToStart; 
- (void)_notifyMongooseFailedToStart;
- (void)_notifyMongooseFailedToSetPorts:(NSString *)ports;
- (void)_notifyMongooseStartedOnPorts:(NSString *)ports;
- (void)_notifyMongooseAboutToStop;
- (void)_notifyMongooseStopped;
- (void)_startMongoose;
- (void)_stopMongoose;
- (void)_restartMongoose;

- (TIMongooseDataProvider *)_dataProviderForRequest:(TIMongooseRequest *)aRequest;
- (TIMongooseDataProvider *)_defaultProvider;

@end

#pragma mark Dictionary Constants
NSString * const kTIMongooseDefaultHostDataProvider = @"kTIMongooseDefaultHostDataProvider";

#pragma mark -
#pragma mark ___TIMongooseOperation Implementation___
@implementation TIMongooseOperation

@synthesize delegate = _delegate, mongooseContext = _mongooseContext, ports = _ports, supportsNameBasedVirtualHosts = _supportsNameBasedVirtualHosts;
@synthesize shouldStart = _shouldStart, shouldStop = _shouldStop, shouldRestart = _shouldRestart;

#pragma mark -
#pragma mark Initialization and Deallocation
- (id)initWithDelegate:(NSObject *)aDelegate
{
    if( self = [super init] ) {
        _delegate = aDelegate;
        _dataProviders = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    return self;
}

- (id)init {
    return [self initWithDelegate:nil];
}

- (void)dealloc {
    [_ports release]; _ports = nil;
    [_dataProviders release]; _dataProviders = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Main Function
-(void)main {
    @try {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        while( YES ) {
            if ( [self isCancelled] ) return;
            
            if( [self shouldStop] ) { [self _stopMongoose]; [self setShouldStop:NO]; }
            
            if( [self shouldStart] ) { [self _startMongoose]; [self setShouldStart:NO]; }
            
            if( [self shouldRestart] ) { [self _restartMongoose]; [self setShouldRestart:NO]; }
            
            sleep(1);
        }
        
        [pool release];
    }
    @catch(...) {
        // Do not rethrow
    }
}

#pragma mark -
#pragma mark Callbacks
static void http_request_callback(struct mg_connection *conn,
           const struct mg_request_info *request_info,
           void *user_data)
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    
    TIMongooseRequest *mongooseRequest = [TIMongooseRequest mongooseRequestWithMGRequestInfo:request_info];
    TIMongooseOperation *mongooseOperation = user_data;
    TIMongooseResponse *mongooseResponse = [[mongooseOperation _dataProviderForRequest:mongooseRequest] mongooseResponseForRequest:mongooseRequest];
    
    if( [[mongooseResponse headersForOutput] length] > 0 )
       mg_printf(conn, [[mongooseResponse headersForOutput] UTF8String]);
    
    if( [[mongooseResponse dataForOutput] length] > 0 )
        mg_write(conn, [[mongooseResponse dataForOutput] bytes], [[mongooseResponse dataForOutput] length]);

    [pool release];
}

static void http_error_callback(struct mg_connection *conn,
                                  const struct mg_request_info *request_info,
                                  void *user_data)
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    TIMongooseRequest *mongooseRequest = [TIMongooseRequest mongooseRequestWithMGRequestInfo:request_info];
    TIMongooseOperation *mongooseOperation = user_data;
    TIMongooseResponse *mongooseResponse = [[mongooseOperation _dataProviderForRequest:mongooseRequest] mongooseResponseForHttpErrorCode:request_info->status_code fromRequest:mongooseRequest];
    
    if( [[mongooseResponse headersForOutput] length] > 0 )
        mg_printf(conn, [[mongooseResponse headersForOutput] UTF8String]);
    
    if( [[mongooseResponse dataForOutput] length] > 0 )
        mg_write(conn, [[mongooseResponse dataForOutput] bytes], [[mongooseResponse dataForOutput] length]);
    
    [pool release];
}

#pragma mark -
#pragma mark Data Providers
- (TIMongooseDataProvider *)_dataProviderForRequest:(TIMongooseRequest *)aRequest
{
    TIMongooseDataProvider *dataProvider = nil;
    if( [self supportsNameBasedVirtualHosts] && ![[aRequest hostDomain] tiM_IsIPAddress] > 0 )
        dataProvider = [self dataProviderForHost:[aRequest hostDomain]];
    else
        dataProvider = [self dataProvider];
    
    return dataProvider;
}

- (TIMongooseDataProvider *)_defaultProvider
{
    static TIMongooseDataProvider *sBasicProvider = nil;
    if( !sBasicProvider ) sBasicProvider = [[TIMongooseDataProvider alloc] init];
    return sBasicProvider;
}

- (void)setDataProvider:(TIMongooseDataProvider *)aProvider
{
    if( aProvider )
        [_dataProviders setObject:aProvider forKey:kTIMongooseDefaultHostDataProvider];
    else
        [_dataProviders removeObjectForKey:kTIMongooseDefaultHostDataProvider];
}

- (TIMongooseDataProvider *)dataProvider
{
    TIMongooseDataProvider *provider = [_dataProviders objectForKey:kTIMongooseDefaultHostDataProvider];
    return provider ? : [self _defaultProvider];
}

- (void)setDataProvider:(TIMongooseDataProvider *)aProvider forHost:(NSString *)aHost
{
    if( aProvider )
        [_dataProviders setObject:aProvider forKey:[aHost lowercaseString]];
    else
        [_dataProviders removeObjectForKey:[aHost lowercaseString]];
}

- (TIMongooseDataProvider *)dataProviderForHost:(NSString *)aHost
{
    TIMongooseDataProvider *provider = [_dataProviders objectForKey:[aHost lowercaseString]];
    
    return provider ? : [self _defaultProvider];
}

#pragma mark -
#pragma mark Mongoose Control
- (void)_startMongoose
{
    [self _notifyMongooseAboutToStart];
    [self setMongooseContext:mg_start()];
    
    if( ![self mongooseContext] ) {
        [self _notifyMongooseFailedToStart]; return;
    }
    
    if( !mg_set_option([self mongooseContext], "ports", [[self ports] UTF8String]) ) {
        [self _notifyMongooseFailedToSetPorts:[self ports]]; return;
    }
    mg_set_uri_callback([self mongooseContext], "*", &http_request_callback, self);
    mg_set_error_callback([self mongooseContext], 0, &http_error_callback, self);
    //NSLog(@"Mongoose Started");
    [self _notifyMongooseStartedOnPorts:[self ports]];
}

- (void)_stopMongoose
{
    [self _notifyMongooseAboutToStop];
    mg_stop([self mongooseContext]);
    //NSLog(@"Mongoose Stopped");
    [self _notifyMongooseStopped];
}

- (void)_restartMongoose
{
    [self _stopMongoose];
    
    sleep(1);
    
    [self _startMongoose];
    //NSLog(@"Mongoose Restarted");
}

#pragma mark -
#pragma mark Talking to the Delegate
- (void)_notifyMongooseAboutToStart
{
    NSDictionary *mongooseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self, kMongooseOperationObject,
                                        [NSNumber numberWithInt:TIMongooseOperationDelegateMessageTypeAboutToStartMongoose], kMongooseDelegateMessageType,
                                        nil];
    
    [[self delegate] performSelectorOnMainThread:@selector(handleMongooseOperationDelegateMessage:) withObject:mongooseDictionary waitUntilDone:NO];
}

- (void)_notifyMongooseFailedToStart
{
    NSDictionary *mongooseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self, kMongooseOperationObject,
                                        [NSNumber numberWithInt:TIMongooseOperationDelegateMessageTypeFailedToStartMongoose], kMongooseDelegateMessageType,
                                        nil];
    
    [[self delegate] performSelectorOnMainThread:@selector(handleMongooseOperationDelegateMessage:) withObject:mongooseDictionary waitUntilDone:NO];
    
}

- (void)_notifyMongooseFailedToSetPorts:(NSString *)ports
{
    NSDictionary *mongooseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self, kMongooseOperationObject,
                                        [NSNumber numberWithInt:TIMongooseOperationDelegateMessageTypeFailedToSetPorts], kMongooseDelegateMessageType,
                                        ports, kMongoosePorts,
                                        nil];
    
    [[self delegate] performSelectorOnMainThread:@selector(handleMongooseOperationDelegateMessage:) withObject:mongooseDictionary waitUntilDone:NO];    
}

- (void)_notifyMongooseStartedOnPorts:(NSString *)ports
{
    NSDictionary *mongooseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self, kMongooseOperationObject,
                                    [NSNumber numberWithInt:TIMongooseOperationDelegateMessageTypeStartedMongoose], kMongooseDelegateMessageType,
                                    ports, kMongoosePorts,
                                    nil];
    
    [[self delegate] performSelectorOnMainThread:@selector(handleMongooseOperationDelegateMessage:) withObject:mongooseDictionary waitUntilDone:NO];
}

- (void)_notifyMongooseAboutToStop
{
    NSDictionary *mongooseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self, kMongooseOperationObject,
                                        [NSNumber numberWithInt:TIMongooseOperationDelegateMessageTypeAboutToStopMongoose], kMongooseDelegateMessageType,
                                        nil];
    
    [[self delegate] performSelectorOnMainThread:@selector(handleMongooseOperationDelegateMessage:) withObject:mongooseDictionary waitUntilDone:NO];
}

- (void)_notifyMongooseStopped
{
    NSDictionary *mongooseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self, kMongooseOperationObject,
                                        [NSNumber numberWithInt:TIMongooseOperationDelegateMessageTypeStoppedMongoose], kMongooseDelegateMessageType,
                                        nil];
    
    [[self delegate] performSelectorOnMainThread:@selector(handleMongooseOperationDelegateMessage:) withObject:mongooseDictionary waitUntilDone:NO];
}

@end

#pragma mark -
#pragma mark Delegate Dictionary Keys
NSString * const kMongooseOperationObject = @"kMongooseOperationObject";
NSString * const kMongooseDelegateMessageType = @"kMongooseDelegateMessageType";
NSString * const kMongoosePorts = @"kMongoosePorts";