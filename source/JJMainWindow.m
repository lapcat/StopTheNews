#import "JJMainWindow.h"

@implementation JJMainWindow

+(nonnull NSWindow*)window {
	NSWindowStyleMask style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable;
	NSWindow* window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 380.0, 300.0) styleMask:style backing:NSBackingStoreBuffered defer:YES];
	[window setExcludedFromWindowsMenu:YES];
	[window setReleasedWhenClosed:NO]; // Necessary under ARC to avoid a crash.
	[window setTabbingMode:NSWindowTabbingModeDisallowed];
	[window setTitle:JJApplicationName];
	NSView* contentView = [window contentView];
	
	NSString* intro = NSLocalizedString(@"StopTheNews registers itself as the default handler for Apple News URLs instead of the News app.\n\nIf you open an Apple News URL in Safari and allow Safari to open it in StopTheNews, the original article will then open in Safari (or Safari Technology Preview, if that is your default web browser).\n\nYou don't need to keep StopTheNews running. Safari will automatically launch StopTheNews, and StopTheNews will automatically terminate itself on opening the original article in Safari.\n\nStopTheNews is free and open source. To support the developer, please consider buying the Safari extension StopTheMadness in the Mac App Store. Thanks!", nil);
	NSTextField* label = [NSTextField wrappingLabelWithString:intro];
	[label setTranslatesAutoresizingMaskIntoConstraints:NO];
	[contentView addSubview:label];
	
	NSButton* buyButton = [[NSButton alloc] init];
	[buyButton setButtonType:NSButtonTypeMomentaryLight];
	[buyButton setBezelStyle:NSBezelStyleRounded];
	[buyButton setTitle:NSLocalizedString(@"Mac App Store", nil)];
	[buyButton setAction:@selector(openMacAppStore:)];
	[buyButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	[contentView addSubview:buyButton];
	[window setDefaultButtonCell:[buyButton cell]];
	[window setInitialFirstResponder:buyButton];
	
	[NSLayoutConstraint activateConstraints:@[
											  [[label topAnchor] constraintEqualToAnchor:[contentView topAnchor] constant:15.0],
											  [[label leadingAnchor] constraintEqualToAnchor:[contentView leadingAnchor] constant:15.0],
											  [[label trailingAnchor] constraintEqualToAnchor:[contentView trailingAnchor] constant:-15.0],
											  [[label widthAnchor] constraintEqualToConstant:350.0],
											  [[buyButton topAnchor] constraintEqualToAnchor:[label bottomAnchor] constant:15.0],
											  [[buyButton bottomAnchor] constraintEqualToAnchor:[contentView bottomAnchor] constant:-15.0],
											  [[buyButton trailingAnchor] constraintEqualToAnchor:[contentView trailingAnchor] constant:-15.0]
										  ]];
	
	[window makeKeyAndOrderFront:nil];
	[window center]; // Wait until after makeKeyAndOrderFront so the window sizes properly first
	
	return window;
}

@end
