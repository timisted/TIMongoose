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

#pragma mark Class Extensions (Private Methods)
@interface TIMongooseResponse ()

- (NSString *)_statusCodeDescription;

@end


#pragma mark -
#pragma mark ___TIMongooseResponse Implementation___
@implementation TIMongooseResponse

@synthesize statusCode = _statusCode, contentType = _contentType, responseData = _responseData;

#pragma mark -
#pragma mark Initialization and Deallocation
- (id)initWithStatusCode:(int)aCode contentType:(NSString *)aType responseData:(NSData *)someData
{
    if( self = [super init] ) {
        _statusCode = aCode;
        _responseData = [someData retain];
        _contentType = [aType retain];
    }
    
    return self;
}

+ (id)mongooseResponseWithStatusCode:(int)aCode contentType:(NSString *)aType responseData:(NSData *)someData
{
    return [[[self alloc] initWithStatusCode:aCode contentType:aType responseData:someData] autorelease];
}

+ (id)mongooseResponseWithStatusCode:(int)aCode contentType:(NSString *)aType responseString:(NSString *)someString
{
    return [self mongooseResponseWithStatusCode:aCode contentType:aType responseData:[someString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)dealloc
{
    [_contentType release]; _contentType = nil;
    [_responseData release]; _responseData = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Output Methods
// Declared as readonly properties in the header
- (NSString *)headersForOutput
{
    return [NSString stringWithFormat:
            @"HTTP/1.1 %i%@\r\nContent-Type: %@\r\n\r\n",
            [self statusCode], 
            [self _statusCodeDescription], 
            [self contentType]];
}

- (NSData *)dataForOutput
{
    return _responseData;
}

#pragma mark Private Helper Methods
- (NSString *)_statusCodeDescription
{
    switch ([self statusCode]) {
        case TIMongooseHTTPResponseType100Continue: return @" CONTINUE";
        case TIMongooseHTTPResponseType101SwitchingProtocols: return @" SWITCHING PROTOCOLS";
            
        case TIMongooseHTTPResponseType200OK: return @" OK";
        case TIMongooseHTTPResponseType201Created: return @" CREATED";
        case TIMongooseHTTPResponseType202Accepted: return @" ACCEPTED";
        case TIMongooseHTTPResponseType203NonAuthoritativeInformation: return @" NON-AUTHORITATIVE INFORMATION";
        case TIMongooseHTTPResponseType204NoContent: return @" NO CONTENT";
        case TIMongooseHTTPResponseType205ResetContent: return @" RESET CONTENT";
        case TIMongooseHTTPResponseType206PartialContent: return @" PARTIAL CONTENT";
        
        case TIMongooseHTTPResponseType300MultipleChoices: return @" MULTIPLE CHOICES";
        case TIMongooseHTTPResponseType301MovedPermanently: return @" MOVED PERMANENTLY";
        case TIMongooseHTTPResponseType302Found: return @" FOUND";
        case TIMongooseHTTPResponseType303SeeOther: return @" SEE OTHER";
        case TIMongooseHTTPResponseType304NotModified: return @" NOT MODIFIED";
        case TIMongooseHTTPResponseType305UseProxy: return @" USE PROXY";
        case TIMongooseHTTPResponseType306Unused: return @" (UNUSED)";
        case TIMongooseHTTPResponseType307TemporaryRedirect: return @" TEMPORARY REDIRECT";
            
        case TIMongooseHTTPResponseType400BadRequest: return @" BAD REQUEST";
        case TIMongooseHTTPResponseType401Unauthorized: return @" UNAUTHORIZED";
        case TIMongooseHTTPResponseType402PaymentRequired: return @" PAYMENT REQUIRED";
        case TIMongooseHTTPResponseType403Forbidden: return @" FORBIDDEN";
        case TIMongooseHTTPResponseType404NotFound: return @" NOT FOUND";
        case TIMongooseHTTPResponseType405MethodNotAllowed: return @" METHOD NOT ALLOWED";
        case TIMongooseHTTPResponseType406NotAcceptable: return @" NOT ACCEPTABLE";
        case TIMongooseHTTPResponseType407ProxyAuthenticationRequired: return @" PROXY AUTHENTICATION REQUIRED";
        case TIMongooseHTTPResponseType408RequestTimeout: return @" REQUEST TIMEOUT";
        case TIMongooseHTTPResponseType409Conflict: return @" CONFLICT";
        case TIMongooseHTTPResponseType410Gone: return @" GONE";
        case TIMongooseHTTPResponseType411LengthRequired: return @" LENGTH REQUIRED";
        case TIMongooseHTTPResponseType412PreconditionFailed: return @" PRECONDITION FAILED";
        case TIMongooseHTTPResponseType413RequestEntityTooLarge: return @" REQUEST ENTITY TOO LARGE";
        case TIMongooseHTTPResponseType414RequestURITooLong: return @" REQUEST-URI TOO LONG";
        case TIMongooseHTTPResponseType415UnsupportedMediaType: return @" UNSUPPORTED MEDIA TYPE";
        case TIMongooseHTTPResponseType416RequestedRangeNotSatisfiable: return @" REQUESTED RANGE NOT SATISFIABLE";
        case TIMongooseHTTPResponseType417ExpectationFailed: return @" EXPECTATION FAILED";
        
        case TIMongooseHTTPResponseType500InternalServerError: return @" INTERNAL SERVER ERROR";
        case TIMongooseHTTPResponseType501NotImplemented: return @" NOT IMPLEMENTED";
        case TIMongooseHTTPResponseType502BadGateway: return @" BAD GATEWAY";
        case TIMongooseHTTPResponseType503ServiceUnavailable: return @" SERVICE UNAVAILABLE";
        case TIMongooseHTTPResponseType504GatewayTimeout: return @" GATEWAY TIMEOUT";
        case TIMongooseHTTPResponseType505HTTPVersionNotSupported: return @" HTTP VERSION NOT SUPPORTED";
        
        default: return @"";
    }
}

@end

#pragma mark -
#pragma mark String Constant Declarations
NSString *TIMongooseResponseContentTypeTextHTML = @"text/html";
NSString *TIMongooseResponseContentTypeTextPlain = @"text/plain";
NSString *TIMongooseResponseContentTypeTestCSS = @"text/css";
NSString *TIMongooseResponseContentTypeTextXML = @"text/xml";
NSString *TIMongooseResponseContentTypeImageJPEG = @"image/jpeg";
NSString *TIMongooseResponseContentTypeImageGIF = @"image/gif";
NSString *TIMongooseResponseContentTypeImagePNG = @"image/png";