#import "JJApplicationDelegate.h"

#import "JJLicenseWindow.h"
#import "JJMainMenu.h"
#import "JJMainWindow.h"

NSString* JJApplicationName;

@implementation JJApplicationDelegate {
	BOOL _didOpenURLs;
	NSUInteger _urlCount;
	NSWindow* _licenseWindow;
	NSWindow* _mainWindow;
}

#pragma mark Private

-(void)dataTaskDidFinishWithURL:(nonnull NSURL*)url message:(nullable NSString*)message {
	dispatch_async(dispatch_get_main_queue(), ^{
		if (message == nil) {
			[self decrementURLCount];
			[[NSWorkspace sharedWorkspace] openURL:url];
		} else {
			NSAlert* alert = [[NSAlert alloc] init];
			[alert setMessageText:NSLocalizedString(@"Original Article Not Found", nil)];
			NSString* informativeText = [NSString stringWithFormat:@"%@\n\n%@\n\nOpen the URL in News app instead?", [url absoluteString], message];
			[alert setInformativeText:informativeText];
			[alert addButtonWithTitle:NSLocalizedString(@"News app", nil)];
			[alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
			NSModalResponse modalResponse = [alert runModal];
			[self decrementURLCount];
			if (modalResponse == NSAlertFirstButtonReturn) {
				NSURL* newsAppURL = [NSURL fileURLWithPath:@"/System/Applications/News.app" isDirectory:YES];
				[[NSWorkspace sharedWorkspace] openURLs:@[url] withApplicationAtURL:newsAppURL options:NSWorkspaceLaunchAsync configuration:@{} error:NULL];
			}
		}
	});
}

-(void)terminateIfNecessary {
	NSArray<NSWindow*>* windows = [NSApp windows];
	for (NSWindow* window in windows) {
		if ([window isVisible])
			return; // Don't terminate if there are visible windows
	}
	[NSApp terminate:nil];
}

-(void)decrementURLCount {
	--_urlCount;
	if (_urlCount > 0)
		return;
	
	[self performSelector:@selector(terminateIfNecessary) withObject:nil afterDelay:2.0];
}

-(void)openMacAppStoreURL:(nonnull NSURL*)url {
	[[NSWorkspace sharedWorkspace] openURLs:@[url] withAppBundleIdentifier:@"com.apple.AppStore" options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifiers:nil];
}

#pragma mark <UNUserNotificationCenterDelegate>

-(void)userNotificationCenter:(nonnull UNUserNotificationCenter*)notificationCenter didReceiveNotificationResponse:(nonnull UNNotificationResponse*)response withCompletionHandler:(nonnull void(^)(void))completionHandler {
	_didOpenURLs = YES;
	NSString* actionIdentifier = [response actionIdentifier];
	if (![actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
		UNNotification* notification = [response notification];
		UNNotificationRequest* request = [notification request];
		UNNotificationContent* content = [request content];
		NSDictionary* userInfo = [content userInfo];
		NSDictionary* news = userInfo[@"news"];
		if (news != nil && [news isKindOfClass:[NSDictionary class]]) {
			NSString* cu = news[@"cu"];
			if (cu != nil && [cu isKindOfClass:[NSString class]] && [cu hasPrefix:@"http"]) {
				NSURL* url = [NSURL URLWithString:cu];
				if (url != nil) {
					[[NSWorkspace sharedWorkspace] openURL:url];
					completionHandler();
					return;
				}
			}
			NSString* aid = news[@"aid"]; // article id
			if (aid != nil && [aid isKindOfClass:[NSString class]]) {
				NSURL* newsURL = [NSURL URLWithString:[@"applenewss:/" stringByAppendingString:aid]];
				if (newsURL) {
					[self application:NSApp openURLs:@[newsURL]];
					completionHandler();
					return;
				}
			}
		}
	}
	completionHandler();
	[self terminateIfNecessary];
}

#pragma mark NSApplicationDelegate

-(void)applicationWillFinishLaunching:(nonnull NSNotification *)notification {
	JJApplicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	if (JJApplicationName == nil) {
		NSLog(@"CFBundleName nil!");
		JJApplicationName = @"StopTheNews";
	}
	[JJMainMenu populateMainMenu];
	
	[[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
}

-(void)applicationWillTerminate:(nonnull NSNotification*)notification {
	[[UNUserNotificationCenter currentNotificationCenter] setDelegate:nil];
}

-(void)applicationDidFinishLaunching:(nonnull NSNotification*)notification {
	if (_didOpenURLs)
		return;
	
	static NSString*_Nonnull const FirstRunWindowShown = @"FirstRunWindowShown";
	NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if ([standardUserDefaults boolForKey:FirstRunWindowShown])
		return;
	[standardUserDefaults setBool:YES forKey:FirstRunWindowShown];
	
	NSString* defaultHandler = CFBridgingRelease(LSCopyDefaultHandlerForURLScheme(CFSTR("macappstore"))); // LSCopyDefaultHandlerForURLScheme is deprecated but so what.
	if (defaultHandler != nil && [defaultHandler caseInsensitiveCompare:@"com.apple.news"] == NSOrderedSame) {
		// StopTheNews 3.0 set itself as the default Mac App Store link handler.
		// This is bad when StopTheNews is uninstalled, because then Apple News becomes the default Mac App Store link handler, so set it back to App Store app.
		CFStringRef bundleID = CFSTR("com.apple.AppStore");
		NSArray<NSString*>* schemes = @[@"macappstore", @"macappstores"];
		OSStatus status;
		for (NSString* scheme in schemes) {
			status = LSSetDefaultHandlerForURLScheme((__bridge CFStringRef _Nonnull)scheme, bundleID);
			if (status != noErr)
				NSLog(@"LSSetDefaultHandlerForURLScheme %@ failed: %i", scheme, status);
		}
	}
	
	[self openMainWindow:nil];
}

-(void)applicationDidResignActive:(nonnull NSNotification*)notification {
	if (_urlCount > 0)
		return;
	
	[self terminateIfNecessary];
}

-(void)application:(nonnull NSApplication*)application openURLs:(nonnull NSArray<NSURL*>*)urls {
	_didOpenURLs = YES;
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
								range = [html rangeOfString:@"redirectToUrlAfterTimeout("];
								location = range.location;
								if (location == NSNotFound) {
									[self dataTaskDidFinishWithURL:url message:NSLocalizedString(@"Cannot find the function redirectToUrlAfterTimeout().", nil)];
								} else {
									[self dataTaskDidFinishWithURL:url message:NSLocalizedString(@"This article appears to be written exclusively for Apple News. No original article is listed.", nil)];
								}
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
										[self dataTaskDidFinishWithURL:originalURL message:nil];
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
		[self openMacAppStoreURL:url];
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
