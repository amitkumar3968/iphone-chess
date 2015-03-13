To build gnuchess you simply need to modify config.h so that it does not `#define malloc _rpl_malloc` or realloc and then

`CC="arm-apple-darwin-gcc -v" CXX=/usr/local/bin/arm-apple-darwin-g++ ./configure --host=arm && make`

this will generate iPhone compatible gnuchess and gnuchessx binaries.