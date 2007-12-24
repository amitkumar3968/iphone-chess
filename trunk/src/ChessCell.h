//
//  ChessCell.h
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChessPiece.h"
#import "ChessPiece_View.h"

@interface ChessCell : NSObject {
	int x;
	int y;

	CGRect rect;

	ChessPiece_View* piece_view;
	UIView* view;
}

- (id)initWithRect:(CGRect)r inView:(UIView*)view;

- (CGRect)rect;

- (void)setX:(int)newX;
- (int)x;
- (void)setY:(int)newY;
- (int)y;

- (void)setPiece:(ChessPiece*)newPiece;
- (ChessPiece*)piece;
- (ChessPiece_View*)piece_view;

@end
