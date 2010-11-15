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
@interface TIMongooseFileBasedDataProvider ()
- (NSData *)_dataForFileName:(NSString *)aFileName;
- (TIMongooseResponse *)_responseForData:(NSData *)someData withFileName:(NSString *)aFileName;
@end

#pragma mark -
#pragma mark ___TIMongooseFileBasedDataProvider Implementation___
@implementation TIMongooseFileBasedDataProvider

@synthesize rootFilePath = _rootFilePath;

#pragma mark -
#pragma mark Initialization and Deallocation
- (id)initWithRootFilePath:(NSString *)aPath
{
    self = [super init];
    if( !self ) return nil;
    
    if( !aPath ) 
        aPath = [[NSBundle mainBundle] bundlePath];
    _rootFilePath = [aPath retain];
    
    return self;
}

- (void)dealloc
{
    [_rootFilePath release]; _rootFilePath = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (NSArray *)possibleIndexFileNames
{
    static NSArray *sFileNames = nil;
    if( !sFileNames ) {
        sFileNames = [[NSArray alloc] initWithObjects:@"index.htm", @"index.html", @"default.htm", @"default.html", nil];
    }
    
    return sFileNames;
}

#pragma mark -
#pragma mark Response Handling
- (TIMongooseResponse *)mongooseResponseForRequest:(TIMongooseRequest *)aRequest
{
    NSData *fileData = [self _dataForFileName:aRequest.uri];    
    if( fileData ) {
        return [self _responseForData:fileData withFileName:aRequest.uri];
    }
    
    if( [aRequest.uri isEqualToString:@"/"] ) {
        for( NSString *eachIndexFileName in [self possibleIndexFileNames] ) {
            fileData = [self _dataForFileName:eachIndexFileName];
            if( fileData )
                return [self _responseForData:fileData withFileName:eachIndexFileName];
        }
    }
    
    return [super mongooseResponseForRequest:aRequest];
}

- (NSData *)_dataForFileName:(NSString *)aFileName
{
    return [NSData dataWithContentsOfFile:[[self rootFilePath] stringByAppendingPathComponent:aFileName]];
}

- (TIMongooseResponse *)_responseForData:(NSData *)someData withFileName:(NSString *)aFileName
{
    return [TIMongooseResponse mongooseResponseWithStatusCode:TIMongooseHTTPResponseType200OK
                                                  contentType:[self contentTypeForFileName:aFileName] 
                                                 responseData:someData];
}

- (NSString *)contentTypeForFileName:(NSString *)aFileName
{
    NSString *fileExtension = [[aFileName pathExtension] lowercaseString];
    
    if( [fileExtension isEqualToString:@"htm"] || [fileExtension isEqualToString:@"html"] )
        return TIMongooseResponseContentTypeTextHTML;
    else if( [fileExtension isEqualToString:@"jpg"] || [fileExtension isEqualToString:@"jpeg"] )
        return TIMongooseResponseContentTypeImageJPEG;
    else if( [fileExtension isEqualToString:@"gif"] )
        return TIMongooseResponseContentTypeImageGIF;
    else if( [fileExtension isEqualToString:@"png"] )
        return TIMongooseResponseContentTypeImagePNG;
    
    return TIMongooseResponseContentTypeTextPlain;
}

@end
