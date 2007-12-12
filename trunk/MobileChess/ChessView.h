#import <Cocoa/Cocoa.h>
#import "ChessCell.h"
#import "ChessBoard.h"
#import "ChessController.h"

@interface ChessView : NSView {
    ChessBoard *board;
    CGImageRef boardimage;
    IBOutlet ChessController *controller;
}

- (void)renderCell:(ChessCell *)cell;

- (void)initImages;

- (ChessBoard *)board;

@end

