#import <Foundation/Foundation.h>

@class AVItem;
@class AVController;
@class AVQueue;

@interface ChessAudio : NSObject {
  AVItem* move;
  AVItem* select;

  AVQueue* queue;
  AVController* controller;
}

- (void)playMove;
- (void)playSelectCell;
- (void)stop;
- (void)play:(AVItem *)item;
@end
