#TIMongoose
*A Cocoa web server built around the Mongoose lightweight http server*  
([http://code.google.com/p/mongoose/](http://code.google.com/p/mongoose/))

Tim Isted  
[http://www.timisted.net](http://www.timisted.net)  
Twitter: @[timisted](http://twitter.com/timisted)

##License
TIMongoose is offered under the **MIT** license.

##Summary
TIMongoose is a collection of Objective-C classes to work on top of *Mongoose*, an embeddable web server with a minimal footprint.

TIMongoose serves HTTP requests through Data Provider objects. The server itself is packaged internally inside an `NSOperation`, and each request served by Mongoose will be dealt with on a separate thread. It is designed to work in both Mac desktop and iPhone OS applications.

To use TIMongoose, you need to create an instance of `TIMongooseEngine`. You'll then need to create at least one data provider (the easiest way is to subclass either `TIMongooseDataProvider` or `TIMongooseFileBasedDataProvider`) to provide responses (packaged in `TIMongooseResponse` objects) to requests (packaged in `TIMongooseRequest` objects).

##Basic Usage
Copy all the files in the TIMongoose directory (including those inside the Internal directory) into your project.

Create an instance of `TIMongooseEngine` and start it on a specified port:
    TIMongooseEngine *engine = [[TIMongooseEngine alloc] initWithDelegate:self];
    [engine startMongooseOnPort:8080];

`TIMongooseEngine` will spawn a `TIMongooseOperation` (an `NSOperation`) object and add it to an operation queue; this means that the method `startMongooseOnPort:` will return immediately. Implement the relevant delegate methods (`TIMongooseEngineDelegate` protocol) to determine whether the server started successfully, or to be informed of errors.

You can specify that `TIMongooseEngine` should listen on multiple ports by calling:
    [engine startMongooseOnPorts:8080, 443, 0];
with a comma-separated list, ending with a zero, or use:
    [engine startMongooseOnPortsInString:@"8080, 443"];
including one or more ports (no trailing zero).

###SSL Support
TIMongoose now supports connections via SSL. If you want to have SSL supported on the iPhone, you'll need to add static OpenSSL libraries to your iPhone device target; these are included in the iPhone example application.

To serve secure connections, you'll need to set a certificate path *before* starting the server. For any port you wish to be able to serve securely, you must include an `s` on the end of the port number, like this:
    TIMongooseEngine *engine [[TIMongooseEngine alloc] initWithDelegate:self];
    [engine setSslCertificateFilePath:[[NSBundle mainBundle] pathForResource:@"cert" ofType:@"pem"]];
    [engine startMongooseOnPortsInString:@"8080, 443s"];

###Data Providers
You'll need to provide at least one data provider in order to serve requests to the server. At present, TIMongoose includes a file-based data provider to serve pre-existing html and image files, and a selector-based data provider, which will call methods based on requested routes, to generate responses. Let's look at the file-based data provider first.

If you are hosting multiple sites/virtual hosts from the one server, you'll need to set a flag on your `TIMongooseEngine` object:

    [engine setSupportsNameBasedVirtualHosts:YES];

To serve standard HTML etc files with TIMongoose, simply create an instance of `TIMongooseFileBasedDataProvider`:
    TIMongooseFileBasedDataProvider *dp = [[[TIMongooseFileBasedDataProvider alloc] init] autorelease];

By default, this will serve files stored in the main app bundle (i.e. included in the project at compile time). You can also specify your own path if you wish, like this:
    [dp setRootFilePath:@"<some path string>"];

If the path contains a tilde, you'll need to expand it before passing it to this method, using `[<string> stringByExpandingTildeInPath].`

Set the data provider for the `TIMongooseEngine`:
    [engine setDataProvider:dp];

The data provider object will be retained by the `TIMongooseEngine`.

If you set `suportsNameBasedVirtualHosts` to `YES` earlier, this data provider will be used for requests made to the server's IP address (i.e., it will be treated as the default site). You can set additional data providers for specific hosts like this:
    [engine setDataProvider:dp forHost:@"mongoose.local"];

At present, you'll need to add any server aliases manually (such as "www.mongoose.local") using the same method:
    [engine setDataProvider:dp forHost:@"www.mongoose.local"];

`TIMongooseFileBasedDataProvider` will serve files if it can find them, otherwise it will respond with a generic Error 404 page, or call the selector you specify for error code 404 (see later in this Readme for instructions). It will treat requests for a directory root (e.g. "http://mongoose.local/") as requests for index files.

Possible filenames are defined in `TIMongooseFileBasedDataProvider`'s `possibleIndexFileNames` method (i.e. index.htm, default.html, etc).

###Selectors for Routes
`TIMongooseFileBasedDataProvider` inherits from `TIMongooseDataProvider`. The `TIMongooseDataProvider` class serves responses by matching the requested URI (e.g. "/username/logout") against a list of routes, and calls the selector previously specified for that route.

You'll need to write a data provider subclass to take advantage of this routing mechanism (if you also need to serve files, you can inherit from `TIMongooseFileBasedDataProvider` instead of `TIMongooseDataProvider`—this will serve files if they exist for the requested URI, otherwise it will use the selector mechanism):

    @interface MyMongooseDataProvider : TIMongooseDataProvider {
    }
    @end

Methods to handle routes must accept a `TIMongooseRequest` argument and return a `TIMongooseResponse` argument:
    - (TIMongooseResponse *)logoutResponseForRequest:(TIMongooseRequest *)aRequest
    {
       // examine the aRequest parameter to discover relevant information
       NSLog(@"Request object = %@", aRequest);
       // do logging out stuff here 
       return [TIMongooseResponse
                mongooseResponseWithStatusCode:TIMongooseHTTPResponseType200OK
                                   contentType:TIMongooseResponseContentTypeTextHTML
                                responseString:@"<html><body>You are now logged out</body></html>"];
    }

The `TIMongooseResponse` class method `mongooseResponseWithStatusCode:contentType:responseString:` encodes the string as UTF8 and passes it to `mongooseResponseWithStatusCode:contentType:responseData:`. Call this latter method directly to pass your own data, or the contents of files.

You'll need to override the setUpSelectors method to add the selectors for your routes:
    - (void)setUpSelectors
    {
        [self addSelector:@selector(logoutResponseForRequest:) forRouteMatchingString:@"/logout"];
    }

The `setUpSelectors` method will be called automatically when you allocate and initialize a `TIMongooseDataProvider` subclass. You do not need to call the super implementation on either `TIMongooseDataProvider` or `TIMongooseFileBasedDataProvider`.

When requests are received, `TIMongooseDataProvider` uses `NSPredicate`'s regular expression support to match the requested URI to a provided route. Check Apple's `NSPredicate` documentation for syntax explanation. If you don't need regular expression support, it's fine just to type the route path as indicated above (exclude the host domain name).

As each request received by the Mongoose webserver will be handled on a separate thread, your data provider class must be thread-safe.

###Selectors for Error Codes
You can customise TIMongoose's http error handling either by overriding
    - (TIMongooseResponse *)mongooseResponseForHttpErrorCode:(int)aCode fromRequest:(TIMongooseRequest *)aRequest;
or adding selectors for specific error codes.

Methods to handle errors must accept both an integer argument (indicating the error code) and an argument for the request, and return a `TIMongooseResponse` object:
    - (TIMongooseResponse *)customResponseForErrorCode:(NSNumber *)aCode request:(TIMongooseRequest *)aRequest
    {
        // generate TIMongooseResponse as above
    }

This allows you to specify selectors only for specific error codes, or use the same selector for multiple error codes if you wish.

###Constants and Enums
TIMongoose has a number of string constants and enums defined, including a few standard HTTP response content types:
    NSString *TIMongooseResponseContentTypeTextHTML;
    NSString *TIMongooseResponseContentTypeTextPlain;
    NSString *TIMongooseResponseContentTypeImageJPEG;

and HTTP response type codes:
    TIMongooseHTTPResponseType200OK
    TIMongooseHTTPResponseType201Created
    TIMongooseHTTPResponseType404NotFound
    TIMongooseHTTPResponseType500InternalServerError

Take a look in `TIMongooseResponse.h` for the full list.

##Testing Virtual Hosts
If you are running an app with TIMongoose on your local machine, or in the iPhone simulator, and want to test resolution of host/domain names, edit your /etc/hosts file to add those domains with IP address 127.0.0.1.   
**Warning:** messing with Terminal.app and sudo may be hazardous for your computer health!

Open the Terminal application and execute the following command:
    sudo nano /etc/hosts
You'll need to type your password so that changes can be made to the file, which will open in the nano command-window text editor (if you have TextMate with the shell command installed, substitute "mate" for "nano" to open the file in TextMate; similarly for other editors with command-line launch support).

Add entries at the end of the file, like this, for your chosen hostnames:
    127.0.0.1          mongoose.local
    127.0.0.1          mongoosetest.com
If you're using nano, type Ctrl-X to exit the editor, then press Y to save the changes.

Once you've saved the file, accessing http://mongoose.local in your browser will now target your local Mongoose server, assuming your app is running.

You can also specify multiple hosts on one line, separated by spaces, like this:
    127.0.0.1          www.mongoose.local subdomain.mongoose.local

##Included Examples
A sample iPhone application is included. A Mac version will follow shortly.

##To Do List
There are lots of features not yet exposed or implemented:

*  Refactoring of internal operation handling for server control.
*  Regex matching of hostnames to allow e.g. "multipleusernames.domain.com" to resolve to one provider
 * Authentication
 * SSL
 * Logging

 *and lots more besides!*