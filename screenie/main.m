//
//  main.m
//  screenie
//
//  Created by Alex Nichol on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WallpaperSetter.h"

int wallpaperUtil (int argc, const char * argv[]);
NSString * colorToHexString (NSColor * color);

struct {
	const char * argName;
	int (*utilFunct)(int argc, const char * argv[]);
} subcommands[] = {
	{"wallpaper", wallpaperUtil}
};

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	if (argc <= 1) {
		fprintf(stderr, "Usage: %s [command] [options]\n"
				"Commands:\n"
				"\nwallpaper      Modify or read desktop wallpaper\n\n", argv[0]);
		return 1;
	}
	
	for (int i = 0; i < 1; i++) {
		if (strcmp(subcommands[i].argName, argv[1]) == 0) {
			return subcommands[i].utilFunct(argc - 1, &argv[1]);
		}
	}
	
	[pool drain];
	return 0;
}

int wallpaperUtil (int argc, const char * argv[]) {
	if (argc == 1) {
		fprintf(stderr, "Usage: %s [--get | --set | --properties] [options] [file]\n"
				"Options for --set:\n"
				" --scaling [none | down | stretch | updown]\n"
				" --clipping [yes | no]\n"
				" --bgcolor #AABBCC\n\n", argv[0]);
		return 1;
	}
	
	const char * optionString = argv[1];
	if (strcmp(optionString, "--get") == 0) {
		NSURL * imageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:[NSScreen mainScreen]];
		printf("%s\n", [[imageURL description] UTF8String]);
	} else if (strcmp(optionString, "--set") == 0) {
		WallpaperSetter * setter = [[WallpaperSetter alloc] initWithArgc:(argc - 1) argv:&argv[1]];
		if (!setter) {
			fprintf(stderr, "Invalid arguments for --set.\n");
			return -1;
		}
		[setter setWallpaper];
		[setter release];
	} else if (strcmp(optionString, "--properties") == 0) {
		NSDictionary * dictionary = [[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:[NSScreen mainScreen]];
		if ([dictionary objectForKey:NSWorkspaceDesktopImageAllowClippingKey]) {
			NSNumber * clipping = [dictionary objectForKey:NSWorkspaceDesktopImageAllowClippingKey];
			if ([clipping boolValue]) {
				printf("Clipping: YES\n");
			} else {
				printf("Clipping: NO\n");
			}
		} else {
			printf("Clipping: NO\n");
		}
		if ([dictionary objectForKey:NSWorkspaceDesktopImageFillColorKey]) {
			NSColor * color = [dictionary objectForKey:NSWorkspaceDesktopImageFillColorKey];
			printf("Background: %s\n", [colorToHexString(color) UTF8String]);
		}
		if ([dictionary objectForKey:NSWorkspaceDesktopImageScalingKey]) {
			NSImageScaling scaling = [[dictionary objectForKey:NSWorkspaceDesktopImageScalingKey] integerValue];
			switch (scaling) {
				case NSImageScaleNone:
					printf("Scaling: none\n");
					break;
				case NSImageScaleAxesIndependently:
					printf("Scaling: stretch\n");
					break;
				case NSImageScaleProportionallyDown:
					printf("Scaling: down\n");
					break;
				case NSImageScaleProportionallyUpOrDown:
					printf("Scaling: updown\n");
					break;
				default:
					printf("Scaling: unknown\n");
					break;
			}
		} else {
			printf("Scaling: updown\n");
		}
	}
	
	return 0;
}

NSString * colorToHexString (NSColor * color) {
	NSMutableString * hexString = [[NSMutableString alloc] init];
	[hexString appendString:@"#"];
	[hexString appendFormat:@"%02x", (int)([color redComponent] * 255.0f)];
	[hexString appendFormat:@"%02x", (int)([color greenComponent] * 255.0f)];
	[hexString appendFormat:@"%02x", (int)([color blueComponent] * 255.0f)];
	return [hexString autorelease];
}

