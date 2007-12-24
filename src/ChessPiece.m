//
//  ChessPiece.m
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ChessPiece.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>

@implementation ChessPiece


-(id)initWithSymbol:(char)c {
  symbol = c;
  return self;
}


-(BOOL)isWhite
{
  return isupper(symbol);
}

-(BOOL)isBlack
{
  return islower(symbol);
}

-(BOOL)isColor:(NSString*)color
{
  NSString* iscolor = [self isWhite] ? @"white" : @"black";
  return [iscolor isEqualToString: color];
}

-(char)symbol
{
  return symbol;
}

@end
