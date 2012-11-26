#
# Devrived from:
# https://github.com/milkymist/scripts/blob/master/compile-lm32-rtems/Makefile
#
# Written 2011 by Xiangfu Liu <xiangfu@sharism.cc>
# this file try to manager build RTMS toolchain
# Clang newlib version 2012 by JP Bonn
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

RTEMS_VERSION:=4.11
INSTALL_DIR:=$(shell pwd)/install

RTEMS_SOURCES_URL:=http://www.rtems.org/ftp/pub/rtems/SOURCES/$(RTEMS_VERSION)

# For Mac OS X use curl.
WGET=wget -c -O 
# WGET=curl -o 

NEWLIB_VERSION:=1.19.0

NEWLIB:=newlib-$(NEWLIB_VERSION).tar.gz

NEWLIB_PATCH:=newlib-$(NEWLIB_VERSION)-rtems$(RTEMS_VERSION)-20111006.diff

DL:=$(if $(wildcard ../dl/.),../dl,dl)

RTEMS_PATCHES_DIR:=rtems-patches
MM1_PATCHES_DIR:=milkymist-one-patches

.PHONY:	all clean install install-newlib install-libg build-newlib build-libg

all: install

install: install-newlib install-libg

install-newlib: build-newlib
	mkdir -p $(INSTALL_DIR)
	mkdir -p $(INSTALL_DIR)/lib
	cd build-newlib && \
	CFLAGS="-ffreestanding" make install

build-newlib: build-newlib/Makefile
	cd build-newlib && \
	CFLAGS="-ffreestanding" make 

install-libg: build-libg
	mkdir -p $(INSTALL_DIR)
	mkdir -p $(INSTALL_DIR)/lib
	cd build-libg && \
	CFLAGS="-I$(INSTALL_DIR)/lm32-elf/include/ -ffreestanding" make install

build-libg: build-libg/Makefile install-newlib
	cd build-libg && \
	CFLAGS="-I$(INSTALL_DIR)/lm32-elf/include/ -ffreestanding" make 


build-newlib/Makefile: .patch.ok
	mkdir -p build-newlib
	(cd build-newlib && \
	../newlib-1.19.0/configure \
	  --with-cross-host=x86_64-unknown-linux-gnu --build=x86_64-unknown-linux-gnu \
	  --host=lm32-elf --target=lm32-elf \
	  --with-target-subdir=lm32-elf \
	  --disable-libssp --enable-languages=c \
	  --prefix=$(INSTALL_DIR) \
	  --with-newlib \
	  CFLAGS="-O0 -g" \
	  CC="clang -ffreestanding -march=lm32 -target lm32 -ccc-gcc-name lm32-rtems4.11-gcc" \
	  CC_FOR_TARGET="clang -ffreestanding -march=lm32 -target lm32 -ccc-gcc-name lm32-rtems4.11-gcc" \
	  CC_FOR_BUILD="clang " \
	  PONIES=true \
	  LD=lm32-rtems4.11-ld \
	  OBJCOPY=lm32-rtems4.11-objcopy \
	  RANLIB=lm32-rtems4.11-ranlib \
	  AR=lm32-rtems4.11-ar \
	  AS=lm32-rtems4.11-as )

build-libg/Makefile: .patch.ok
	mkdir -p build-libg
	(cd build-libg && \
	../newlib-1.19.0/libgloss/configure --host=lm32-elf \
	  --prefix=$(INSTALL_DIR) \
	  CC="clang -march=lm32 -target lm32 -ccc-gcc-name lm32-rtems4.11-gcc" \
	  LD=lm32-rtems4.11-ld \
	  OBJCOPY=lm32-rtems4.11-objcopy \
	  RANLIB=lm32-rtems4.11-ranlib \
	  AR=lm32-rtems4.11-ar \
	  AS=lm32-rtems4.11-as ) 

.patch.ok: .unzip.ok $(RTEMS_PATCHES_DIR)/.ok
	(cd newlib-$(NEWLIB_VERSION); cat ../$(RTEMS_PATCHES_DIR)/$(NEWLIB_PATCH) | patch -p1)
	touch $@

.unzip.ok: $(DL)/$(NEWLIB).ok
	tar xf $(DL)/$(NEWLIB)
	touch $@

$(RTEMS_PATCHES_DIR)/.ok:
	mkdir -p $(RTEMS_PATCHES_DIR)
	$(WGET) $(RTEMS_PATCHES_DIR)/$(NEWLIB_PATCH) $(RTEMS_SOURCES_URL)/$(NEWLIB_PATCH)
	touch $@

$(DL)/$(NEWLIB).ok:
	mkdir -p $(DL)
	$(WGET) $(DL)/$(NEWLIB) $(RTEMS_SOURCES_URL)/$(NEWLIB)
	touch $@

clean-libg:
	rm -rf build-libg
	rm -rf .compile.libg.ok
	rm -rf .install.libg.ok

clean-newlib:
	rm -rf build-newlib
	rm -rf .compile.newlib.ok
	rm -rf .install.newlib.ok

clean:
	rm -rf newlib-$(NEWLIB_VERSION) build-libg build-newlib
	rm -rf .*.ok
	rm -rf .ok
