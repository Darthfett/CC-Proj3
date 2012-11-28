CC = gcc
# This is the name of our compiler
BINARY = opc
LEX = flex
YACC = bison
DIFF = diff


# Flags
CFLAGS = -g -Wall
YACCFLAGS = -d -y -v 

OBJECTS = \
	main.o \
	symtab.o shared.o intermediate_rep.o

all:    yacc lex $(OBJECTS) tests_prepare
	$(CC) -o $(BINARY) $(CFLAGS) y.tab.c lex.yy.c $(OBJECTS)

lex:
	$(LEX) pascal.l

yacc:
	$(YACC) $(YACCFLAGS) pascal.y
	@# Play tricks with yacc to prepend our shared definitions
	echo "#include \"shared.h\"" >> y.tab.h.tmp
	cat y.tab.h >> y.tab.h.tmp
	rm y.tab.h
	mv y.tab.h.tmp y.tab.h

.c.o:
	$(CC) -c $(CFLAGS) $<
clean:
	-rm -f core $(BINARY) out.c *~
	-rm -f lex.yy.c y.tab.c y.tab.h y.tab.h.tmp y.output
	-rm -f $(OBJECTS)
	-rm -f tests_lib_shared_auto.inc
	-rm -f tests_semantic/results/$(BINARY).{log,sum}
	-rm -f tests_semantic/*.output
	-rm -f tests_semantic/out.c
	-rm -f tests_semantic/a.out

tests: tests_semantic tests_opt tests_gen

tests_semantic: tests_prepare
	# "runtest" comes from DejaGNU
	mkdir -p tests_semantic/results
	(cd tests_semantic; runtest --all --output results --tool $(BINARY) tests_semantic.exp)

tests_prepare:
	@echo "BINARY=../$(BINARY)" > tests_lib_shared_auto.inc

.PHONY: all lex yacc clean tests
