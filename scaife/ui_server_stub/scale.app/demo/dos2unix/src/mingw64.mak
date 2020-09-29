# Author: Erwin Waterlander
# Copyright (C) 2012-2014 Erwin Waterlander
# This file is distributed under the same license as the dos2unix package.

# This makefile is for use with MSYS2 and MinGW-w64 target 64 bit (x86_64)
# http://sourceforge.net/projects/msys2/
.PHONY: test check

# Ruben van Boxem x86_64-w64-mingw32
#CC = x86_64-w64-mingw32-gcc
#STRIP = x86_64-w64-mingw32-strip
#CRT_GLOB_OBJ = C:/mingw64/mingw/lib/CRT_glob.o

# MSYS2
CC = gcc
STRIP = strip
CRT_GLOB_OBJ = /mingw64/x86_64-w64-mingw32/lib/CRT_glob.o

prefix=c:/usr/local64
ENABLE_NLS=

ifdef ENABLE_NLS
LIBS_EXTRA = -lintl -liconv
ZIPOBJ_EXTRA = bin/libintl-8.dll bin/libiconv-2.dll
endif
LIBS_EXTRA += $(CRT_GLOB_OBJ)

all:
	$(MAKE) all EXE=.exe ENABLE_NLS=$(ENABLE_NLS) LIBS_EXTRA="$(LIBS_EXTRA)" prefix=$(prefix) LINK="cp -f" CC=$(CC) CFLAGS_OS=-I/mingw64/include

test: all
	cd test; $(MAKE) test

check: test

install:
	$(MAKE) install EXE=.exe ENABLE_NLS=$(ENABLE_NLS) LIBS_EXTRA="$(LIBS_EXTRA)" prefix=$(prefix) LINK="cp -f" CC=$(CC) CFLAGS_OS=-I/mingw64/include

uninstall:
	$(MAKE) uninstall EXE=.exe prefix=$(prefix)

clean:
	$(MAKE) clean EXE=.exe ENABLE_NLS=$(ENABLE_NLS) prefix=$(prefix)

mostlyclean:
	$(MAKE) mostlyclean EXE=.exe ENABLE_NLS=$(ENABLE_NLS) prefix=$(prefix)

dist:
	$(MAKE) dist-zip EXE=.exe prefix=$(prefix) VERSIONSUFFIX="-win64" ZIPOBJ_EXTRA="${ZIPOBJ_EXTRA}" ENABLE_NLS=$(ENABLE_NLS)

strip:
	$(MAKE) strip LINK="cp -f" EXE=.exe  STRIP=$(STRIP)

