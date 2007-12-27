//
//  ChessController.m
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ChessController.h"
#import "ChessCell.h"

#import <Foundation/NSThread.h>

@implementation ChessMove
- (id)initFrom:(ChessCell*)f To:(ChessCell*)t
{
  self = [super init];
  if(self) {
    from = f;
    to = t;

    [from retain];
    [to retain];
  }
  return self;
}

- (id)initFromString:(NSString*)move onBoard:(ChessBoard*)board
{
  self = [super init];
  if(self) {
    const char* m = [move cString];
    
    int f_x = m[0] - 'a';
    int f_y = m[1] - '1';

    int t_x = m[2] - 'a';
    int t_y = m[3] - '1';

    NSLog(@"creating move from string: %@ = (%d, %d) (%d, %d)\n", move, f_x, f_y, t_x, t_y);

    from = [board cellAtX:f_x Y:f_y];
    to = [board cellAtX:t_x Y:t_y];

    [from retain];
    [to retain];
  }
  return self;
}

- (void)dealloc
{
  [from release];
  [to release];

  [super dealloc];
}

- (ChessCell*)from
{
  return from;
}

- (ChessCell*)to
{
  return to;
}
@end

@implementation ChessController

- (id)initWithBoard:(ChessBoard*)b inView:(UIView*)v
{
  self = [super init];
  
  if(self) {
    board = b;
    view = v;
    selected_cell = nil;

    if(board && view) {
      engine = [[ChessEngine alloc] initWithController: self];
      audio = [[ChessAudio alloc] init];

      UIImage* glow_image = [UIImage applicationImageNamed: @"pieceglow.png"];
      if(glow_image) {
	glow = [[UIImageView alloc] initWithImage: glow_image];
      }

      NSLog(@"starting engine thread\n");
      [NSThread detachNewThreadSelector:@selector(engineThread:)
		toTarget: self
		withObject:nil
       ];
    }
  }

  return self;
}

- (void)engineThread:(id)unused
{
  [[NSAutoreleasePool alloc] init];
  NSLog(@"engineThread started\n");

  while(1) {
    [engine waitForMove: &turn_num withDelegate: self];
  }
}

- (void)cellClicked:(ChessCell*)cell inView: (UIView*)view {
  if(turn_color && ![turn_color isEqualToString: player_color]) {
    NSLog(@"ignoring click during computer turn\n");
    return;
  }

  if(cell == selected_cell) {  // toggle cell selection
    [self selectCell: nil];
    return;
  } else if(selected_cell == nil || cell == nil) { // select new cell or deselect is cell is nil
    ChessPiece* p = [cell piece];
    if(p != nil) {
      if([p isColor: player_color]) {
	[self selectCell: cell];
      }
    }
  } else { // otherwise we are moving the piece from our selected cell to a new spot
    ChessPiece* selected_piece = [selected_cell piece];
    ChessPiece* new_piece = [cell piece];
    
    if(selected_piece && new_piece) {
      if([selected_piece isWhite] == [new_piece isWhite]) {
	[self selectCell: cell];
	return;
      }
    }
    
    NSString* move = [[NSString alloc] initWithFormat:@"%@%@", [selected_cell stringCoord], [cell stringCoord]];      
    [self sendMove: move];
    [self startWaiting];
  }

  NSLog(@"Click over\n");
}

- (void)selectCell:(ChessCell*)cell
{
  if(cell != nil ) {
    [audio playSelectCell];
  }

  selected_cell = cell;

  if(cell == nil) {
    [glow removeFromSuperview];
  } else {
    CGRect cr = [cell rect];
    CGRect glow_frame = cr;
    glow_frame.size.height = 204.0;
    glow_frame.size.width = 204.0;
    glow_frame.origin.x -= (102 - (cr.size.width / 2));
    glow_frame.origin.y -= (102 - (cr.size.height / 2));

    [glow setFrame: glow_frame];
    [view addSubview: glow];
    [view bringSubviewToFront: glow];
    [view bringSubviewToFront: [[cell piece_view] image_view]];
  }

  [view setNeedsDisplay];
}

