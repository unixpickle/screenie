//
//  WallpaperSetter.h
//  screenie
//
//  Created by Alex Nichol on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WallpaperSetter : NSObject {
	NSDictionary * flags;
	NSURL * imageURL;
}

- (id)initWithArgc:(int)argc argv:(const char **)argv;
- (void)setWallpaper;

@end
