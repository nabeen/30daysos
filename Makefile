TOOLPATH = ./z_tools/
MAKE     = make -r
NASK     = $(TOOLPATH)nask
EDIMG    = $(TOOLPATH)edimg
IMGTOL   = $(TOOLPATH)imgtol
COPY     = cp
DEL      = rm -f

# デフォルト動作

default :
	$(MAKE) img

# ファイル生成規則

ipl.bin : ipl.nas Makefile
	$(NASK) ipl.nas ./build/ipl.bin ./build/ipl.lst

haribote.sys : haribote.nas Makefile
	$(NASK) haribote.nas ./build/haribote.sys ./build/haribote.lst

haribote.img : ipl.bin haribote.sys Makefile
	$(EDIMG)   imgin:./z_tools/fdimg0at.tek \
		wbinimg src:./build/ipl.bin len:512 from:0 to:0 \
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
	-$(DEL) ./build/ipl.bin
	-$(DEL) ./build/ipl.lst
	-$(DEL) ./build/haribote.sys
	-$(DEL) ./build/haribote.lst

src_only :
	$(MAKE) clean
	-$(DEL) ./build/haribote.img
