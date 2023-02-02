


compiler:  y.tab.o lex.yy.o  symtab.o 
	g++ lex.yy.o y.tab.o  symtab.o 

y.tab.cpp: parser.y
	bison -d -o y.tab.cpp  parser.y

lex.yy.cpp: scanner.l
	flex -o lex.yy.cpp  scanner.l

y.tab.o: y.tab.cpp
	g++ -c y.tab.cpp

lex.yy.o: lex.yy.cpp
	g++ -c lex.yy.cpp

symtab.o: symtab.cpp symtab.h
	g++ -c symtab.cpp

# gen.o: gen.cpp gen.h
#	g++ -c gen.cpp

.PHONY: clean #fake項目
clean:
	rm -f *.o
