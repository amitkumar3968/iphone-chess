//
//  ChessBoard.h
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//


#import "ChessCell.h"

@interface ChessBoard : NSObject {
    ChessCell* cells[8][8];
    CGRect rect;
    UIView* view;
}

- (id)initWithRect: (CGRect)r inView:(UIView*)v;

- (void)initCells;
- (void)clearPieces;
- (ChessCell *)cellAtX: (int)x Y:(int)y;

- (CGRect)rect;

@end
