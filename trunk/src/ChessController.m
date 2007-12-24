//
//  ChessController.m
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ChessController.h"
#import "ChessCell.h"

@implementation ChessController

- (id)initWithBoard:(ChessBoard*)b inView:(UIView*)v
{
  self = [super init];
  
  if(self) {
    board = b;
    view = v;
    selected_cell = nil;
    waiting = NO;
    
    audio = [[ChessAudio alloc] init];

    if(board && view) {
      engine = [[ChessEngine alloc] initWithController: self];
    }
  }

  return self;
}


- (void)newGame
{
  [engine newGame];

  [board clearPieces];
  NSLog(@"Placing initial board pieces...\n");

  int i = 0;
  int j = 0;

  // Place starting white pieces	
  [[board cellAtX:0 Y:0] setPiece: [[ChessPiece alloc] initWithSymbol: 'R']];
  [[board cellAtX:1 Y:0] setPiece: [[ChessPiece alloc] initWithSymbol: 'N']];
  [[board cellAtX:2 Y:0] setPiece: [[ChessPiece alloc] initWithSymbol: 'B']];
  [[board cellAtX:3 Y:0] setPiece: [[ChessPiece alloc] initWithSymbol: 'Q']];
  [[board cellAtX:4 Y:0] setPiece: [[ChessPiece alloc] initWithSymbol: 'K']];
  [[board cellAtX:5 Y:0] setPiece: [[ChessPiece alloc] initWithSymbol: 'B']];
  [[board cellAtX:6 Y:0] setPiece: [[ChessPiece alloc] initWithSymbol: 'N']];
  [[board cellAtX:7 Y:0] setPiece: [[ChessPiece alloc] initWithSymbol: 'R']];
  
  for(i=0; i < 8; ++i) {
    [[board cellAtX:i Y:1] setPiece: [[ChessPiece alloc] initWithSymbol: 'P']];
  }		
  
  // Place starting white pieces
  [[board cellAtX:0 Y:7] setPiece: [[ChessPiece alloc] initWithSymbol: 'r']];
  [[board cellAtX:1 Y:7] setPiece: [[ChessPiece alloc] initWithSymbol: 'n']];
  [[board cellAtX:2 Y:7] setPiece: [[ChessPiece alloc] initWithSymbol: 'b']];
  [[board cellAtX:3 Y:7] setPiece: [[ChessPiece alloc] initWithSymbol: 'q']];
  [[board cellAtX:4 Y:7] setPiece: [[ChessPiece alloc] initWithSymbol: 'k']];
  [[board cellAtX:5 Y:7] setPiece: [[ChessPiece alloc] initWithSymbol: 'b']];
  [[board cellAtX:6 Y:7] setPiece: [[ChessPiece alloc] initWithSymbol: 'n']];
  [[board cellAtX:7 Y:7] setPiece: [[ChessPiece alloc] initWithSymbol: 'r']];
  
  for(i=0; i < 8; ++i) {
    [[board cellAtX:i Y:6] setPiece: [[ChessPiece alloc] initWithSymbol: 'p']];
  }
}

- (void)startGame
{
  turn_color = @"white";
  player_color = @"white";
}


- (void)cellClicked:(ChessCell*)cell inView: (UIView*)view {
  if(waiting) return;

  if(![turn_color isEqualToString: player_color]) {
    return;
  }

  if(cell == selected_cell) {  // toggle cell selection
    selected_cell = nil;
    return;
  } else if(selected_cell == nil || cell == nil) { // select new cell or deselect is cell is nil
    ChessPiece* p = [cell piece];
    if(p != nil) {
      if([p isColor: player_color]) {
	selected_cell = cell;
      }
    }
  } else { // otherwise we are moving the piece from our selected cell to a new spot
    ChessPiece* selected_piece = [selected_cell piece];
    ChessPiece* new_piece = [cell piece];

    if(selected_piece && new_piece) {
      if([selected_piece isWhite] == [new_piece isWhite]) {
	selected_cell = cell; // switch to that piece
	return;
      }
    }

    // ask the engine to process this move
    [engine moveFrom: selected_cell To: cell];
    [self startWaiting];
  }
}


- (void)toggleTurn
{
  if([turn_color isEqualToString:@"white"]) {
    turn_color = @"black";
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>> It is now blacks turn\n");
  } else if([turn_color isEqualToString:@"black"]) {
    turn_color = @"white";
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>> It is now whites turn\n");
  }
}

- (BOOL)isComputerTurn
{
  if([turn_color isEqualToString:player_color]) {
    return NO;
  }
  return YES;
}

- (BOOL)isHumanTurn
{
  if([turn_color isEqualToString:player_color]) {
    return YES;
  }
  return NO;
}

- (void)startWaiting
{
  waiting = YES;
  [view startWaiting];
}

- (void)stopWaiting
{
  waiting = NO;
  [view stopWaiting];
}

- (void)engineMove:(NSString*)move
{
  if([self isComputerTurn]) {
    NSLog(@"Engine move: %@\n", move);
    [self doMove: move];
    [self toggleTurn];
    [self stopWaiting];
  }
}

- (void)illegalMove:(NSString*)move
{
  if([self isHumanTurn]) {
    NSLog(@"Illegal move: %@\n", move);
    [self stopWaiting];
  }
}

- (void)validMove:(NSString*)move {
  if([self isHumanTurn]) {
    NSLog(@"Player move: %@\n", move);
    [self doMove: move];
    [self toggleTurn];
    [self startWaiting];
  }
}

- (void)doMove:(NSString*)move {
  if([move length] != 4) {
    NSLog(@"Unknown move format: %@\n", move);
    exit(1);
  }

  NSLog(@"Valid move: %@\n", move);

  [audio playMove];

  const char* m = [move cString];
  int f_x = m[0] - 'a';
  int f_y = m[1] - '1';

  int t_x = m[2] - 'a';
  int t_y = m[3] - '1';

  NSLog(@"%@ -> %d x %d, %d x %d\n", move, f_x, f_y, t_x, t_y);

  assert(f_x >= 0 && f_x < 8);
  assert(f_y >= 0 && f_y < 8);
  assert(t_x >= 0 && f_x < 8);
  assert(t_y >= 0 && t_y < 8);

  ChessCell* from = [board cellAtX: f_x Y: f_y];
  ChessCell* to = [board cellAtX: t_x Y: t_y];
  
  // check for castling
  if(tolower([[from piece] symbol]) == 'k') {
    const int xmv = t_x - f_x;
    
    ChessCell* rook = nil;
    ChessCell* rook_to = nil;

    // detect which side was castled to
    if(xmv < -1) { // queenside
      NSLog(@"Queenside castling: king xmv = %d\n", xmv);
      rook = [board cellAtX: 0 Y: f_y];
      rook_to = [board cellAtX: 3 Y: f_y];
    } else if(xmv > 1) { //king side
      NSLog(@"Kingside castling: king xmv = %d\n", xmv);
      rook = [board cellAtX: 7 Y: f_y];
      rook_to = [board cellAtX: 5 Y: f_y];
    }

    [rook_to setPiece: [rook piece]];
    [rook setPiece: nil];
  }


  [to setPiece: [from piece]];
  [from setPiece: nil];
  selected_cell = nil;

  [view setNeedsDisplay];
}

- (ChessCell*)selected_cell {
  return selected_cell;
}

- (ChessEngine *)engine
{
    return engine;
}
@end
