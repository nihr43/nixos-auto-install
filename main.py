import sys
import os
import yaml
import subprocess
from jinja2 import Environment, FileSystemLoader


class iso_profile:
    def __init__(self, name, root_device, root_size):
        self.name = name
        self.root_device = root_device
        self.grub_device = root_device
        self.root_size = root_size

        # /dev/sda1 or /dev/nvme0n1p1
        if self.root_device.endswith("da"):
            self.root_partition = f"{self.root_device}1"
        elif self.root_device.endswith("n1"):
            self.root_partition = f"{self.root_device}p1"
        else:
            raise ValueError("unable to determine root_partition")

    def build(self):
        print(f"building {self.name}")
        file_loader = FileSystemLoader("src/")
        env = Environment(loader=file_loader)
        for f in os.listdir("src"):
            file_path = os.path.join("src", f)
            if os.path.isfile(file_path):
                template = env.get_template(f)
                output = template.render(vals=self)
                output_file_path = f"artifacts/{f}"
                with open(output_file_path, "w") as out:
                    out.write(output)
        result = subprocess.run(
            ["nix-build", "artifacts"], capture_output=True, text=True
        )
        if result.returncode != 0:
            raise ValueError
        result = subprocess.run(f"cp result/iso/*.iso {self.name}.iso", shell=True)
        if result.returncode != 0:
            raise ValueError
        os.chmod(f"{self.name}.iso", 0o644)
        print(f"{self.name} finished")


def main():
    try:
        os.mkdir("artifacts")
    except FileExistsError:
        pass

    with open("config.yaml", "r") as f:
        yam = yaml.safe_load(f)
        for profile_name, values in yam.items():
            profile = iso_profile(
                profile_name,
                values["root_device"],
                values["root_size"],
            )
            profile.build()


if __name__ == "__main__":
    sys.exit(main())
