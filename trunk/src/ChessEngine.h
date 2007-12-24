
#import <Foundation/Foundation.h>
#import "ChessCell.h"
#import "SubProcess.h"

@interface ChessEngine : NSObject {
  SubProcess* proc;
  id controller;
  NSString* last_move;
  BOOL is_running;
}

-(id)initWithController:(id)c;
-(void)moveFrom:(ChessCell*)f To:(ChessCell*)t;
-(void)handleStreamOutput:(const char*)buf length:(ssize_t)len;
-(void)processLine:(NSArray*)words;

-(void)newGame;
-(void)go;
-(void)quit;
-(void)moveNow;
-(void)hint;

-(void)setDepth:(int)d;
-(void)setClock:(float)c;
-(void)setBook:(NSString*)book;
-(void)setHashsize:(int)h;





@end


