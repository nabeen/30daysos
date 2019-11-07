run :
	./z_tools/nask helloos.nas ./build/helloos.img
	cp ./build/helloos.img ./z_tools/qemu/fdimage0.bin
	make -C ./z_tools/qemu
