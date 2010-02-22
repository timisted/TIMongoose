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

#import "MyMongooseDataProvider.h"
#import "TIMongoose.h"

#pragma mark ___MyMongooseDataProvider Implemenation___
@implementation MyMongooseDataProvider

#pragma mark Initial Setup
- (void)setUpSelectors
{
    [self addSelector:@selector(rootResponseForRequest:) forRouteMatchingString:@"/"];
    [self addSelector:@selector(imageResponseForRequest:) forRouteMatchingString:@"/[abi]mage"];
    [self addSelector:@selector(myResponseForErrorCode:request:) forErrorCode:TIMongooseHTTPResponseType404NotFound];
}

#pragma mark Response Generation
- (TIMongooseResponse *)rootResponseForRequest:(TIMongooseRequest *)aRequest
{
    return [TIMongooseResponse
             mongooseResponseWithStatusCode:TIMongooseHTTPResponseType200OK
             contentType:TIMongooseResponseContentTypeTextHTML
             responseString:@"Hello, my name is Mr Mongoose"];
}

- (TIMongooseResponse *)imageResponseForRequest:(TIMongooseRequest *)aRequest
{
    return [TIMongooseResponse 
             mongooseResponseWithStatusCode:TIMongooseHTTPResponseType200OK
             contentType:TIMongooseResponseContentTypeImageJPEG
             responseData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kitteh" ofType:@"jpg"]]];
}

- (TIMongooseResponse *)myResponseForErrorCode:(NSNumber *)aCode request:(TIMongooseRequest *)aRequest
{
    NSString *dataString = [NSString stringWithFormat:
                            @"<html><head><title>Mongoose Had a Problem</title></head><body style='text-align:center;'><p><img src='/mongoo.jpg'></p><h1>Sorry, Mongoose couldn't find your file.</h1></body></html>", aCode];
    return [TIMongooseResponse 
            mongooseResponseWithStatusCode:[aCode intValue]
            contentType:TIMongooseResponseContentTypeTextHTML
            responseString:dataString];
}

@end
