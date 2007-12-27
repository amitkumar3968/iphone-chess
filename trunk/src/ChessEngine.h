
#import <Foundation/Foundation.h>
#import "SubProcess.h"

@interface ChessEngine : NSObject {
  SubProcess* proc;
  id controller;

  BOOL is_running;
  BOOL can_think;
  NSMutableArray* move_history;
}

-(id)initWithController:(id)c;
-(void)sendMove:(NSString*)move;
-(void)waitForMove:(int)move_num withDelegate:(id)delegate;

-(NSArray*)move_history;

-(void)newGame;
-(void)go;
-(void)quit;
-(void)moveNow;
-(void)hint;

-(void)setManual;
-(void)setDepth:(int)d;
-(void)setClock:(float)c;
-(void)setBook:(NSString*)book;
-(void)setHashsize:(int)h;


-(BOOL)canThink;

-(void)pause;
-(void)cont;

@end


