//
//  ChessCell.h
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ChessPiece.h"

@interface ChessCell : NSObject {
	CGRect rect;
	int x;
	int y;
	ChessPiece* piece;
}

- (id)initWithRect:(CGRect)r;

- (CGRect)rect;

- (void)setX:(int)newX;
- (int)x;
- (void)setY:(int)newY;
- (int)y;

- (void)setPiece:(ChessPiece*)newPiece;
- (ChessPiece*)piece;

@end
