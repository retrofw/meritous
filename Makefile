#
#   Makefile
#
#   Copyright 2007, 2008 Lancer-X/ASCEAI
#
#   This file is part of Meritous.
#
#   Meritous is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   Meritous is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Meritous.  If not, see <http://www.gnu.org/licenses/>.
#

CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CC = $(CROSS_COMPILE)gcc
STRIP = $(CROSS_COMPILE)strip

SYSROOT		:= $(shell $(CC) --print-sysroot)
CFLAGS		:= $(shell $(SYSROOT)/usr/bin/sdl-config --cflags) -Wall -g -DWITH_HOME_DIR
LDFLAGS		:= $(shell $(SYSROOT)/usr/bin/sdl-config --libs) -lSDL_image -lSDL_mixer -lz -lm
TARGET		:= meritous/meritous.elf

ifdef DEBUG
	CFLAGS	+= -ggdb
else
	CFLAGS	+= -O2
endif

OBJS = 	src/levelblit.o \
		src/mapgen.o \
		src/demon.o \
		src/gamemap.o \
		src/tiles.o \
		src/save.o \
		src/help.o \
		src/audio.o \
		src/boss.o \
		src/ending.o
#
default:	meritous

%.o:		%.c
		${CC} -c -o $@ $? ${CFLAGS}

meritous:	${OBJS}
		${CC} -o ${TARGET} $+ ${LDFLAGS}
ifndef DEBUG
		${STRIP} ${TARGET}
endif

ipk: meritous
	@rm -rf /tmp/.meritous-ipk/ && mkdir -p /tmp/.meritous-ipk/root/home/retrofw/games/meritous /tmp/.meritous-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@cp -r meritous/meritous.elf meritous/meritous.png meritous/meritous.man.txt meritous/dat /tmp/.meritous-ipk/root/home/retrofw/games/meritous
	@cp meritous/meritous.lnk /tmp/.meritous-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" meritous/control > /tmp/.meritous-ipk/control
	@cp meritous/conffiles /tmp/.meritous-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.meritous-ipk/control.tar.gz -C /tmp/.meritous-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.meritous-ipk/data.tar.gz -C /tmp/.meritous-ipk/root/ .
	@echo 2.0 > /tmp/.meritous-ipk/debian-binary
	@ar r meritous/meritous.ipk /tmp/.meritous-ipk/control.tar.gz /tmp/.meritous-ipk/data.tar.gz /tmp/.meritous-ipk/debian-binary

clean:		
		rm -f ${OBJS} ${TARGET}

