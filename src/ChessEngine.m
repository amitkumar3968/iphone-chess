#import "ChessEngine.h"


@implementation ChessEngine

-(id)initWithController:(id)c;
{
  self = [super init];

  if(self) {
    NSLog(@"Launching chess engine...\n");
    controller = c;
    move_history = [[NSMutableArray alloc] init];
    proc = [[SubProcess alloc] init];
    NSLog(@"gnuchess started\n");
    is_running = NO;
    can_think = NO;
  } 

  return self;
}

-(void)sendMove:(NSString*)move
{
  NSLog(@"Sending move to gnuchess: %@\n", move);

  [proc writeString: move];
  [proc writeString: @"\n"];
}

-(void)waitForMove:(int*)move_num withDelegate:(id)delegate
{
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc ]init ];
  
  NSString* line;

  NSLog(@"Waiting for move (%d) from gnuchess...\n", *move_num);
  while((line = [proc readLine])) {
    NSArray* words = [line componentsSeparatedByString:@" "];

    if([line hasPrefix: @"Illegal move"]) {
      [delegate performSelectorOnMainThread:@selector(illegalMove:)
		withObject:[words lastObject]
		waitUntilDone:NO];
      return;
    }
    
    NSRange dec_range = [line rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
    NSRange dot_range = [line rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]];

    if(dec_range.location == 0 &&
       dot_range.location != NSNotFound) {
      NSString* decimals = [line substringToIndex: dot_range.location];
      int lmn = [decimals intValue];
      
      if(lmn >= *move_num || lmn == 1) {
	[move_history addObject: [words lastObject]];
	[delegate performSelectorOnMainThread:@selector(validMove:)
		  withObject:[words lastObject]
		  waitUntilDone:NO];
	return;
      }
    }

    if([line hasPrefix:@"0-1 {computer wins as black}"] ||
       [line hasPrefix:@"1-0 {computer wins as white}"])
      {
	[delegate performSelectorOnMainThread:@selector(computerWin:)
		  withObject:nil
		  waitUntilDone:NO];
	return;
      }
    else if ([line hasPrefix:@"1-0 {computer loses as black}"] ||
		 [line hasPrefix:@"0-1 {computer loses as white}"])
      {
	
	[delegate performSelectorOnMainThread:@selector(humanWin:)
		  withObject:nil
		  waitUntilDone:NO];
      	return;
      }
  }

  [pool release];
}


-(void)engineConfigure
{
  NSLog(@"Setting engine config\n");
  [self setDepth: 4];
  [self setClock: 30*50];
  [self setBook: @"book.pgn"];
  [self setHashsize: pow(2, 16)];
}

-(void)newGame
{
  NSLog(@">>>>>>>>> newGame\n");
  [proc writeString:@"new\n"];
  [move_history removeAllObjects];
  can_think = YES;
}

-(void)go
{
  [proc writeString:@"go\n"];
  can_think = YES;
}

-(void)quit
{
  [proc writeString:@"quit\n"];
}

-(void)setBook:(NSString*)book
{
  NSString* sb = [[NSString alloc] initWithFormat:@"book add %@\n", book];
  [proc writeString: sb];
  [sb release];
}

-(BOOL)canThink
{
  return can_think;
}

-(NSArray*)move_history
{
  return move_history;
}

-(void)setManual
{
  [proc writeString: @"manual\n"];
  can_think = NO;
}

-(void)setDepth:(int)d
{
  NSString* sd = [[NSString alloc] initWithFormat:@"depth %d\n", d];
  [proc writeString: sd];
  [sd release];
}

-(void)setClock:(float)s
{
  const int cs = s*100;
  NSString* time = [[NSString alloc] initWithFormat:@"time %d\n", cs];
  [proc writeString: time];
  [time release];
}

-(void)setHashsize:(int)h
{
  NSString* hash = [[NSString alloc] initWithFormat:@"hashsize %d\n", h];
  [proc writeString: hash];
  [hash release];
}

-(void)moveNow
{
  [proc writeString: @"?\n"];
}

-(void)hint
{
  [proc writeString: @"hint\n"];
}

-(void)draw
{
  [proc writeString: @"draw\n"];
}

-(void)pause
{
  [proc pause];
}

-(void)cont
{
  [proc cont];
}

-(void)dealloc
{
  [self quit];
  [super dealloc];
}

@end
