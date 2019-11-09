TOOLPATH = ./z_tools/
INCPATH  = ./z_tools/haribote/

MAKE     = make -r
NASK     = $(TOOLPATH)nask
CC1      = $(TOOLPATH)gocc1 -I$(INCPATH) -Os -Wall -quiet
GAS2NASK = $(TOOLPATH)gas2nask -a
OBJ2BIM  = $(TOOLPATH)obj2bim
BIM2HRB  = $(TOOLPATH)bim2hrb
RULEFILE = $(TOOLPATH)haribote/haribote.rul
EDIMG    = $(TOOLPATH)edimg
IMGTOL   = $(TOOLPATH)imgtol
COPY     = cp
DEL      = rm -f

# デフォルト動作

default :
	$(MAKE) img

# ファイル生成規則

ipl10.bin : ipl10.nas Makefile
	$(NASK) ipl10.nas ./build/ipl10.bin ./build/ipl10.lst

asmhead.bin : asmhead.nas Makefile
	$(NASK) asmhead.nas ./build/asmhead.bin ./build/asmhead.lst

bootpack.gas : bootpack.c Makefile
	$(CC1) -o ./build/bootpack.gas bootpack.c

bootpack.nas : bootpack.gas Makefile
	$(GAS2NASK) ./build/bootpack.gas ./build/bootpack.nas

bootpack.obj : bootpack.nas Makefile
	$(NASK) ./build/bootpack.nas ./build/bootpack.obj ./build/bootpack.lst

naskfunc.obj : naskfunc.nas Makefile
	$(NASK) naskfunc.nas ./build/naskfunc.obj ./build/naskfunc.lst

bootpack.bim : bootpack.obj naskfunc.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:./build/bootpack.bim stack:3136k map:./build/bootpack.map \
		./build/bootpack.obj ./build/naskfunc.obj
# 3MB+64KB=3136KB

bootpack.hrb : bootpack.bim Makefile
	$(BIM2HRB) ./build/bootpack.bim ./build/bootpack.hrb 0

haribote.sys : asmhead.bin bootpack.hrb Makefile
	cat ./build/asmhead.bin ./build/bootpack.hrb > ./build/haribote.sys

haribote.img : ipl10.bin haribote.sys Makefile
	$(EDIMG)   imgin:./z_tools/fdimg0at.tek \
		wbinimg src:./build/ipl10.bin len:512 from:0 to:0 \
		copy from:./build/haribote.sys to:@: \
		imgout:./build/haribote.img

# コマンド

img :
	$(MAKE) haribote.img

run :
	$(MAKE) img
	$(COPY) ./build/haribote.img ./z_tools/qemu/fdimage0.bin
	$(MAKE) -C ./z_tools/qemu

install :
	$(MAKE) img
	$(IMGTOL) w a: ./build/haribote.img

clean :
	-$(DEL) ./build/*.bin
	-$(DEL) ./build/*.lst
	-$(DEL) ./build/*.gas
	-$(DEL) ./build/*.obj
	-$(DEL) ./build/bootpack.nas
	-$(DEL) ./build/bootpack.map
	-$(DEL) ./build/bootpack.bim
	-$(DEL) ./build/bootpack.hrb
	-$(DEL) ./build/haribote.sys

src_only :
	$(MAKE) clean
	-$(DEL) ./build/haribote.img
