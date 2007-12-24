//
//  ChessPiece_View.m
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ChessPiece_View.h"


@implementation ChessPiece_View

-(id)initWithPiece:(ChessPiece*)p andRect:(CGRect)r inView:(UIView*)v {
  piece = p;
  rect = r;
  view = v;

  assert(piece && view);

  [piece retain];
  [self initImage];

  return self;
}

- (void)initImage
{

  NSString* color = [piece isWhite] ? @"white" : @"black";
  NSString* name = [[NSString alloc] initWithFormat:@"pieces/%@/%c.png", color, [piece symbol]];
  UIImage* image = [UIImage applicationImageNamed: name];
  [name release];

  if(image) {
    //NSLog(@"Loaded image named %@\n", name);
    image_view = [[UIImageView alloc] initWithImage: image];
    [image_view setFrame: rect];
    [view addSubview: image_view];
    [view setNeedsDisplay];
  } else {
    NSLog(@"Failed to load image named %@\n", name);
  }
}

-(ChessPiece*)piece {
  return piece;
}

-(UIImageView*)image_view {
  return image_view;
}

-(void)release
{
  [image_view removeFromSuperview];
  [image_view release];
  [piece release];
  [super release];
}
@end
