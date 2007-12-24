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
CHESS=gnuchess-5.07/

PGNFILE=book_1.01.pgn.gz
PGNURL=http://ftp.gnu.org/pub/gnu/chess/$(PGNFILE)

all:	Chess gnuchess bundle zip

Chess:  main.o Chess.o ChessEngine.o ChessView.o ChessBoard.o ChessController.o ChessCell.o ChessPiece.o ChessPiece_View.o SubProcess.o ChessAudio.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	$(SRC)%.m
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

bundle: Chess
	mkdir -p Chess.app
	mkdir -p Chess.app/pieces
	mkdir -p Chess.app/sound

	echo -n > Chess.app/gnuchess.pid
	echo -n > Chess.app/board.tmp

	cp Chess Chess.app
	cp $(CHESS)/src/gnuchess Chess.app
	cp Info.plist Chess.app

	tar --exclude '*/.*' -C img/ -c . | tar -C Chess.app -x
	tar --exclude '*/.*' -c sound/ | tar -C Chess.app -x

#	cd Chess.app && curl "$(PGNURL)" | gzip -d | head -n 162447 > book.pgn
	
deploy:
	scp -rp Chess.app root@$(IP):/Applications

zip: bundle
	zip -9yr Chess.zip Chess.app

gnuchess:
	cd $(CHESS) && ./configure --host=arm && make

clean:
	rm -f *.o Chess Chess.zip
	rm -Rf Chess.app

	cd $(CHESS) && make clean
	rm -Rf $(SRC)/.deps/
