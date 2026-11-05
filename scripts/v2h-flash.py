#!/usr/bin/env python3
"""Write the RZ/V2H or RZ/V2N bootloader through the fastboot loader (replaces Flash Writer).

usage: v2h-flash.py qspi     --bl2 FILE --fip FILE
       v2h-flash.py emmc-boot --bl2 FILE --fip FILE [--boot-config]

FILE is a .srec from the Yocto deploy directory or a raw .bin. Boot the board
with v2h-scif-boot.py first.
"""
import argparse
import subprocess
import sys
import tempfile

STAGE = 0x62000000
READBACK = 0x70000000

QSPI_BL2, QSPI_FIP, QSPI_ENV = 0x0, 0x60000, 0x1E0000
EMMC_BL2_SECTOR, EMMC_FIP_SECTOR = 1, 300


def load(path):
    """Return the raw bytes of a .srec (from its lowest address) or a .bin."""
    if not path.lower().endswith((".srec", ".mot")):
        return open(path, "rb").read()

    chunks = {}
    for line in open(path):
        line = line.strip()
        if line[:2] not in ("S1", "S2", "S3"):
            continue
        alen = {"S1": 2, "S2": 3, "S3": 4}[line[:2]]
        raw = bytes.fromhex(line[2:])
        addr = int.from_bytes(raw[1:1 + alen], "big")
        chunks[addr] = raw[1 + alen:-1]
    base = min(chunks)
    data = bytearray()
    for addr in sorted(chunks):
        if addr - base > len(data):
            data += b"\xff" * (addr - base - len(data))
        data[addr - base:addr - base + len(chunks[addr])] = chunks[addr]
    return bytes(data)


def fastboot(*args):
    r = subprocess.run(["fastboot", *args], capture_output=True, text=True)
    if r.returncode:
        sys.exit("fastboot %s failed:\n%s" % (" ".join(args[:2]), r.stderr.strip()))


def pad(data, align):
    return data + b"\xff" * (-len(data) % align)


def run(cmd):
    fastboot("oem", "run:" + cmd)


def stage(data):
    with tempfile.NamedTemporaryFile() as f:
        f.write(data)
        f.flush()
        fastboot("stage", f.name)


def write_qspi(name, data, offset, limit):
    if len(data) > limit:
        sys.exit("%s is %#x bytes, over the %#x available" % (name, len(data), limit))
    data = pad(data, 0x10000)
    n = len(data)
    print("%s: %#x bytes to xSPI %#x" % (name, len(data), offset))
    stage(data)
    run("sf probe; sf erase %#x %#x; sf write %#x %#x %#x; sf read %#x %#x %#x; cmp.b %#x %#x %#x"
        % (offset, n, STAGE, offset, n, READBACK, offset, n, STAGE, READBACK, n))


def write_emmc_boot(name, data, sector):
    data = pad(data, 512)
    blocks = len(data) // 512
    print("%s: %d sectors to eMMC boot partition 1, sector %d" % (name, blocks, sector))
    stage(data)
    run("mmc dev 0 1; mmc write %#x %#x %#x; mmc read %#x %#x %#x; cmp.b %#x %#x %#x"
        % (STAGE, sector, blocks, READBACK, sector, blocks, STAGE, READBACK, len(data)))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("target", choices=("qspi", "emmc-boot"))
    ap.add_argument("--bl2", required=True)
    ap.add_argument("--fip", required=True)
    ap.add_argument("--boot-config", action="store_true",
                    help="emmc-boot: boot from boot partition 1 on an 8 bit bus")
    args = ap.parse_args()

    bl2, fip = load(args.bl2), load(args.fip)
    if args.target == "qspi":
        write_qspi("BL2", bl2, QSPI_BL2, QSPI_FIP - QSPI_BL2)
        write_qspi("FIP", fip, QSPI_FIP, QSPI_ENV - QSPI_FIP)
    else:
        write_emmc_boot("BL2", bl2, EMMC_BL2_SECTOR)
        write_emmc_boot("FIP", fip, EMMC_FIP_SECTOR)
        if args.boot_config:
            print("eMMC boot config: partition 1, 8 bit bus")
            run("mmc dev 0; mmc bootbus 0 2 0 0; mmc partconf 0 0 1 0")
    print("done: set the boot mode switches and power cycle")


if __name__ == "__main__":
    main()
