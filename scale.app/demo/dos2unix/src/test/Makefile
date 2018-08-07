TESTS = ascii.t iso.t utf8.t utf16.t misc.t

d2u_os=$(shell uname -s)

# Checking WIN32 version in MSYS shell.
ifeq ($(findstring MINGW,$(d2u_os)),MINGW)
TESTS += gb18030.t
endif

ifneq ($(findstring FreeBSD,$(d2u_os)),FreeBSD)
# Unix/Linux/Cygwin. Check if zh_CN.gb18030 locale is supported.
ifeq ($(shell ./chk_loc.sh zh_CN.gb18030),yes)
TESTS += gb18030.t
endif
endif

# Windows version does not support symlinks like the Unix version.
ifneq ($(findstring MINGW,$(d2u_os)),MINGW)
TESTS += symlink.t
endif


all: test

check: test

test:
	prove -v $(TESTS)


ascii:
	prove -v $@.t

iso:
	prove -v $@.t

misc:
	prove -v $@.t

utf8:
	prove -v $@.t

utf16:
	prove -v $@.t

gb18030:
	prove -v $@.t

symlink:
	prove -v $@.t

wcstombs:
	$(CC) -Wall -Wextra wcstombs_test.c -o wcstombs_test
	@echo "====> test wcstombs() UTF-8"
	LC_ALL=en_US.UTF-8 ./wcstombs_test
	@echo "====> test wcstombs() GB18030"
	LC_ALL=zh_CN.GB18030 ./wcstombs_test

clean:
	rm -f out*.txt in_link.txt wcstombs_test
