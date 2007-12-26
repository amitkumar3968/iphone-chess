//
//  ChessCell.m
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ChessCell.h"


@implementation ChessCell

- (id)initWithRect:(CGRect)r inView:(UIView*)v;
{
    self = [super init];

    if(self) {
      view = v;
      rect = r;
      piece_view = nil;
    }

    return self;
}

- (NSString*)stringCoord
{
  char f_y = '1' + [self y];
  char f_x = 'a' + [self x];

  return [NSString stringWithFormat:@"%c%c", f_x, f_y];
}

- (ChessPiece*)piece
{
    return [piece_view piece];
}

- (ChessPiece_View*)piece_view
{
    return piece_view;
}

- (void)setPiece: (ChessPiece*)newPiece
{
  if(piece_view) {
    [piece_view release];
  }

  if(newPiece == nil) {
    piece_view = nil;
  } else {
    piece_view = [[ChessPiece_View alloc] initWithPiece: newPiece andRect: rect inView: view];
  }
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
