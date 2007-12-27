#import <CoreGraphics/CGColorSpace.h>
#import <CoreGraphics/CGColor.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIProgressIndicator.h>

#import "ChessBoard.h"
#import "ChessController.h"
#import "ChessCell.h"


@interface ChessResultHandler : NSObject {
  ChessController* controller;
}
- (id)initWithController:(ChessController*)c;
- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button;
@end

@interface ChessNewGameHandler : NSObject {
  ChessController* controller;
}
- (id)initWithController:(ChessController*)c;
- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button;
@end

@interface ChessView : UIView {
    struct CGColor* cell_light; // RGBA: 255, 206, 158, 0
    struct CGColor* cell_dark; // RGBA: 209, 139, 71, 0
    struct CGColor* cell_select; // RGBA: 0,0,0,0

    UIProgressIndicator* thinkbar;
    UIAlertSheet* alert_new;
    UIAlertSheet* alert_result;

    CGRect frame;

    ChessBoard *board;	
    ChessController *controller;
}

- (void)computerWinAlert;
- (void)humanWinAlert;

- (void)mouseDown:(GSEvent *)event;

- (void)startWaiting:(id)unused;
- (void)stopWaiting:(id)unused;

- (void)renderCell:(ChessCell *)cell;

- (void)initGraphics;
- (void)initColors;



- (ChessBoard *)board;
- (ChessController *)controller;

@end

