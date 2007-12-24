//
//  ChessPiece_View.h
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIImageView.h>
#import <GraphicsServices/GraphicsServices.h>

#import "ChessPiece.h"

@interface ChessPiece_View : NSObject {
  ChessPiece* piece;	
  CGImageRef image;
  CGRect rect;
  UIImageView* image_view;
  UIView* view;
}

-(id)initWithPiece:(ChessPiece*)p andRect:(CGRect)r inView:(UIView*)v;
-(void)initImage;
																	       
-(ChessPiece*)piece;
-(UIImageView*)image_view;
@end
