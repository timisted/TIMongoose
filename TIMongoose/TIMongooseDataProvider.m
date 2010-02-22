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

#pragma mark ___TIMongooseSelector Interface___
@interface TIMongooseSelector : NSObject { SEL _selector; NSString *_routeString; NSPredicate *_routePredicate; int _errorCode; }
@property (assign) SEL selector;
@property (retain) NSString *routeString;
@property (retain) NSPredicate *routePredicate;
@property (assign) int errorCode;
- (id)initWithSelector:(SEL)aSelector forRouteMatchingString:(NSString *)aString;
- (id)initWithSelector:(SEL)aSelector forErrorCode:(int)aCode;
+ (id)mongooseSelectorWithSelector:(SEL)aSelector forRouteMatchingString:(NSString *)aString;
+ (id)mongooseSelectorWithSelector:(SEL)aSelector forErrorCode:(int)aCode;
@end

#pragma mark -
#pragma mark ___TIMongooseDataProvider Implementation___
@implementation TIMongooseDataProvider

#pragma mark -
#pragma mark Initialization and Deallocation
- (id)init
{
    if( self = [super init] )
    {
        _routingSelectors = [[NSMutableArray alloc] initWithCapacity:10];
        _errorSelectors = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    [self performSelector:@selector(setUpSelectors) withObject:nil afterDelay:0];
    
    return self;
}

- (void)dealloc
{
    [_routingSelectors release];
    [_errorSelectors release];
    [super dealloc];
}

#pragma mark -
#pragma mark Working with Selectors
- (void)setUpSelectors { } // overide to add your selectors

#pragma mark Route Selectors
- (void)addSelector:(SEL)aSelector forRouteMatchingString:(NSString *)aString
{
    [_routingSelectors addObject:[TIMongooseSelector mongooseSelectorWithSelector:aSelector forRouteMatchingString:aString]];
}

- (SEL)selectorForRoute:(NSString *)aRoute
{
    for( TIMongooseSelector *eachRoute in _routingSelectors ) {
        if( [[eachRoute routePredicate] evaluateWithObject:aRoute] ) {
            return [eachRoute selector];
        }
    }
    
    return nil;
}

- (void)removeSelectorForRouteMatchingString:(NSString *)aString
{
    NSArray *objectsToRemove = [_routingSelectors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.routeString == %@", aString]];
    
    [_routingSelectors removeObjectsInArray:objectsToRemove];
}

#pragma mark Error Selectors
- (void)addSelector:(SEL)aSelector forErrorCode:(int)aCode
{
    [_errorSelectors addObject:[TIMongooseSelector mongooseSelectorWithSelector:aSelector forErrorCode:aCode]];
}

- (SEL)selectorForErrorCode:(int)aCode
{
    for( TIMongooseSelector *eachRoute in _errorSelectors ) {
        if( [eachRoute errorCode] == aCode ) {
            return [eachRoute selector];
        }
    }
    return nil;
}

- (void)removeSelectorForErrorCode:(int)aCode
{
    NSArray *objectsToRemove = [_errorSelectors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.errorCode == %i", aCode]];
    
    [_errorSelectors removeObjectsInArray:objectsToRemove];    
}

#pragma mark -
#pragma mark Generating Responses
- (TIMongooseResponse *)mongooseResponseForRequest:(TIMongooseRequest *)aRequest
{
    SEL selector = [self selectorForRoute:aRequest.uri];
    
    if( selector )
        return [self performSelector:selector withObject:aRequest];
    else
        return [self mongooseResponseForHttpErrorCode:TIMongooseHTTPResponseType404NotFound fromRequest:aRequest];
}

- (TIMongooseResponse *)mongooseResponseForHttpErrorCode:(int)aCode fromRequest:(TIMongooseRequest *)aRequest
{
    SEL selector = [self selectorForErrorCode:aCode];
    
    if( !selector ) selector = @selector(genericResponseForErrorCode:request:);
    
    return [self performSelector:selector withObject:[NSNumber numberWithInt:aCode] withObject:aRequest];
}

- (TIMongooseResponse *)genericResponseForErrorCode:(NSNumber *)aCode request:(TIMongooseRequest *)aRequest
{
    NSString *dataString = [NSString stringWithFormat:
                            @"<HTML><HEAD><TITLE>HTML Error %i</TITLE></HEAD><BODY><H1>Error %i</H1><P>Sorry, an error occurred</P></BODY></HTML>", [aCode intValue], [aCode intValue]];
    return [TIMongooseResponse 
            mongooseResponseWithStatusCode:[aCode intValue]
            contentType:TIMongooseResponseContentTypeTextHTML
            responseData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

@end

#pragma mark -
#pragma mark ___TIMongooseSelector Implementation___
@implementation TIMongooseSelector
@synthesize selector = _selector, routeString = _routeString, routePredicate = _routePredicate, errorCode = _errorCode;

- (id)initWithSelector:(SEL)aSelector forRouteMatchingString:(NSString *)aString
{
    if( self = [super init] ) {
        _selector = aSelector;
        _routeString = [aString copy];
    }
    
    return self;
}

- (id)initWithSelector:(SEL)aSelector forErrorCode:(int)aCode
{
    if( self = [super init] ) {
        _selector = aSelector;
        _errorCode = aCode;
    }
    
    return self;
}

+ (id)mongooseSelectorWithSelector:(SEL)aSelector forRouteMatchingString:(NSString *)aString
{
    return [[[self alloc] initWithSelector:aSelector forRouteMatchingString:aString] autorelease];
}

+ (id)mongooseSelectorWithSelector:(SEL)aSelector forErrorCode:(int)aCode
{
    return [[[self alloc] initWithSelector:aSelector forErrorCode:aCode] autorelease];
}

- (void)dealloc
{
    [_routeString release];
    [_routePredicate release];
    [super dealloc];
}

- (NSPredicate *)routePredicate
{
    if( !_routePredicate )
        _routePredicate = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", [self routeString]] retain];
    
    return _routePredicate;
}

@end