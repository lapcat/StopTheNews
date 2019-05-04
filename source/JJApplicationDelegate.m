#import "JJApplicationDelegate.h"

#import "JJLicenseWindow.h"
#import "JJMainMenu.h"
#import "JJMainWindow.h"

NSString* JJApplicationName;

@implementation JJApplicationDelegate {
	BOOL _didFinishLaunching;
	BOOL _shouldTerminateAutomatically;
	NSUInteger _urlCount;
	NSWindow* _licenseWindow;
	NSWindow* _mainWindow;
}

#pragma mark Private

-(void)dataTaskDidFinish {
	dispatch_async(dispatch_get_main_queue(), ^{
		--_urlCount;
		if (_shouldTerminateAutomatically && _urlCount == 0)
			[NSApp terminate:nil];
	});
}

-(void)dataTaskDidFinishWithURL:(nonnull NSURL*)url message:(nonnull NSString*)message {
	dispatch_async(dispatch_get_main_queue(), ^{
		_shouldTerminateAutomatically = NO;
		NSAlert* alert = [[NSAlert alloc] init];
		[alert setMessageText:NSLocalizedString(@"Original Article Not Found", nil)];
		NSString* informativeText = [NSString stringWithFormat:@"%@\n\n%@", [url absoluteString], message];
		[alert setInformativeText:informativeText];
		(void)[alert runModal];
		--_urlCount;
	});
}

#pragma mark NSApplicationDelegate

-(void)applicationWillFinishLaunching:(nonnull NSNotification *)notification {
	JJApplicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	if (JJApplicationName == nil) {
		NSLog(@"CFBundleName nil!");
		JJApplicationName = @"StopTheNews";
	}
	[JJMainMenu populateMainMenu];
}

-(void)applicationDidFinishLaunching:(nonnull NSNotification*)notification {
	_didFinishLaunching = YES;
	if (!_shouldTerminateAutomatically)
		[self openMainWindow:nil];
}

-(void)application:(nonnull NSApplication*)application openURLs:(nonnull NSArray<NSURL*>*)urls {
	if (!_didFinishLaunching)
		_shouldTerminateAutomatically = YES;
	_urlCount += [urls count];
	NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
	for (NSURL* url in urls) {
		NSString* absoluteString = [url absoluteString];
		if (absoluteString == nil) {
			[self dataTaskDidFinishWithURL:url message:NSLocalizedString(@"The URL has no absolute string.", nil)];
		} else {
			NSString* oldPrefix = nil;
			if ([absoluteString hasPrefix:@"applenews://"]) {
				oldPrefix = @"applenews://";
			} else if ([absoluteString hasPrefix:@"applenewss:"]) {
				oldPrefix = @"applenewss:";
			} else {
				[self dataTaskDidFinishWithURL:url message:NSLocalizedString(@"The URL has an unexpected scheme.", nil)];
				continue;
			}
			NSString* newString = [absoluteString stringByReplacingCharactersInRange:NSMakeRange(0, [oldPrefix length]) withString:@"https://apple.news"];
			NSURL* newURL = [NSURL URLWithString:newString];
			if (newURL == nil) {
				[self dataTaskDidFinishWithURL:url message:NSLocalizedString(@"Cannot generate an Apple News URL.", nil)];
			} else {
				NSURLSessionDataTask* dataTask = [session dataTaskWithURL:newURL completionHandler:^(NSData*_Nullable data, NSURLResponse*_Nullable response, NSError*_Nullable error) {
					if (data == nil) {
						if (response == nil) {
							[self dataTaskDidFinishWithURL:url message:[error localizedDescription]];
						} else {
							NSString* message = [NSString stringWithFormat:@"URL Response: %@\n\n%@", response, [error localizedDescription]];
							[self dataTaskDidFinishWithURL:url message:message];
						}
					} else {
						NSString* html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
						if (html == nil) {
							[self dataTaskDidFinishWithURL:url message:NSLocalizedString(@"The data was not UTF-8.", nil)];
						} else {
							NSRange range = [html rangeOfString:@"redirectToUrlAfterTimeout(\""];
							NSUInteger location = range.location;
							if (location == NSNotFound) {
								[self dataTaskDidFinishWithURL:url message:NSLocalizedString(@"Cannot find the function redirectToUrlAfterTimeout().", nil)];
							} else {
								NSUInteger length = range.length;
								NSScanner* scanner = [NSScanner scannerWithString:html];
								[scanner setScanLocation:location + length];
								[scanner setCharactersToBeSkipped:nil];
								NSString* originalURLString;
								if (![scanner scanUpToString:@"\"" intoString:&originalURLString]) {
									[self dataTaskDidFinishWithURL:url message:NSLocalizedString(@"Cannot find the end of the original URL.", nil)];
								} else {
									NSURL* originalURL = [NSURL URLWithString:originalURLString];
									if (originalURL == nil) {
										[self dataTaskDidFinishWithURL:url message:NSLocalizedString(@"The original URL is improperly formatted.", nil)];
									} else {
										[[NSWorkspace sharedWorkspace] openURL:originalURL];
										[self dataTaskDidFinish];
									}
								}
							}
						}
					}
				}];
				[dataTask setPriority:1.0];
				[dataTask resume];
			}
		}
	}
}

#pragma mark JJApplicationDelegate

-(void)windowWillClose:(nonnull NSNotification*)notification {
	id object = [notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:object];
	if (object == _licenseWindow)
		_licenseWindow = nil;
	else if (object == _mainWindow)
		_mainWindow = nil;
}

-(void)openLicense:(nullable id)sender {
	if (_licenseWindow != nil) {
		[_licenseWindow makeKeyAndOrderFront:self];
	} else {
		_licenseWindow = [JJLicenseWindow window];
		if (_licenseWindow != nil)
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:_licenseWindow];
	}
}

-(void)openMacAppStore:(id)sender {
	NSURL* url = [NSURL URLWithString:@"macappstore://itunes.apple.com/app/stopthemadness/id1376402589"];
	if (url != nil)
		[[NSWorkspace sharedWorkspace] openURL:url];
	else
		NSLog(@"MAS URL nil!");
}

-(void)openMainWindow:(nullable id)sender {
	if (_mainWindow != nil) {
		[_mainWindow makeKeyAndOrderFront:self];
	} else {
		_mainWindow = [JJMainWindow window];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:_mainWindow];
	}
}

-(void)openWebSite:(nullable id)sender {
	NSURL* url = [NSURL URLWithString:@"https://github.com/lapcat/StopTheNews"];
	if (url != nil)
		[[NSWorkspace sharedWorkspace] openURL:url];
	else
		NSLog(@"Support URL nil!");
}

@end
