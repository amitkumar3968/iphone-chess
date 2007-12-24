#import "ChessEngine.h"


@implementation ChessEngine

-(id)initWithController:(id)c;
{
  NSLog(@"Launching chess engine...\n");
  controller = c;
  //  proc = [[SubProcess alloc] initProc:@"./gnuchess" Args:[NSArray arrayWithObject: @"-x"] withDelegate: self];
  proc = [[SubProcess alloc] initWithDelegate: self];
  is_running = NO;
}


-(void)moveFrom:(ChessCell*)f To:(ChessCell*)t
{
  char f_y = '1' + [f y];
  char f_x = 'a' + [f x];

  char t_y = '1' + [t y];
  char t_x = 'a' + [t x];

  NSString* move = [[NSString alloc] initWithFormat:@"%c%c%c%c\n", f_x, f_y, t_x, t_y];

  NSLog(@"Sending move to gnuchess: %@\n", move);

  if(last_move) {
    [last_move release];
  }

  last_move = move;

  [proc writeString: move];
}

-(void)handleStreamOutput:(const char*)buf length:(ssize_t)len
{
  static NSString* trailing = nil;

  NSString* newstr = [[NSString alloc] initWithBytes: buf length: len encoding: NSASCIIStringEncoding];

  NSMutableString* rawstr = [[NSMutableString alloc] init];
  if(trailing) {
    [rawstr appendString: trailing];
    [trailing release];
    trailing = nil;
  }

  [rawstr appendString: newstr]; 
  [newstr release];

  NSArray* lines = [rawstr componentsSeparatedByString:@"\n"];
  [rawstr release];

  NSEnumerator* e = [lines objectEnumerator];
  NSString* line;

  BOOL has_spare = YES;
  if([[lines lastObject] length] == 0) {
    has_spare = NO;
  } 

  while(line = [e nextObject]) {
    if([line length] == 0) continue;

    if(has_spare == YES && line == [lines lastObject]) {
      trailing = line;
    } else {
      NSString* str = [line stringByTrimmingCharactersInSet:
			      [NSCharacterSet whitespaceAndNewlineCharacterSet]];
      NSArray* words = [str componentsSeparatedByString:@" "];
      
      [self performSelectorOnMainThread:@selector(processLine:)
	    withObject:words
	    waitUntilDone:YES];      
      
      [str release];
      [words release];
    }
  }
}

-(void)engineConfigure
{
  [self setDepth: 4];
  [self setClock: 30*50];
  //  [self setBook: @"book.pgn"];
  [self setHashsize: pow(2, 16)];
}

-(void)processLine:(NSArray*)words {
  NSString* first = [words objectAtIndex: 0];  
  
  if(is_running == NO && [first hasPrefix:@"Chess"]) {
    NSLog(@"Chess engine is now running.\n");
    is_running = YES;
    
    [self engineConfigure];

    return;
  }

  if(is_running != YES) {
    return;
  }

  NSLog(@"Searching %d words...\n", [words count]);  
  NSEnumerator* e = [words objectEnumerator];
  NSString* s;
  while(s = [e nextObject]) {
    NSLog(@"Word: '%@'\n", s);
  }

  if([first isEqualToString:@"My"]) {
    NSLog(@">>>>>>>>>> engineMove\n");
    [controller engineMove:[words objectAtIndex: 3]];
  } else if([first isEqualToString:@"Illegal"]) {
    NSLog(@">>>>>>>>>> illegalMove\n");
    [controller illegalMove:[words objectAtIndex: 2]];
  } else if([first isEqualToString:@"Error"]) {
  } else if([first isEqualToString:@"result"]) {
  } else {
    if([words count] > 1 && last_move != nil) {
      NSString* word2 = [words objectAtIndex: 1];

      if([last_move hasPrefix: word2]) {
	NSLog(@">>>>>>>>>> validMove\n");
	[controller validMove:word2];
      }
    }
  }
}



-(void)newGame
{
  [proc writeString:@"new\n"];
}

-(void)go
{
  [proc writeString:@"go\n"];
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

@end
