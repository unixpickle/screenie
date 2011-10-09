//
//  WallpaperSetter.m
//  screenie
//
//  Created by Alex Nichol on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WallpaperSetter.h"

NSImageScaling scalingFromString (const char * scaleMode);
NSColor * colorFromHexString (NSString * hexString);
int numberFromHexChar (unichar c);
BOOL readHexChars (const char * chars, int * values, int count);

@implementation WallpaperSetter

- (id)initWithArgc:(int)argc argv:(const char **)argv {
	if ((self = [super init])) {
		if (argc == 1) {
			[super dealloc];
			return nil;
		}
		NSImageScaling scaling = NSImageScaleProportionallyUpOrDown;
		BOOL clipping = NO;
		NSColor * bgColor = nil;
		for (int i = 1; i < argc - 1; i++) {
			const char * option = argv[i];
			if (strcmp(option, "--scaling") == 0) {
				if (i + 1 == argc - 1) {
					[super dealloc];
					return nil;
				}
				scaling = scalingFromString(argv[++i]);
			} else if (strcmp(option, "--clipping") == 0) {
				if (i + 1 == argc - 1) {
					[super dealloc];
					return nil;
				}
				if (strcmp(argv[++i], "yes") == 0) {
					clipping = YES;
				} else {
					clipping = NO;
				}
			} else if (strcmp(option, "--bgcolor") == 0) {
				if (i + 1 == argc - 1) {
					[super dealloc];
					return nil;
				}
				bgColor = colorFromHexString([NSString stringWithUTF8String:argv[++i]]);
				if (!bgColor) {
					[super dealloc];
					return nil;
				}
			} else {
				[super dealloc];
				return nil;
			}
		}
		
		imageURL = [[NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[argc - 1]]] retain];
		if (!imageURL) {
			[super dealloc];
			return nil;
		}
		
		NSMutableDictionary * attributes = [[NSMutableDictionary alloc] init];
		[attributes setObject:[NSNumber numberWithBool:clipping]
					   forKey:NSWorkspaceDesktopImageAllowClippingKey];
		[attributes setObject:[NSNumber numberWithInteger:(NSInteger)scaling]
					   forKey:NSWorkspaceDesktopImageScalingKey];
		if (bgColor) {
			[attributes setObject:bgColor forKey:NSWorkspaceDesktopImageFillColorKey];
		}
		
		flags = [[NSDictionary alloc] initWithDictionary:attributes];
		[attributes release];
	}
	return self;
}

- (void)setWallpaper {
	NSError * error = nil;
	[[NSWorkspace sharedWorkspace] setDesktopImageURL:imageURL forScreen:[NSScreen mainScreen] options:flags error:&error];
	if (error) {
		fprintf(stderr, "Error setting wallpaper: %s\n", [[error description] UTF8String]);
	}
}

- (void)dealloc {
	[flags release];
	[imageURL release];
	[super dealloc];
}

@end

NSImageScaling scalingFromString (const char * scaleMode) {
	if (strcmp(scaleMode, "none") == 0) {
		return NSImageScaleNone;
	} else if (strcmp(scaleMode, "down") == 0) {
		return NSImageScaleProportionallyDown;
	} else if (strcmp(scaleMode, "stretch") == 0) {
		return NSImageScaleAxesIndependently;
	} else if (strcmp(scaleMode, "updown") == 0) {
		return NSImageScaleProportionallyUpOrDown;
	}
	return NSImageScaleNone;
}

NSColor * colorFromHexString (NSString * hexString) {
	float red, green, blue;
	if ([hexString length] == 0) return nil;
	unichar firstLetter = [hexString characterAtIndex:0];
	if (firstLetter != '#') {
		hexString = [@"#" stringByAppendingString:hexString];
	}
	if ([hexString length] == 4) {
		int digits[3];
		if (!readHexChars(&([hexString UTF8String])[1], digits, 3)) {
			return nil;
		}
		red = (float)digits[0] / 15.0f;
		green = (float)digits[1] / 15.0f;
		blue = (float)digits[2] / 15.0f;
	} else if ([hexString length] == 7) {
		int digits[6];
		if (!readHexChars(&([hexString UTF8String])[1], digits, 6)) {
			return nil;
		}
		red = (float)(digits[0] * 16 + digits[1]) / 255.0f;
		green = (float)(digits[2] * 16 + digits[3]) / 255.0f;
		blue = (float)(digits[4] * 16 + digits[5]) / 255.0f;
	}
	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1];
}

int numberFromHexChar (unichar c) {
	char lCase = tolower(c);
	if (lCase >= '0' && lCase <= '9') {
		return (lCase - '0');
	} else if (lCase >= 'a' && lCase <= 'f') {
		return (lCase - 'a') + 10;
	}
	return -1;
}

BOOL readHexChars (const char * chars, int * values, int count) {
	for (int i = 0; i < count; i++) {
		values[i] = numberFromHexChar(chars[i]);
		if (values[i] < 0) return NO;
	}
	return YES;
}
