#
# Devrived from:
# https://github.com/milkymist/scripts/blob/master/compile-lm32-rtems/Makefile
#
# Written 2011 by Xiangfu Liu <xiangfu@sharism.cc>
# this file try to manager build RTMS toolchain
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

RTEMS_VERSION=4.11
#make sure you have write access
RTEMS_PREFIX=`pwd`/install

RTEMS_SOURCES_URL=http://www.rtems.org/ftp/pub/rtems/SOURCES/$(RTEMS_VERSION)

# For Mac OS X use curl.
WGET=wget -c -O 
# WGET=curl -o 

NEWLIB_VERSION=1.19.0

NEWLIB=newlib-$(NEWLIB_VERSION).tar.gz

NEWLIB_PATCH=newlib-$(NEWLIB_VERSION)-rtems$(RTEMS_VERSION)-20111006.diff

DL=$(if $(wildcard ../dl/.),../dl,dl)

RTEMS_PATCHES_DIR=rtems-patches
MM1_PATCHES_DIR=milkymist-one-patches

.PHONY:	all clean install

all: .compile.newlib.ok 

install: .install.newlib.ok

.install.newlib.ok: .compile.newlib.ok
	cd build-newlib && make install
	touch $@

.compile.newlib.ok: .patch.ok gcc-$(GCC_CORE_VERSION)/newlib
	export PATH=$(RTEMS_PREFIX)/bin:$$PATH
	mkdir -p build-newlib
	(cd build-newlib/;\
          ../newlib-$(NEWLIB_VERSION)/configure --target=lm32-rtems4.11 \
          --with-gnu-as --with-gnu-ld --with-newlib --verbose --enable-threads \
          --enable-languages="c" --disable-shared --prefix=$(RTEMS_PREFIX); \
         make all; \
         make info; \
	)
	touch $@

gcc-$(GCC_CORE_VERSION)/newlib: .unzip.ok
#	(cd gcc-$(GCC_CORE_VERSION); ln -s ../newlib-$(NEWLIB_VERSION)/newlib;)

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

clean:
	rm -rf newlib-$(NEWLIB_VERSION)
	rm -rf .*.ok
	rm -rf .ok
