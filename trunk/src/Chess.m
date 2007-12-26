#import "Chess.h"
#import "ChessView.h"
#import "ChessBoard.h"

@implementation Chess : UIApplication

- (void) initApplication    
{
  struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
  rect.origin.x = rect.origin.y = 0.0f;

  _window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
  [_window orderFront: self];
  [_window makeKey: self];
  [_window _setHidden: NO];

  _boardView = [[ChessView alloc] initWithFrame: rect];
  
  if(![self loadBoard]) {
    [[_boardView controller] newGameWithHumanAs:@"white"];
  }

  [_window setContentView: _boardView]; 
}

- (void) applicationDidFinishLaunching: (id) unused
{
  [self initApplication];
  NSLog(@"Application init complete\n");
}


- (void)applicationExited:(GSEvent *)event
{
  [self saveBoard];

  [[[_boardView controller] engine] quit];
}

- (void)applicationResume:(GSEvent*)event
{
  [self loadBoard];
}

- (void)applicationWillTerminate:(GSEvent*)event
{
  [self saveBoard];
}

- (void)applicationSuspend:(GSEvent*)event
{
  [self saveBoard];
}

- (void)dealloc
{
  [self saveBoard];
  [super dealloc];
}

- (BOOL)loadBoard
{
  NSString* move_path = [[NSBundle mainBundle] pathForResource:@"board" ofType:@"tmp" ];
  
  NSArray* moves = [NSArray arrayWithContentsOfFile: move_path];
  if([moves count] > 0) {
    NSLog(@"%d moves in file: %@", [moves count], move_path);

    NSEnumerator* e = [moves objectEnumerator];
    NSString* move;

    ChessController* c = [_boardView controller];


    [c startWaiting];

    [c newGameWithHumanAs:@"white"];
    [c startManual];

    NSLog(@"Sending moves\n");
    while((move = [e nextObject])) {
      [c sendMove: move];
    }

    // do not disable manual mode or waiting
    // wait for gnuchess to process all sent moves
    
    return YES;
  } else {
    NSLog(@"No moves in file: %@", move_path);
    return NO;
  }
}

- (void)saveBoard
{
  NSString* board_path = [[NSBundle mainBundle] pathForResource:@"board" ofType:@"tmp"];
  NSLog(@"Saving board data to %@\n", board_path);

  NSFileHandle* move_file = [NSFileHandle fileHandleForWritingAtPath: board_path];
  
  [[[_boardView controller] move_history] writeToFile: board_path atomically: YES];
}

@end


