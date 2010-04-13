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
#import "TIMongooseRequest.h"

#pragma mark Forward Declarations
@protocol TIMongooseOperationDelegate;
@class TIMongooseDataProvider;

#pragma mark -
#pragma mark ___TIMongooseOperation Interface___
@interface TIMongooseOperation : NSOperation {
@private
    NSObject <TIMongooseOperationDelegate> *_delegate;
    struct mg_context *_mongooseContext;
    NSString *_ports;
    NSString *_sslCertificatePath;
    NSMutableDictionary *_dataProviders;
    BOOL _supportsNameBasedVirtualHosts;
    
    BOOL _shouldStart;
    BOOL _shouldStop;
    BOOL _shouldRestart;
}

#pragma mark Designated Initializer
- (id)initWithDelegate:(NSObject *)aDelegate;

#pragma mark Data Providers
- (void)setDataProvider:(TIMongooseDataProvider *)aProvider;
- (TIMongooseDataProvider *)dataProvider;
- (void)setDataProvider:(TIMongooseDataProvider *)aProvider forHost:(NSString *)aHost;
- (TIMongooseDataProvider *)dataProviderForHost:(NSString *)aHost;

#pragma mark Properties
@property (assign) NSObject <TIMongooseOperationDelegate> *delegate;
@property (assign) BOOL supportsNameBasedVirtualHosts;
@property (assign) struct mg_context *mongooseContext;
@property (retain) NSString *ports;
@property (retain) NSString *sslCertificatePath;
@property (assign) BOOL shouldStart, shouldStop, shouldRestart;

@end

#pragma mark -
#pragma mark ___TIMongooseOperationDelegate Definition___
@protocol TIMongooseOperationDelegate

- (void)handleMongooseOperationDelegateMessage:(NSDictionary *)dictionary;

@end

#pragma mark -
#pragma mark Enums and String Constants
typedef enum _TIMongooseOperationDelegateMessageType {
    TIMongooseOperationDelegateMessageTypeUnknown = 0,
    TIMongooseOperationDelegateMessageTypeAboutToStartMongoose,
    TIMongooseOperationDelegateMessageTypeFailedToStartMongoose,
    TIMongooseOperationDelegateMessageTypeFailedToSetPorts,
    TIMongooseOperationDelegateMessageTypeStartedMongoose,
    TIMongooseOperationDelegateMessageTypeAboutToStopMongoose,
    TIMongooseOperationDelegateMessageTypeStoppedMongoose
} TIMongooseOperationDelegateMessageType;

extern NSString * const kMongooseOperationObject;
extern NSString * const kMongooseDelegateMessageType;
extern NSString * const kMongoosePorts;