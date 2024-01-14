nixos.iso:
	docker run --rm -it -v $$(pwd):/tmp/ nixos/nix:2.17.1 /tmp/build.sh

qemu: nixos.iso
	fallocate -l 4g /dev/shm/disk.img
	qemu-system-x86_64 -m size=8g -smp cpus=8 -enable-kvm -cdrom nixos.iso -boot menu=on -boot once=d -drive file=/dev/shm/disk.img,if=ide,format=raw
