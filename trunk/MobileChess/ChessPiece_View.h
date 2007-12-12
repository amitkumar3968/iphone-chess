//
//  ChessPiece_View.h
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ChessPiece_View : NSView {
	ChessPiece* piece;	
	CGImageRef image;
}

- (void)initImage;
@end