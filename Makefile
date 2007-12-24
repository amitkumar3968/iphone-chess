CC=arm-apple-darwin-gcc 
CXX=/usr/local/bin/arm-apple-darwin-g++ 

LD=$(CC)
LDFLAGS = -framework CoreFoundation \
          -framework Foundation \
          -framework UIKit \
          -framework LayerKit \
          -framework CoreGraphics \
          -framework GraphicsServices \
          -framework CoreSurface \
	  -framework Celestial \
          -lobjc

CFLAGS=-Wall -std=c99 -g

IP=10.0.10.131
IP=10.0.1.3

SRC=src/
IMG=img/
SOUND=sound/

all:	Chess bundle

Chess:  main.o Chess.o ChessEngine.o ChessView.o ChessBoard.o ChessController.o ChessCell.o ChessPiece.o ChessPiece_View.o SubProcess.o ChessAudio.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	$(SRC)%.m
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

bundle: Chess
	mkdir -p Chess.app
	echo -n > Chess.app/gnuchess.pid
	echo -n > Chess.app/board.tmp
	cp Chess Chess.app
	cp -R $(IMG)* Chess.app
	cp -R $(SOUND)* Chess.app
	cp gnuchess Chess.app
	cp Info.plist Chess.app

deploy:
	make bundle
	scp -rp Chess.app root@$(IP):/Applications

zip: bundle
	zip -9yr Chess.zip Chess.app

clean:
	rm -f *.o Chess Chess.zip
	rm -Rf Chess.app

