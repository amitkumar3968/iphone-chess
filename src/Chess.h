#import <UIKit/UIKit.h>

#import "ChessView.h"

@interface Chess : UIApplication
{
  ChessView *_boardView;
  UIWindow *_window;
}

-(void)saveBoard;
-(BOOL)loadBoard;

@end



