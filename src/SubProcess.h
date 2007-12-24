// SubProcess.h
#import <Foundation/Foundation.h>

@protocol InputDelegateProtocol
- (void)handleStreamOutput:(const char*)c length:(unsigned int)len;
@end

@interface SubProcess : NSObject
{
  int rfd;
  int wfd;
  int child_pid;
  id delegate;
}

// Delegate should support InputDelegateProtocol
- (id)initWithDelegate:(id)inputDelegate;
- (void)dealloc;
- (void)close;
- (BOOL)isRunning;
- (int)write:(const char*)c length:(unsigned int)len; 
- (int)writeString:(NSString*)string;
- (void)startIOThread:(id)inputDelegate;
- (void)failure:(NSString*)message;

@end
