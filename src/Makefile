MAIN = executable executable.ps
all : clean $(MAIN)

lex.yy.c: turtleLex.l
	flex -d turtleLex.l

turtleBison.tab.c turtleBison.tab.h: turtleBison.y
	bison -d turtleBison.y

executable: lex.yy.c turtleBison.tab.c turtleBison.tab.h symtab.c symtab.h
	gcc lex.yy.c turtleBison.tab.c symtab.c -o executable

executable.ps: MyTurtleProgram.tlt executable
	./executable < MyTurtleProgram.tlt > executable.ps

clean :
	rm -f lex.yy.c turtleBison.tab.* *.ps *.o
	rm -f executable
