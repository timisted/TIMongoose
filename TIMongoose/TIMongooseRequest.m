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
#import "NSString+TIMongooseAdditions.h"

#pragma mark Class Extensions (Private Methods)
@interface TIMongooseRequest ()
- (void)_getCachedHostDomainAndPort;
@end

#pragma mark
#pragma mark ___TIMongooseRequest Implementation___
@implementation TIMongooseRequest

#pragma mark -
#pragma mark Initialization and Deallocation
- (id)initWithMGRequestInfo:(const struct mg_request_info *)anMGRequestInfoStruct
{
    if( self = [super init] ) {
        _mg_info = anMGRequestInfoStruct;
    }
    
    return self;
}

+ (id)mongooseRequestWithMGRequestInfo:(struct mg_request_info *)anMGRequestInfoStruct
{
    return [[[self alloc] initWithMGRequestInfo:anMGRequestInfoStruct] autorelease];
}

- (void)dealloc
{
    [_cachedHostDomain release];
    [super dealloc];
}

#pragma mark -
#pragma mark Description
- (NSString *)description
{
    NSString *descriptionString = [NSString stringWithFormat:
                                   @"%@ {\nRequest Method = %@\nURI = %@\nHttp Version = %@\nQuery String = %@\n", 
                                   [super description],
                                   [self requestMethod],
                                   [self uri],
                                   [self httpVersion],
                                   [self queryString]];
    
    descriptionString = [descriptionString stringByAppendingFormat:
                         @"Remote User = %@\nRemote IP = %@\nRemote Port = %i\nStatus Code = %i\nHeaders = %@}",
                         [self remoteUser],
                         [self remoteIpAddress],
                         [self remotePort],
                         [self httpStatusCode],
                         [self headers]];
    
    return descriptionString;
}

#pragma mark -
#pragma mark Read-only Property Accessors
- (TIMongooseRequestMethodType)requestMethodType
{
    const char *reqMeth = _mg_info->request_method;
    
    if( strcmp(reqMeth, "GET") == 0 )
        return TIMongooseRequestMethodTypeGET;
    else if( strcmp(reqMeth, "POST") == 0 )
        return TIMongooseRequestMethodTypePOST;
    else if( strcmp(reqMeth, "PUT") == 0 )
        return TIMongooseRequestMethodTypePUT;
    else if( strcmp(reqMeth, "DELETE") == 0 )
        return TIMongooseRequestMethodTypeDELETE;
    else if( strcmp(reqMeth, "HEAD") == 0 )
        return TIMongooseRequestMethodTypeHEAD;
    else if( strcmp(reqMeth, "OPTIONS") == 0 )
        return TIMongooseRequestMethodTypeOPTIONS;
    else if( strcmp(reqMeth, "TRACE") == 0 )
        return TIMongooseRequestMethodTypeTRACE;
    else if( strcmp(reqMeth, "CONNECT") == 0 )
        return TIMongooseRequestMethodTypeCONNECT;
    else
        return TIMongooseRequestMethodTypeUnknown;
}

- (NSString *)requestMethod
{
    return (_mg_info->request_method != nil) ? [NSString stringWithUTF8String:_mg_info->request_method] : nil;
}

- (NSString *)uri
{
    return (_mg_info->uri != nil) ? [NSString stringWithUTF8String:_mg_info->uri] : nil;
}

- (NSString *)httpVersion
{
    return (_mg_info->http_version != nil) ? [NSString stringWithUTF8String:_mg_info->http_version] : nil;
}

- (NSString *)queryString
{
    return (_mg_info->query_string != nil) ? [NSString stringWithUTF8String:_mg_info->query_string] : nil;
}

- (NSData *)postData
{
    return [NSData dataWithBytes:_mg_info->post_data length:_mg_info->post_data_len];
}

- (NSString *)remoteUser
{
    return (_mg_info->remote_user != nil) ? [NSString stringWithUTF8String:_mg_info->remote_user] : nil;
}

- (NSString *)remoteIpAddress
{
    return [NSString tiM_IPAddressFromLong:_mg_info->remote_ip];
}

- (int)remotePort
{
    return _mg_info->remote_port;
}

- (int)httpStatusCode
{
    return _mg_info->status_code;
}

- (NSDictionary *)headers
{
    int numberOfHeaders = _mg_info->num_headers;
    
    NSMutableDictionary *headerDictionary = [NSMutableDictionary dictionaryWithCapacity:numberOfHeaders];
    
    for( int i = 0; i < numberOfHeaders; i ++ ) {
        [headerDictionary setValue:[NSString stringWithUTF8String:_mg_info->http_headers[i].value]
                            forKey:[NSString stringWithUTF8String:_mg_info->http_headers[i].name]];
    }
    
    return headerDictionary;
}

- (NSString *)hostDomain
{
    if( !_cachedHostDomain )
        [self _getCachedHostDomainAndPort];
    
    return _cachedHostDomain;
}

- (int)hostPort
{
    if( !_cachedHostPort )
        [self _getCachedHostDomainAndPort];
    
    return _cachedHostPort;
}

- (void)_getCachedHostDomainAndPort
{
    NSArray *hostBits = [[[self headers] valueForKey:@"Host"] componentsSeparatedByString:@":"];
    
    if( [hostBits count] > 0 )
        _cachedHostDomain = [[hostBits objectAtIndex:0] retain];
    else {
        [_cachedHostDomain release]; _cachedHostDomain = nil;
    }
    
    if( [hostBits count] > 1 )
        _cachedHostPort = [[hostBits objectAtIndex:1] intValue];
    else
        _cachedHostPort = 80;
}

@end
