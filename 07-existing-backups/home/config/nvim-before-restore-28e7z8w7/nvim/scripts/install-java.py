"""Install a verified Temurin JDK only inside Neovim's data directory."""
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import sys
import tarfile
import tempfile
import urllib.request


def install(destination):
    destination = destination.resolve()
    if (destination / "bin/java").is_file():
        print("Java already installed")
        return
    if destination.exists():
        raise RuntimeError(f"Refusing to replace incomplete directory: {destination}")
    if platform.system() != "Linux":
        raise RuntimeError("This private Java installer supports Linux")
    architecture = {"x86_64": "x64", "aarch64": "aarch64"}.get(platform.machine())
    if not architecture:
        raise RuntimeError(f"Unsupported architecture: {platform.machine()}")
    endpoint = (
        "https://api.adoptium.net/v3/assets/latest/25/hotspot"
        f"?architecture={architecture}&os=linux&image_type=jdk&vendor=eclipse"
    )
    # Fetch metadata before creating directories, so offline attempts leave no files.
    with urllib.request.urlopen(endpoint, timeout=20) as response:
        assets = json.load(response)
    package = assets[0]["binary"]["package"]
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="jdk-download-", dir=destination.parent) as folder:
        folder = Path(folder)
        archive = folder / "jdk.tar.gz"
        checksum = hashlib.sha256()
        with urllib.request.urlopen(package["link"], timeout=60) as response, archive.open("wb") as output:
            while chunk := response.read(1024 * 1024):
                checksum.update(chunk)
                output.write(chunk)
        if checksum.hexdigest().lower() != package["checksum"].lower():
            raise RuntimeError("Java download checksum mismatch")
        unpacked = folder / "unpacked"
        unpacked.mkdir()
        with tarfile.open(archive, "r:gz") as bundle:
            bundle.extractall(unpacked, filter="data")
        roots = list(unpacked.iterdir())
        if len(roots) != 1 or not (roots[0] / "bin/java").is_file():
            raise RuntimeError("Downloaded archive has an unexpected layout")
        if not os.access(roots[0] / "bin/java", os.X_OK):
            raise RuntimeError("Downloaded Java executable is not runnable")
        shutil.move(str(roots[0]), destination)
    print(f"Java installed at {destination}")


if __name__ == "__main__":
    try:
        install(Path(sys.argv[1]))
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
