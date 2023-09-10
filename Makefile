nixos.iso:
	docker run --rm -it -v $$(pwd):/root/ nixos/nix /root/build.sh

qemu: nixos.iso
	fallocate -l 4g /dev/shm/disk.img
	qemu-system-x86_64 -m size=8g -smp cpus=8 -enable-kvm -cdrom nixos.iso -boot menu=on -drive file=/dev/shm/disk.img,if=ide,format=raw
