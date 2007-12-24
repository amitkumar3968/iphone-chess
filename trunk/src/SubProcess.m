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

static SubProcess* instance = nil;

static void signal_handler(int signal) {
  NSLog(@"Caught signal: %d", signal);
  [instance dealloc];
  instance = nil;
  exit(1);
}

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

- (id)initWithDelegate:(id)inputDelegate
{
  if (instance != nil) {
    [NSException raise:@"Unsupported" format:@"Only one SubProcess"];
  }
  self = [super init];
  instance = self;
  wfd = -1;
  rfd = -1;

  delegate = inputDelegate;

  // Clean up when ^C is pressed during debugging from a console
  signal(SIGINT, &signal_handler);
  

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
    [self failure:@"[Failed to fork child process]"];
    exit(0);
  } else if (pid == 0) {
    // First try to use /bin/login since its a little nicer.  Fall back to
    // /bin/sh  if that is available.
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
  [NSThread detachNewThreadSelector:@selector(startIOThread:)
	    toTarget:self
	    withObject:delegate];

  NSLog(@"Yay\n");
  return self;
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

- (void)startIOThread:(id)inputDelegate
{
  [[NSAutoreleasePool alloc] init];
  const int kBufSize = 1024;
  char buf[kBufSize];
  ssize_t nread;
  while (1) {
    // Blocks until a character is ready
    nread = read(rfd, buf, kBufSize);
    // On error, give a tribute to OS X terminal
    if (nread == -1) {
      perror("read");
      [self close];
      [self failure:@"[Process completed]"];
      return;
    } else if (nread == 0) {
      [self close];
      [self failure:@"[Process completed]"];
      return;
    }
    [inputDelegate handleStreamOutput:buf length:nread];
  }
}

- (void)failure:(NSString*)message;
{
  // HACK: Just pretend the message came from the child
  [delegate handleStreamOutput:[message cString] length:[message length]];
}
@end
