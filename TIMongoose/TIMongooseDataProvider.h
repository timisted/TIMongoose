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

#import "TIMongooseBasicDataProviderMethods.h"

#pragma mark Forward Declarations
@class TIMongooseResponse, TIMongooseRequest;

#pragma mark -
#pragma mark ___TIMongooseDataProvider Interface___
@interface TIMongooseDataProvider : NSObject <TIMongooseBasicDataProviderMethods> {
@private
    NSMutableArray *_routingSelectors;
    NSMutableArray *_errorSelectors;
}

#pragma mark -
#pragma mark Adding and Removing Selectors
/* setUpSelectors will be called automatically when the MongooseDataProvider is created.
   Override this method and call addSelector:forRouteMatchingString: for each route you need,
   and addSelector:forHttpErrorCode: for each error you wish to handle yourself. */
- (void)setUpSelectors;

#pragma mark Route Selectors
/* Selectors should have this method signature:
   - (TIMongooseResponse *)responseForRequest:(TIMongooseRequest *)aRequest */
- (void)addSelector:(SEL)aSelector forRouteMatchingString:(NSString *)aString;

/* Selectors will be matched using NSPredicate regex; i.e.
   [[NSPredicate predicateWithFormat:@"SELF MATCHES <string>"] evaluateWithObject:aRoute]; */
- (SEL)selectorForRoute:(NSString *)aRoute;

/* You must supply the route match string used in addSelector:forRouteMatchingString: 
   to remove a selector. */
- (void)removeSelectorForRouteMatchingString:(NSString *)aString;

#pragma mark Error Selectors
/* Selectors should have this method signature:
   - (TIMongooseResponse *)responseForErrorCode:(NSNumber *)aCode request:(TIMongooseRequest *)aRequest */
- (void)addSelector:(SEL)aSelector forErrorCode:(int)aCode;

- (SEL)selectorForErrorCode:(int)aCode;

- (void)removeSelectorForErrorCode:(int)aCode;

#pragma mark Mongoose Response Methods
/* By default, this method will search for a suitable selector for the request's URI,
   and call mongooseResponseForHttpErrorCode:404 fromRequest:... if it can't find one.
   Override mongooseResponseForRequest: to generate your own route responses. */
- (TIMongooseResponse *)mongooseResponseForRequest:(TIMongooseRequest *)aRequest;

/* By default, this method will search for a suitable selector for the error code,
   or generate standard error pages if it can't find one.
   Override to mongooseResponseForHttpErrorCode:fromRequest: to generate your own. */
- (TIMongooseResponse *)mongooseResponseForHttpErrorCode:(int)aCode fromRequest:(TIMongooseRequest *)aRequest;

/* If you don't provide any error selectors, this method will generate a generic response. */
- (TIMongooseResponse *)genericResponseForErrorCode:(NSNumber *)aCode request:(TIMongooseRequest *)aRequest;

@end
