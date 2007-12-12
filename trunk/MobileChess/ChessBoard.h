//
//  ChessBoard.h
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ChessCell.h"

@interface ChessBoard : NSObject {
    NSMutableArray *cells;
    CGRect rect;
}

- (id)initWithRect: (CGRect)r;

- (void)initCells;

- (ChessCell *)cellAtX: (int)x Y:(int)y;

@end
