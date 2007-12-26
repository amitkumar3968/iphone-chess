// SubProcess.m
#import "SubProcess.h"

#include <stdlib.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <util.h>
#include <sys/ioctl.h>

@implementation SubProcess

int start_process(const char* path, char* const args[], char* const env[]) {
  struct stat st;
  if (stat(path, &st) != 0) {
    fprintf(stderr, "%s: File does not exist\n", path);
    return -1;
  }
  if ((st.st_mode & S_IXUSR) == 0) {
    fprintf(stderr, "%s: Permission denied\n", path);
    return -1;
  }
  if (execve(path, args, env) == -1) {
    perror("execlp:");
    return -1;
  }
  // execve never returns if successful
  return 0;
}

- (id)init
{
  self = [super init];

  wfd = -1;
  rfd = -1;

  int old_pid = [self readPidFile];
  if(old_pid) {
    NSLog(@"Killing old gnuchess: %d\n", old_pid);
    kill(old_pid, 9);
  }

  int read_pipe[2];
  int write_pipe[2];

  if(pipe(read_pipe) < 0 || pipe(write_pipe) < 0) {
    NSLog(@"Failed to create IPC pipes: %s\n", strerror(errno));
    exit(0);
  }

  pid_t pid = fork();
  if (pid == -1) {
    perror("fork");
    exit(0);
  } else if (pid == 0) {
    char* chess_args[] = {"gnuchess", "-x", (char)0};
    char* env[] = { (char*)0 };

    dup2(write_pipe[0], 0); close(write_pipe[0]);
    dup2(read_pipe[1], 1); close(read_pipe[1]);

    rfd = 0;
    wfd = 1;

    start_process("/Applications/Chess.app/gnuchess", chess_args, env);
    exit(0);
  }

  close(read_pipe[1]);
  close(write_pipe[0]);

  rfd = read_pipe[0];
  wfd = write_pipe[1];

  child_pid = pid;

  [self writePidFile];

  NSLog(@"Child process id: %d\n", pid);

  if(rfd > -1 && wfd > -1 && child_pid) {
    return self;
  } else {
    [self release];
    return nil;
  }
}

- (int)readPidFile
{
  NSString* pidpath = [[NSBundle mainBundle] pathForResource:@"gnuchess" ofType:@"pid"];
  NSFileHandle* pf = [NSFileHandle fileHandleForReadingAtPath: pidpath];
  
  int p = ((int*)[[pf readDataOfLength: sizeof(int)] bytes])[0];

  [pf closeFile];
  
  return p;
}

- (void)writePidFile
{
  NSString* pidpath = [[NSBundle mainBundle] pathForResource:@"gnuchess" ofType:@"pid"];

  NSFileManager* fm = [NSFileManager defaultManager];
  NSData* data = [NSData dataWithBytes: &child_pid length: sizeof(child_pid)];

  [fm createFileAtPath: pidpath
      contents:data
      attributes: nil];
}

- (void)dealloc
{
  [self close];
  [super dealloc];
}

- (void)close
{
  NSLog(@"Closing fds\n");

  if (rfd >= 0) {
    close(rfd);
    rfd = -1;
  }

  if (wfd >= 0) {
    close(wfd);
    wfd = -1;
  }

  if(child_pid) {
    NSLog(@"Waiting for gnuchess (%d) to shutdown...\n", child_pid);
    kill(child_pid, 15);
    waitpid(child_pid, NULL, 0);
    child_pid = 0;

    [self writePidFile];
  }
}

- (BOOL)isRunning
{
  return ((wfd >= 0) ? YES : NO) && ((rfd >= 0) ? YES : NO);
}

- (int)write:(const char*)data length:(unsigned int)length
{
  return write(wfd, data, length);
}


- (int)writeString:(NSString*)string
{
  return [self write: [string cString] length:[string length]];
}

- (NSString*)readLine
{
  static NSString* trailing = nil;
  static NSMutableArray* lines = nil;

  if([lines count] > 0) {
    NSString* line = [lines objectAtIndex: 0];
    NSLog(@"line >> %@\n", line);
    [lines removeObjectAtIndex: 0];
    return line;
  } else {
    if(lines == nil) {
      lines = [[NSMutableArray alloc] init];
    }
  }

  char buf[1024];
  int nread = read(rfd, buf, sizeof(buf));

  if(nread > 0) {
    NSMutableString* data = [[NSMutableString alloc] init];
    if(trailing) {
      [data appendString: trailing];
    }

    [data appendString: [NSString stringWithCString: buf length: nread]];

    NSArray* new_lines = [data componentsSeparatedByString:@"\n"];
    BOOL has_spare = NO;
    if([new_lines lastObject] != @"") {
      has_spare = YES;
    }

    NSEnumerator* e = [new_lines objectEnumerator];
    NSString* l;
    while((l = [e nextObject])) {
      if(has_spare == YES && l == [new_lines lastObject]) {
	trailing = [new_lines lastObject];
      } else {
	[lines addObject: l];
      }
    }

    //    [new_lines release];
    [data release];

    return [self readLine];
  } else {
    [self close];
  }
}

@end
