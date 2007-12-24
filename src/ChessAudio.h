#import <Foundation/Foundation.h>

@class AVItem;
@class AVController;
@class AVQueue;

@interface ChessAudio : NSObject {
  AVItem* move;

  AVQueue* queue;
  AVController* controller;
}

- (void)playMove;
- (void)stop;
- (void)play:(AVItem *)item;
@end
