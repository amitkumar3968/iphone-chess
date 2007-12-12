//
//  ChessCell.m
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ChessCell.h"


@implementation ChessCell

- (id)initWithRect:(CGRect)r
{
    self = [super init];
    rect = r;
    piece = nil;
	

    return self;
}

- (ChessPiece*)piece
{
    return piece;
}

- (void)setPiece: (ChessPiece*)newPiece
{
	piece = newPiece;
}

- (CGRect)rect
{
    return rect;
}

- (void)setX:(int)newX
{
    x = newX;
}

- (int)x
{
    return x;
}

- (void)setY:(int)newY
{
    y = newY;
}

- (int)y
{
    return y;
}


@end
