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
  NSLog(@"Checking saved boards...\n");
  if(![self loadBoard]) {
    [[_boardView controller] newGameWithHumanAs:@"white"];
  }

  [self saveBoard];

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
  [[[_boardView controller] engine] cont];
}

- (void)applicationWillTerminate:(GSEvent*)event
{
  [self saveBoard];
  [[[_boardView controller] engine] pause];
}

- (void)applicationSuspend:(GSEvent*)event
{
  [self saveBoard];
  [[[_boardView controller] engine] pause];
}

- (void)dealloc
{
  [self saveBoard];
  [super dealloc];
}

- (BOOL)loadBoard
{
  NSString* move_path = [[NSBundle mainBundle] pathForResource:@"board" ofType:@"plist" ];  
  NSArray* game = [NSArray arrayWithContentsOfFile: move_path];

  NSLog(@"Loaded array from %@. Has %d items\n", move_path, [game count]);

  if([game count] == 2) {
    NSArray* moves = [game objectAtIndex: 0];
    NSString* human = [game objectAtIndex: 1];

    NSLog(@"%d moves in file: %@", [moves count], move_path);

    NSEnumerator* e = [moves objectEnumerator];
    NSString* move;

    ChessController* c = [_boardView controller];

    [c startWaiting];

    [c newGameWithHumanAs:human];
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
  NSString* board_path = [[NSBundle mainBundle] pathForResource:@"board" ofType:@"plist"];
  NSLog(@"Saving board data to %@\n", board_path);

  ChessController* c = [_boardView controller];

  NSMutableArray* game = [[NSMutableArray alloc] init];
  [game addObject: [c move_history]];
  [game addObject: [c humanColorString]];

  NSLog(@"data: %@\n", [game description]);

  [game writeToFile: board_path atomically: YES];

  [game release];
}

@end


