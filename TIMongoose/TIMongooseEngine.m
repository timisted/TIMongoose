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

#import "TIMongoose.h"
#import "TIMongooseOperation.h"
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#pragma mark ___TIMongooseEngine Implementation___
@implementation TIMongooseEngine
@synthesize mongooseContext = _mongooseContext, delegate = _delegate;
@synthesize mongooseOperation = _mongooseOperation, operationQueue = _operationQueue;

#pragma mark -
#pragma mark Initialization and Deallocation
- (id)initWithDelegate:(NSObject <TIMongooseEngineDelegate>*)aDelegate
{
    self = [super init];
    if( !self ) return nil;
    
    _delegate = aDelegate;
    _operationQueue = [[NSOperationQueue alloc] init];
    
    return self;
}

- (void)dealloc
{
    [[self operationQueue] cancelAllOperations];
    [_operationQueue release]; _operationQueue = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Server Config
- (void)setSupportsNameBasedVirtualHosts:(BOOL)aBool
{
    [[self mongooseOperation] setSupportsNameBasedVirtualHosts:aBool];
}

- (BOOL)supportsNameBasedVirtualHosts
{
    return [[self mongooseOperation] supportsNameBasedVirtualHosts];
}

#pragma mark Data Providers
- (void)setDataProvider:(TIMongooseDataProvider *)aProvider
{
    [[self mongooseOperation] setDataProvider:aProvider];
}

- (TIMongooseDataProvider *)dataProvider
{
    return [[self mongooseOperation] dataProvider];
}

- (void)setDataProvider:(TIMongooseDataProvider *)aProvider forHost:(NSString *)aHost
{
    [[self mongooseOperation] setDataProvider:aProvider forHost:aHost];
}

- (TIMongooseDataProvider *)dataProviderForHost:(NSString *)aHost
{
    return [[self mongooseOperation] dataProviderForHost:aHost];
}

#pragma mark -
#pragma mark Accessor Methods
- (TIMongooseOperation *)mongooseOperation
{
    @synchronized( _mongooseOperation ) {
    if( _mongooseOperation ) return _mongooseOperation;
    
    _mongooseOperation = [[TIMongooseOperation alloc] initWithDelegate:self];
    
    [[self operationQueue] addOperation:_mongooseOperation];
    
    return _mongooseOperation;
    }
}

// Return the localized IP address - iPhone version from Erica Sadun's cookbook
- (NSString *)localIPAddress
{
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    char baseHostName[255];
    int success = gethostname(baseHostName, 255);
    if( success != 0 ) return nil;
    baseHostName[255] = '\0';
    
    NSString *hostname = [NSString stringWithFormat:@"%s.local", baseHostName];
    struct hostent *host = gethostbyname([hostname UTF8String]);
    if( !host ) {
        herror("resolv"); return nil;
    }
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];    
#elif TARGET_OS_MAC
    // Use a predicate to match IP address out of [[NSHost currentHost] addresses], then returns
    // the first one that isn't the local
    NSString *ipRegex = @"(\[0-9]{1,3})\\.(\[0-9]{1,3})\\.(\[0-9]{1,3})\\.(\[0-9]{1,3})";
    NSPredicate *regexPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipRegex];
    for( NSString *eachAddress in [[NSHost currentHost] addresses] ) {
        if( [regexPred evaluateWithObject:eachAddress] && ![eachAddress isEqualToString:@"127.0.0.1"] )
            return eachAddress;
    }
    return @"127.0.0.1";
#else
    return nil;
#endif 
}

#pragma mark -
#pragma mark Mongoose Control
- (void)setSslCertificateFilePath:(NSString *)aPath
{
    [[self mongooseOperation] setSslCertificatePath:aPath];
}

- (void)startMongooseOnPort:(int)aPort
{
    [self startMongooseOnPorts:aPort, 0];
}

- (void)startMongooseOnPorts:(int)firstPort, ...
{
    NSMutableString *portsString = [NSMutableString string];
    
    int eachPort = 0;
    va_list argumentList;
    if (firstPort)                      // The first argument isn't part of the varargs list,
    {                                   // so we'll handle it separately.
        [portsString appendFormat:@"%i,", firstPort];
        va_start(argumentList, firstPort);          // Start scanning for arguments after firstObject.
        while( (eachPort = va_arg(argumentList, int)) ) // As many times as we can get an argument of type "id"
            [portsString appendFormat:@"%i,", eachPort];               // that isn't nil, add it to self's contents.
        va_end(argumentList);
    }
    
    [self startMongooseOnPortsInString:portsString];
}

- (void)startMongooseOnPortsInString:(NSString *)aPortsString
{
    [[self mongooseOperation] setPorts:aPortsString];
    [[self mongooseOperation] setShouldStart:YES];
}

- (void)stopMongoose
{
    [[self mongooseOperation] setShouldStop:YES];
}

- (void)restartMongoose
{
    [[self mongooseOperation] setShouldRestart:YES];
}

- (BOOL)isRunning
{
    return [[self mongooseOperation] mongooseServerIsRunning];
}

#pragma mark -
#pragma mark TIMongooseOperation Delegate Messages
- (void)handleMongooseOperationDelegateMessage:(NSDictionary *)dictionary
{
    NSNumber *num = [dictionary valueForKey:kMongooseDelegateMessageType];
    TIMongooseOperationDelegateMessageType messageType = [num intValue];
    
    switch (messageType) {
        case TIMongooseOperationDelegateMessageTypeAboutToStartMongoose:
            if( [[self delegate] respondsToSelector:@selector(mongooseEngineAboutToStartMongoose:)] )
                [[self delegate] mongooseEngineAboutToStartMongoose:self];
            break;
        
        case TIMongooseOperationDelegateMessageTypeFailedToStartMongoose:
            if( [[self delegate] respondsToSelector:@selector(mongooseEngineFailedToStartMongoose:)] )
                [[self delegate] mongooseEngineFailedToStartMongoose:self];
            break;
            
        case TIMongooseOperationDelegateMessageTypeFailedToSetPorts:
            if( [[self delegate] respondsToSelector:@selector(mongooseEngine:failedToSetPorts:)] )
                [[self delegate] mongooseEngine:self failedToSetPorts:[dictionary valueForKey:kMongoosePorts]];
            break;
            
        case TIMongooseOperationDelegateMessageTypeStartedMongoose:
            if( [[self delegate] respondsToSelector:@selector(mongooseEngine:didStartMongooseOnPorts:)] )
                [[self delegate] mongooseEngine:self didStartMongooseOnPorts:[dictionary valueForKey:kMongoosePorts]];
            
            NSString *ipAddress = [self localIPAddress];
            if( ipAddress && [[self delegate] respondsToSelector:@selector(mongooseEngine:didStartListeningOnIPAddress:)] )
                [[self delegate] mongooseEngine:self didStartListeningOnIPAddress:ipAddress];
            break;
            
        case TIMongooseOperationDelegateMessageTypeAboutToStopMongoose:
            if( [[self delegate] respondsToSelector:@selector(mongooseEngineAboutToStopMongoose:)] )
                [[self delegate] mongooseEngineAboutToStopMongoose:self];
            break;
            
        case TIMongooseOperationDelegateMessageTypeStoppedMongoose:
            if( [[self delegate] respondsToSelector:@selector(mongooseEngineDidStopMongoose:)] )
                [[self delegate] mongooseEngineDidStopMongoose:self];
            break;
        
        case TIMongooseOperationDelegateMessageTypeUnknown:
        default:
            break;
    }
}

@end
