//
//  ChessPiece.h
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChessPiece : NSObject {
  char symbol;
}

-(id)initWithSymbol:(char)c;
-(char)symbol;
-(BOOL)isWhite;
-(BOOL)isBlack;
-(BOOL)isColor:(NSString*)color;
@end


