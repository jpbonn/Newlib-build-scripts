#
# ensure LM32 clang is default clang, set INSTALL_DIR, then do make.
# uses LM32 binutils for linking and assembly.
#

INSTALL_DIR:=$(shell pwd)/install
TOP_DIR:=$(shell pwd)

# For Mac OS X use curl.
WGET=wget -c -O 
# WGET=curl -o 

NEWLIB_VERSION:=2.2.0-1

NEWLIB:=newlib-$(NEWLIB_VERSION)

NEWLIB_SOURCES_URL:=ftp://sources.redhat.com/pub/newlib/newlib-$(NEWLIB_VERSION).tar.gz

DL:=$(if $(wildcard ../dl/.),../dl,dl)


.PHONY:	all clean install install-newlib build-newlib

all: install

install: install-newlib

install-newlib: build-newlib
	mkdir -p $(INSTALL_DIR)
	mkdir -p $(INSTALL_DIR)/lib
	cd build-newlib && \
	make install

build-newlib: build-newlib/Makefile
	cd build-newlib && \
	CFLAGS="-ffreestanding" make 

build-newlib/Makefile: .unzip.ok
	mkdir -p build-newlib
	(cd build-newlib && \
	../$(NEWLIB)/configure \
	--prefix=$(INSTALL_DIR) \
 	--target=lm32-elf \
	AR_FOR_TARGET=lm32-elf-ar \
	AS_FOR_TARGET=lm32-elf-as \
	LD_FOR_TARGET=lm32-elf-ld \
	CFLAGS_FOR_TARGET=" -O0 -g " \
	RANLIB_FOR_TARGET=lm32-elf-ranlib \
	CC_FOR_TARGET="clang -ffreestanding --target=lm32-elf -ccc-gcc-name lm32-elf-gcc" )

.unzip.ok: $(DL)/$(NEWLIB).ok
	tar xf $(DL)/$(NEWLIB)
	touch $@

$(DL)/$(NEWLIB).ok:
	mkdir -p $(DL)
	$(WGET) $(DL)/$(NEWLIB) $(NEWLIB_SOURCES_URL)
	touch $@

distclean: clean
	rm -rf dl 

clean:
	rm -rf newlib-$(NEWLIB_VERSION) build-newlib
	rm -rf .*.ok
	rm -rf .ok
	rm -rf build-newlib
	rm -rf .compile.newlib.ok
	rm -rf .install.newlib.ok
