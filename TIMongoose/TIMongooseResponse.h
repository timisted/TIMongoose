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

#pragma mark ___TIMongooseResponse Interface___
@interface TIMongooseResponse : NSObject {
@private
    int _statusCode;
    NSData *_responseData;
    NSString *_contentType;
}

#pragma mark Designated Initializer
- (id)initWithStatusCode:(int)aCode contentType:(NSString *)aType responseData:(NSData *)someData;

#pragma mark Class Factory Methods
/* Generates a TIMongooseResponse object with the provided data. */
+ (id)mongooseResponseWithStatusCode:(int)aCode contentType:(NSString *)aType responseData:(NSData *)someData;

/* Calls the above method, passing the string encoded as UTF8. */
+ (id)mongooseResponseWithStatusCode:(int)aCode contentType:(NSString *)aType responseString:(NSString *)someString;

#pragma mark Properties
@property (assign) int statusCode;
@property (retain) NSData *responseData;
@property (retain) NSString *contentType;
@property (readonly) NSString *headersForOutput;
@property (readonly) NSData *dataForOutput;

@end

#pragma mark -
#pragma mark String Constants and Enums
extern NSString *TIMongooseResponseContentTypeTextHTML;
extern NSString *TIMongooseResponseContentTypeTextCSS;
extern NSString *TIMongooseResponseContentTypeTextPlain;
extern NSString *TIMongooseResponseContentTypeImageJPEG;
extern NSString *TIMongooseResponseContentTypeImageGIF;
extern NSString *TIMongooseResponseContentTypeImagePNG;
extern NSString *TIMongooseResponseContentTypeApplicationJSON;

typedef enum _TIMongooseHTTPResponseType {
    TIMongooseHTTPResponseType100Continue = 100,
    TIMongooseHTTPResponseType101SwitchingProtocols = 101,
    
    TIMongooseHTTPResponseType200OK = 200,
    TIMongooseHTTPResponseType201Created = 201,
    TIMongooseHTTPResponseType202Accepted = 202,
    TIMongooseHTTPResponseType203NonAuthoritativeInformation = 203,
    TIMongooseHTTPResponseType204NoContent = 204,
    TIMongooseHTTPResponseType205ResetContent = 205,
    TIMongooseHTTPResponseType206PartialContent = 206,
    
    TIMongooseHTTPResponseType300MultipleChoices = 300,
    TIMongooseHTTPResponseType301MovedPermanently = 301,
    TIMongooseHTTPResponseType302Found = 302,
    TIMongooseHTTPResponseType303SeeOther = 303,
    TIMongooseHTTPResponseType304NotModified = 304,
    TIMongooseHTTPResponseType305UseProxy = 305,
    TIMongooseHTTPResponseType306Unused = 306,
    TIMongooseHTTPResponseType307TemporaryRedirect = 307,
    
    TIMongooseHTTPResponseType400BadRequest = 400,
    TIMongooseHTTPResponseType401Unauthorized = 401,
    TIMongooseHTTPResponseType402PaymentRequired = 402,
    TIMongooseHTTPResponseType403Forbidden = 403,
    TIMongooseHTTPResponseType404NotFound = 404,
    TIMongooseHTTPResponseType405MethodNotAllowed = 405,
    TIMongooseHTTPResponseType406NotAcceptable = 406,
    TIMongooseHTTPResponseType407ProxyAuthenticationRequired = 407,
    TIMongooseHTTPResponseType408RequestTimeout = 408,
    TIMongooseHTTPResponseType409Conflict = 409,
    TIMongooseHTTPResponseType410Gone = 410,
    TIMongooseHTTPResponseType411LengthRequired = 411,
    TIMongooseHTTPResponseType412PreconditionFailed = 412,
    TIMongooseHTTPResponseType413RequestEntityTooLarge = 413,
    TIMongooseHTTPResponseType414RequestURITooLong = 414,
    TIMongooseHTTPResponseType415UnsupportedMediaType = 415,
    TIMongooseHTTPResponseType416RequestedRangeNotSatisfiable = 416,
    TIMongooseHTTPResponseType417ExpectationFailed = 417, 
    
    TIMongooseHTTPResponseType500InternalServerError = 500,
    TIMongooseHTTPResponseType501NotImplemented = 501,
    TIMongooseHTTPResponseType502BadGateway = 502,
    TIMongooseHTTPResponseType503ServiceUnavailable = 503,
    TIMongooseHTTPResponseType504GatewayTimeout = 504,
    TIMongooseHTTPResponseType505HTTPVersionNotSupported = 505
    
} TIMongooseHTTPResponseType;