//
//  ChessBoard.m
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ChessBoard.h"


@implementation ChessBoard


- (id)initWithRect: (CGRect)r
{
    self = [super init];
    rect = r;
    [self initCells];
    return self;
}

- (ChessCell *)cellAtX: (int)x Y:(int)y
{
    return [cells objectAtIndex: 8*y + x];
}

- (void)initCells
{
    int i = 0;
    int j = 0;
    ChessCell *current = nil;
    CGRect cellRect;
    float cellWidth = rect.size.width/8;
    float cellHeight = rect.size.height/8;
	
    float x = rect.origin.x;
    float y = rect.origin.y; 
	
    if (cells) {   
        [cells release];
        cells = nil;
    }   
	
    cells = [[NSMutableArray alloc] init];
	
    for (i = 0; i < 8; ++i) {
        for ( j = 0; j < 8; ++j) {
            cellRect = CGRectMake(x	+ (j*cellWidth), y + (i*cellHeight), cellWidth, cellHeight);
			
            current = [[ChessCell alloc] initWithRect: cellRect];
            [current setX: j];
            [current setY: i];
            [cells addObject: current];
        }   
    }   

	// Place starting black pieces
	[[self cellAtX:0 Y:0] setPiece: [ChessPiece_Black_Rook init]];
	[[self cellAtX:1 Y:0] setPiece: [ChessPiece_Black_Knight init]];
	[[self cellAtX:2 Y:0] setPiece: [ChessPiece_Black_Bishop init]];
	[[self cellAtX:3 Y:0] setPiece: [ChessPiece_Black_Queen init]];
	[[self cellAtX:4 Y:0] setPiece: [ChessPiece_Black_King init]];
	[[self cellAtX:5 Y:0] setPiece: [ChessPiece_Black_Bishop init]];
	[[self cellAtX:6 Y:0] setPiece: [ChessPiece_Black_Knight init]];
	[[self cellAtX:7 Y:0] setPiece: [ChessPiece_Black_Rook init]];
	
	for(i=0; i < 8; ++i) {
		[[self cellAtX:i Y:1] setPiece: [ChessPiece_Black_Pawn init]];
	}
	
	// Place starting white pieces
	[[self cellAtX:0 Y:7] setPiece: [ChessPiece_White_Rook init]];
	[[self cellAtX:1 Y:7] setPiece: [ChessPiece_White_Knight init]];
	[[self cellAtX:2 Y:7] setPiece: [ChessPiece_White_Bishop init]];
	[[self cellAtX:3 Y:7] setPiece: [ChessPiece_White_Queen init]];
	[[self cellAtX:4 Y:7] setPiece: [ChessPiece_White_King init]];
	[[self cellAtX:5 Y:7] setPiece: [ChessPiece_White_Bishop init]];
	[[self cellAtX:6 Y:7] setPiece: [ChessPiece_White_Knight init]];
	[[self cellAtX:7 Y:7] setPiece: [ChessPiece_White_Rook init]];
	
	for(i=0; i < 8; ++i) {
		[[self cellAtX:i Y:6] setPiece: [ChessPiece_White_Pawn init]];
	}
}


@end
