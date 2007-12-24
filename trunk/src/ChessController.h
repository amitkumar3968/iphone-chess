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

@interface ChessController : NSObject {
  ChessAudio* audio;
  ChessBoard* board;
  ChessCell* selected_cell;
  UIView* view;


  BOOL waiting;
  ChessEngine* engine;
  NSString* turn_color; // whose turn is it?
  NSString* player_color;
  NSMutableArray* white_taken; // pieces taken which are white
  NSMutableArray* black_taken; // pieces taken which are black
  NSMutableArray* move_history;
}

- (void)startGame;
- (void)newGame;
- (id)initWithBoard:(ChessBoard*)b inView:(UIView*)v;
- (void)cellClicked:(ChessCell*)cell inView:(UIView*)view;
- (ChessCell*)selected_cell;

- (void)toggleTurn;
- (BOOL)isComputerTurn;
- (BOOL)isHumanTurn;

- (void)engineMove:(NSString*)move;
- (void)illegalMove:(NSString*)move;
- (void)validMove:(NSString*)move;
- (void)doMove:(NSString*)move;
- (ChessEngine*)engine;


- (void)startWaiting;
- (void)stopWaiting;
@end