- (void)movePiece:(ChessMove*)m
{
  ChessCell* from = [m from];
  ChessCell* to = [m to];
  
  if(![[from piece] isColor: turn_color]) {
    NSLog(@"Piece is not %@\n", turn_color);
    return;
  }
    
  [audio playMove];
  
  // check for castling
  if(tolower([[from piece] symbol]) == 'k') {
    const int xmv = [to x] - [from x];
    
    ChessCell* rook = nil;
    ChessCell* rook_to = nil;
    
    // detect which side was castled to
    if(xmv < -1) { // queenside
      NSLog(@"Queenside castling: king xmv = %d\n", xmv);
      rook = [board cellAtX: 0 Y: [from y]];
      rook_to = [board cellAtX: 3 Y: [from y]];
    } else if(xmv > 1) { //king side
      NSLog(@"Kingside castling: king xmv = %d\n", xmv);
      rook = [board cellAtX: 7 Y: [from y]];
      rook_to = [board cellAtX: 5 Y: [from y]];
    }
    
    [rook_to setPiece: [rook piece]];
    [rook setPiece: nil];
  }
  
  [to setPiece: [from piece]];
  [from setPiece: nil];
  [self selectCell: nil];

  NSLog(@"piece moved\n");
}


- (void)toggleTurn
{
  if([turn_color isEqualToString:@"white"]) {
    turn_color = @"black";
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>> It is now blacks turn (%d)\n", turn_num);
  } else if([turn_color isEqualToString:@"black"]) {
    turn_num += 1;

    turn_color = @"white";
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>> It is now whites turn (%d)\n", turn_num);
  }

  NSLog(@"ms = %d mr = %d\n", moves_sent, moves_recv);

  if(moves_sent <= moves_recv) { // engine is up to date      
    NSLog(@"engine is up to date\n");
    if([self isComputerTurn] == YES) { // computer is to play
      NSLog(@"engine is to play\n");

      [self selectCell: nil];

      if([engine canThink] == NO) { // computer is not thinking
	NSLog(@"engine is not thinking\n");
	[self stopManual];
      }
    } else {
      [self stopWaiting];
    }
  }
}

- (void)sendMove:(NSString*)move
{
  moves_sent += 1;

  NSLog(@"sending move %d\n", moves_sent);
  
  [engine sendMove: move];
}

- (void)newGameWithHumanAs:(NSString*)color
{
  [engine newGame];
  [board clearPieces];


  [self selectCell: nil];

  turn_num = 1;
  moves_sent = 0;
  moves_recv = 0;

  turn_color = @"white";

  if(player_color) {
    [player_color release];
  }
  player_color = color;
  [color retain];

  NSLog(@"Human is playing as %@\n", player_color);

  if([self isComputerTurn]) {
    [self startWaiting];
    [engine go]; // force engine to take first move
  }

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

  [view setNeedsDisplay];
}

- (void)startGame
{

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

- (NSString*)humanColorString 
{
  return player_color;
}

- (NSString*)computerColorString
{
  return [player_color isEqualToString:@"white"] ? @"black" : @"white";
}

- (void)startManual
{
  [engine setManual];
  NSLog(@"Entering manual state\n");
}

- (void)stopManual
{
  NSLog(@"Leaving manual state\n");

  if([self isComputerTurn]) {
    NSLog(@"Starting think for computers turn\n");
    [self startWaiting];
    [engine go];
  }
}

- (void)startWaiting
{
  [view performSelectorOnMainThread:@selector(startWaiting:)
	withObject:nil
	waitUntilDone:NO];
}

- (void)stopWaiting
{
  [view performSelectorOnMainThread:@selector(stopWaiting:)
	withObject:nil
	waitUntilDone:NO];
}

- (void)illegalMove:(NSString*)move
{
  moves_recv += 1;

  NSLog(@"Illegal move: %@\n", move);
  [self stopWaiting];
}

- (void)validMove:(NSString*)move {
  moves_recv += 1;

  if([self isHumanTurn]) {
    NSLog(@"Player move: %@\n", move);
    ChessMove* m = [[ChessMove alloc] initFromString: move onBoard: board];
    [self movePiece: m];
    [self toggleTurn];
  } else {
    [self engineMove: move];
  }
}

- (void)engineMove:(NSString*)move
{
  if([self isComputerTurn]) {
    NSLog(@"Engine move: %@\n", move);
    ChessMove* m = [[ChessMove alloc] initFromString: move onBoard: board];
    [self movePiece: m];
    [self toggleTurn];
  }
}

- (void)computerWin:(id)unused
{
  [view computerWinAlert];
}


- (void)humanWin:(id)unused
{
  [view humanWinAlert];
}

- (ChessCell*)selected_cell {
  return selected_cell;
}

- (ChessEngine *)engine
{
    return engine;
}

- (NSArray*)move_history
{
  return [engine move_history];
}
@end
