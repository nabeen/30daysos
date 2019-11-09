
# デフォルト動作

default :
	make img

# ファイル生成規則

ipl.bin : ipl.nas Makefile
	./z_tools/nask ipl.nas ./build/ipl.bin ./build/ipl.lst

helloos.img : ipl.bin Makefile
	./z_tools/edimg   imgin:./z_tools/fdimg0at.tek \
		wbinimg src:./build/ipl.bin len:512 from:0 to:0   imgout:./build/helloos.img

# コマンド

asm :
	make -r ipl.bin

img :
	make -r helloos.img

run :
	make img
	cp ./build/helloos.img ./z_tools/qemu/fdimage0.bin
	make -C ./z_tools/qemu

install :
	make img
	./z_tools/imgtol w a: ./build/helloos.img

clean :
	rm -f ./build/ipl.bin
	rm -f ./build/ipl.lst

src_only :
	make clean
	rm -f ./build/helloos.img
