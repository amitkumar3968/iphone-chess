//
//  ChessController.h
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>

#import "ChessBoard.h"
#import "ChessCell.h"
#import "ChessEngine.h"
#import "ChessAudio.h"

@interface ChessMove : NSObject {
  ChessCell* from;
  ChessCell* to;
}

- (id)initFrom:(ChessCell*)f To:(ChessCell*)t;
- (id)initFromString:(NSString*)move onBoard:(ChessBoard*)board;
- (void)dealloc;
- (ChessCell*)from;
- (ChessCell*)to;

@end

@interface ChessController : NSObject {
  ChessAudio* audio;
  ChessBoard* board;
  ChessCell* selected_cell;
  UIView* view;


  BOOL waiting;
  ChessEngine* engine;

  NSString* turn_color; // whose turn is it?
  NSString* player_color;

  int turn_num;
  int moves_sent;
  int moves_recv;

  NSMutableArray* white_taken; // pieces taken which are white
  NSMutableArray* black_taken; // pieces taken which are black
}

- (void)startGame;
- (void)newGameWithHumanAs:(NSString*)color;
- (id)initWithBoard:(ChessBoard*)b inView:(UIView*)v;
- (void)cellClicked:(ChessCell*)cell inView:(UIView*)view;

- (void)movePiece:(ChessMove*)move;

- (void)toggleTurn;
- (BOOL)isComputerTurn;
- (BOOL)isHumanTurn;

- (void)engineThread:(id)unused;

- (void)sendMove:(NSString*)move;

- (void)engineMove:(NSString*)move;
- (void)illegalMove:(NSString*)move;
- (void)validMove:(NSString*)move;
- (void)computerWin:(id)unused;
- (void)humanWin:(id)unused;

- (void)startManual;
- (void)stopManual;

- (void)startWaiting;
- (void)stopWaiting;

- (ChessEngine*)engine;
- (ChessCell*)selected_cell;
- (NSArray*)move_history;
@end
