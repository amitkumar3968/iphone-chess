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
    [[_boardView controller] newGame];
  }

  [self saveBoard];

  [[_boardView controller] startGame];

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
  NSString* board_path = [[NSBundle mainBundle] pathForResource:@"board" ofType:@"tmp" ];
  
  NSFileHandle* board_file = [NSFileHandle fileHandleForReadingAtPath: board_path];
  NSData* data = [board_file readDataOfLength: 8*8];


  if([data length] >= 8*8) {
    NSLog(@"Loading board data from %@\n", board_path);
    ChessBoard* board = [_boardView board];
    
    [board clearPieces];

    for(int x=0; x < 8; ++x) {
      for(int y=0; y < 8; ++y) {
	char sym = ((char*)[data bytes])[x*8 + y];
	
	if(sym != '.') {
	  NSLog(@"(%d, %d) = %c\n", x,y,sym);
	  [[board cellAtX: x Y: y]
	    setPiece: [[ChessPiece alloc]
			initWithSymbol: sym
		       ]
	   ];
	}
      }
    }

    return YES;
  }

  NSLog(@"No board file at %@\n", board_path);
  return NO;
}

- (void)saveBoard
{
  char board_store[8][8];
  ChessBoard* board = [_boardView board];

  for(int x=0; x < 8; ++x) {
    for(int y=0; y < 8; ++y) {
      ChessCell* cell = [board cellAtX: x Y: y];
      if([cell piece]) {
	board_store[x][y] = [[cell piece] symbol];
      } else {
	board_store[x][y] = '.';
      }
    }
  }

  NSString* board_path = [[NSBundle mainBundle] pathForResource:@"board" ofType:@"tmp"];

  NSLog(@"Saving board data to %@\n", board_path);

  NSFileManager* fm = [NSFileManager defaultManager];
  [fm createFileAtPath: board_path
      contents:[NSData dataWithBytesNoCopy: board_store length: sizeof(board_store)]
      attributes: nil];
}

@end


