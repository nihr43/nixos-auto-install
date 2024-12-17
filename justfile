build: lint
    nix-shell . --run 'python3 main.py'

lint:
    black .
    flake8 . --ignore=E501,W503

test: lint build
    fallocate -l 4g qemu.img
    qemu-system-x86_64 -m size=4g -smp cpus=4 -enable-kvm -cdrom qemu.iso -boot menu=on -boot once=d -drive file=qemu.img,if=ide,format=raw
