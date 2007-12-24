#import "ChessAudio.h"

#import <UIKit/CDStructures.h>
#import <Celestial/AVController.h>
#import <Celestial/AVItem.h>
#import <Celestial/AVQueue.h>

@implementation ChessAudio
- (id)init
{
  self = [super init];

  if(self) {
    NSError* err = nil;
    NSString* path = nil;

    // move
    path = [[NSBundle mainBundle] pathForResource:@"move" ofType:@"wav"];
    move = [[AVItem alloc] initWithPath:path error:&err];

    controller = [[AVController alloc] init];
    [controller setDelegate:self];

    queue = [[AVQueue alloc] init];
    [queue appendItem:move error:&err];
  }

  return self;
}

- (void)dealloc
{

  [move release]; move = nil;

  [queue release]; queue = nil;
  [controller release]; controller = nil;

  [super dealloc];
}

-(void)playMove
{
  [self play:move];
}

-(void)play:(AVItem *)item;
{
  NSError *err;

  [controller setCurrentItem:item];
  [controller setCurrentTime:(double)0.0];
  [controller play:&err];
}

-(void)stop;
{
  [controller pause];
}


@end
