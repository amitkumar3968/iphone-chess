//
//  ChessView.m
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ChessView.h"
#import "ChessPiece_View.h"
#import "ChessBoard.h"

@implementation ChessView

- (id)initWithFrame:(CGRect)f
{
    self = [super initWithFrame:frame];
    
    if (self) {
      frame = f;

      UINavigationBar* nav = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0, 0.0, frame.size.width, 48.0)];
      [nav showButtonsWithLeftTitle:@"New" rightTitle:@"Stats"];
      [nav setBarStyle: 5];
      [self addSubview: nav];

      frame.size.height -= 48;
      frame.origin.y += 48;

      const int black_border = (frame.size.height-frame.size.width)/2;

      CGRect board_rect = frame;
      board_rect.origin.y += black_border;
      board_rect.size.height = board_rect.size.width;

      NSLog(@"Creating board...\n");
      board = [[ChessBoard alloc] initWithRect: board_rect inView: self];
      NSLog(@"Creating controller...\n");
      controller = [[ChessController alloc] initWithBoard: board inView: self];

      assert(controller && board);

      CGRect think_frame;
      think_frame.origin.y = frame.size.height+(black_border*0.1);
      think_frame.origin.x = (frame.size.width/2) - (black_border/2);
      think_frame.size.height = black_border*0.9;
      think_frame.size.width = black_border*0.9;

      thinkbar = [[UIProgressIndicator alloc] initWithFrame: think_frame];
      [self addSubview: thinkbar];
      [thinkbar setStyle: 5];

      [self initColors];

      NSLog(@"Created ChessView\n");
    }

    return self;
}

- (void)startWaiting:(id)unused;
{
  [thinkbar startAnimation];
}


- (void)stopWaiting:(id)unused;
{
  [thinkbar stopAnimation];
}

- (void)mouseDown:(GSEvent *)event
{
  CGRect rect = [board rect];
  CGPoint point = GSEventGetLocationInWindow(event);

  int cellWidth = (int)rect.size.width/8;
  int cellHeight = (int)rect.size.height/8;

  /*  NSLog(@"click at %f x %f in rect (%f, %f)(%f, %f)\n", point.x, point.y,
	rect.origin.x, rect.origin.y,
	rect.size.width, rect.size.height);
  */

  int x = (int)(point.x - rect.origin.x) / cellWidth;
  int y = 7 - ((int)(point.y - rect.origin.y) / cellHeight);
  
  NSLog(@"clicked: %d x %d\n", x, y);

  if(x >= 0 && x < 8 &&
     y >= 0 && y < 8) {
    ChessCell* clicked = [board cellAtX: x Y: y];

    assert([clicked x] == x && [clicked y] == y);

    [controller cellClicked: clicked inView: self];
  }
  
  [self setNeedsDisplay];
}

- (void)initColors
{
  CGContextRef context = UICurrentContext();
  float light[4] = { 1.0f, 0.8f, 0.61f, 1.0f };
  float dark[4] = { 0.81f, 0.54f, 0.27f, 1.0f };
  float select[4] = { 0.16f, 0.58f, 1.0f, 1.0f };

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  cell_light = CGColorCreate(colorSpace, light);
  cell_dark = CGColorCreate(colorSpace, dark);
  cell_select = CGColorCreate(colorSpace, select);
  CGColorSpaceRelease(colorSpace);
}

- (void)drawRect:(CGRect)r 
{
  NSLog(@"Drawing board...\n");
  CGContextRef context = UICurrentContext();

  const int cells = 8;
  
  const float width = [board rect].size.width;
  const float height = [board rect].size.height;

  ChessCell* selected = [controller selected_cell];

  for(int x = 0; x < cells; ++x) {
    for(int y = 0; y < cells; ++y) {
      ChessCell* cell = [board cellAtX:x Y:y];
      CGRect cell_rect = [cell rect];

      if(cell == selected) {
	CGContextSetFillColorWithColor(context, cell_select);
      } else {
	if((x+y) % 2 == 1) {
	  CGContextSetFillColorWithColor(context, cell_light);
	} else {
	  CGContextSetFillColorWithColor(context, cell_dark);
	}
      }

      CGContextFillRect(context, cell_rect);
    }
  }

  NSLog(@"Drew board\n");
}

- (ChessBoard *)board
{
    return board;
}

- (ChessController *)controller
{
    return controller;
}

@end
