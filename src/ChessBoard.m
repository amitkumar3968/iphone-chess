//
//  ChessBoard.m
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//


#import "ChessBoard.h"


@implementation ChessBoard


- (id)initWithRect: (CGRect)r inView:(UIView*)v
{
    self = [super init];

    if(self) {
      rect = r;
      view = v;
      [self initCells];
    }

    return self;
}

- (void)initCells
{
  int i = 0;
  int j = 0;
  ChessCell *current = nil;
  CGRect cellRect;

  float cellWidth = rect.size.width/8;
  float cellHeight = cellWidth;
  
  float x = rect.origin.x;
  float y = rect.origin.y; 
  
  printf("Allocating cells %f, %f...\n", x, y);
  for (i = 0; i < 8; ++i) {
    for ( j = 0; j < 8; ++j) {

      cellRect = CGRectMake(x + (j*cellWidth), y + (i*cellHeight), cellWidth, cellHeight);

      current = [[ChessCell alloc] initWithRect: cellRect inView: view];
      [current setX: j];
      [current setY: 7-i];
      
      cells[j][7-i] = current;
    } 
  }   
}

- (void)clearPieces
{
  for(int x=0; x < 8; ++x) {
    for(int y=0; y < 8; ++y) {
      ChessCell* cell = [self cellAtX: x Y: y];
      [cell setPiece: nil];
    }
  }
}

- (ChessCell *)cellAtX: (int)x Y:(int)y
{
  if(x >= 8 && y >= 8) {
    return nil;
  }
  
  return cells[x][y];
}

- (CGRect)rect
{
  return rect;
}


@end
