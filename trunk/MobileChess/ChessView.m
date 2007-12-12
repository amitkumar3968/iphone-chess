//
//  ChessView.m
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ChessView.h"


CGImageRef loadPNG(NSString* _path) {
	CFStringRef path;
    CFURLRef url;
    CGDataProviderRef provider;
    NSString *p;
	
    p = [[NSBundle mainBundle] pathForResource: _path ofType: @"png"];
	
    path = CFStringCreateWithCString(NULL, 
									 [p cStringUsingEncoding: NSASCIIStringEncoding], 
									 kCFStringEncodingUTF8);
	
    url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, 0);
    provider = CGDataProviderCreateWithURL(url);
	
    CFRelease(path);
    CFRelease(url);
	
	CGImageRef img = CGImageCreateWithJPEGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
	
    CGDataProviderRelease(provider);	
	
	return img;
}

@implementation ChessView

- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        board = [[ChessBoard alloc] initWithRect:CGRectMake(
															frame.origin.x,
															frame.origin.y,
															frame.size.width,
															frame.size.height)
				 ];
        [self initImages];
    }
    return self;
}

- (void) initImages
{
	boardimage = loadPNG(@"board");
}

- (ChessBoard *)board
{
    return board;
}


@end
