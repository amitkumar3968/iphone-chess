//
//  main.m
//  MobileChess
//
//  Created by Alex Stapleton on 11/12/2007.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chess.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    return UIApplicationMain(argc, argv, [Chess class]);
}
