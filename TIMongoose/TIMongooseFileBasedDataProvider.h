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

#import "TIMongooseDataProvider.h"

#pragma mark ___TIMongooseFileBasedDataProviderInterface___ 
@interface TIMongooseFileBasedDataProvider : TIMongooseDataProvider {
    NSString *_rootFilePath;
}

#pragma mark Designated Initializer
/* The root file path is the path to the directory containing the files to be served by
   this data provider. By default, this will be the path to the main app bundle. */
- (id)initWithRootFilePath:(NSString *)aPath;

#pragma mark Working with Files
/* This method will be used to determine what file is served for a directory root request
   such as "www.mydomain.com/".
   By default, it returns "index.htm" and "default.htm", along with ".html" variants. */
- (NSArray *)possibleIndexFileNames;

/* Returns the content type for a given file name.
   The default implementation currently deals only with basic html, text, and graphic types. */
- (NSString *)contentTypeForFileName:(NSString *)aFileName;

#pragma mark Properties
@property (retain) NSString *rootFilePath;

@end
