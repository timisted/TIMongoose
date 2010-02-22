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

#pragma mark Enums
typedef enum _TIMongooseRequestMethodType {
    TIMongooseRequestMethodTypeUnknown = 0,
    TIMongooseRequestMethodTypeGET = 1,
    TIMongooseRequestMethodTypePOST,
    TIMongooseRequestMethodTypePUT,
    TIMongooseRequestMethodTypeDELETE,
    TIMongooseRequestMethodTypeHEAD,
    TIMongooseRequestMethodTypeOPTIONS,
    TIMongooseRequestMethodTypeTRACE,
    TIMongooseRequestMethodTypeCONNECT
} TIMongooseRequestMethodType;

#pragma mark -
#pragma mark ___TIMongooseRequest Interface___
@interface TIMongooseRequest : NSObject {
@private
    const struct mg_request_info *_mg_info;
    
    NSString *_cachedHostDomain;
    int _cachedHostPort;
}

#pragma mark Designated Initializer
- (id)initWithMGRequestInfo:(const struct mg_request_info *)anMGRequestInfoStruct;

#pragma mark Class Factory Method
+ (id)mongooseRequestWithMGRequestInfo:(const struct mg_request_info *)anMGRequestInfoStruct;

#pragma mark Properties
@property (readonly) NSString *requestMethod;
@property (readonly) TIMongooseRequestMethodType requestMethodType;
@property (readonly) NSString *uri;
@property (readonly) NSString *httpVersion;
@property (readonly) NSString *queryString;
@property (readonly) NSData *postData;
@property (readonly) NSString *remoteUser;
@property (readonly) NSString *remoteIpAddress;
@property (readonly) int remotePort;
@property (readonly) int httpStatusCode;
@property (readonly) NSDictionary *headers;
@property (readonly) NSString *hostDomain;
@property (readonly) int hostPort;

@end




