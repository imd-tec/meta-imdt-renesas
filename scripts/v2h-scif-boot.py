#!/usr/bin/env python3
"""Boot an RZ/V2H SBC into fastboot over the debug serial port.

Replaces the Renesas Flash Writer: nothing is written to flash. The board must
be in SCIF download mode (see the README). The image comes from
tools/imdt/v2h-build-loader.sh in the IMDT U-Boot tree.

usage: v2h-scif-boot.py [--relay] [--console SECONDS] <tty> <image>
"""
import argparse
import os
import shutil
import struct
import subprocess
import sys
import time

import serial

RELAY_BOOT_MODE = "/usr/local/bin/boot_mode"
RELAY_POWER_ON = "/usr/local/bin/power_on"
RELAY_POWER_OFF = "/usr/local/bin/power_off"
PHYFW_ADDR = 0x08120000


def record(addr, data):
    return b"FBLD" + struct.pack("<II", addr, len(data)) + data + struct.pack("<I", sum(data) & 0xffffffff)


def read_until(ser, token, limit):
    end = time.time() + limit
    buf = b""
    while time.time() < end:
        chunk = ser.read(512)
        if chunk:
            buf += chunk
            sys.stdout.write(chunk.decode(errors="replace"))
            sys.stdout.flush()
            if token in buf:
                return
    sys.exit("\ntimed out waiting for %r" % token)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("tty")
    ap.add_argument("image")
    ap.add_argument("--relay", action="store_true",
                    help="power cycle into SCIF download mode with the rack relays")
    ap.add_argument("--console", type=int, default=0, metavar="SECONDS",
                    help="keep printing the console after the second stage starts")
    args = ap.parse_args()

    img = open(args.image, "rb").read()
    magic, srec_len, fw_len, s2_len, s2_addr = struct.unpack_from("<4sIIII", img)
    if magic != b"V2HF":
        sys.exit("%s is not a V2H loader image" % args.image)
    off = 20
    srec = img[off:off + srec_len]
    phyfw = img[off + srec_len:off + srec_len + fw_len]
    stage2 = img[off + srec_len + fw_len:]
    if len(stage2) != s2_len:
        sys.exit("loader image is truncated")

    if args.relay:
        subprocess.run([RELAY_POWER_OFF], check=True, stdout=subprocess.DEVNULL)
        subprocess.run([RELAY_BOOT_MODE, "prog"], check=True, stdout=subprocess.DEVNULL)
        time.sleep(1)

    ser = serial.Serial(args.tty, 115200, timeout=0.2)
    if args.relay:
        subprocess.run([RELAY_POWER_ON], check=True, stdout=subprocess.DEVNULL)
    else:
        print("Set the boot mode switches to SCIF download and power the board on.")

    t0 = time.time()
    read_until(ser, b"Load Program to SRAM", 3600 if not args.relay else 15)
    ser.write(srec)
    ser.flush()
    read_until(ser, b"baud", 120)
    t1 = time.time()

    time.sleep(0.3)
    ser.baudrate = 921600
    ser.reset_input_buffer()
    ser.write(record(PHYFW_ADDR, phyfw))
    ser.flush()
    read_until(ser, b"ready", 60)
    ser.write(record(s2_addr, stage2))
    ser.flush()
    read_until(ser, b"go", 60)
    print("\n[fastboot loader started in %.1fs]" % (time.time() - t0))

    end = time.time() + args.console
    while time.time() < end:
        chunk = ser.read(512)
        if chunk:
            sys.stdout.write(chunk.decode(errors="replace"))
            sys.stdout.flush()
    ser.close()

    if shutil.which("fastboot"):
        for _ in range(30):
            out = subprocess.run(["fastboot", "devices"], capture_output=True, text=True).stdout
            if out.strip():
                print("fastboot: " + out.strip())
                return
            time.sleep(1)
        sys.exit("no fastboot device appeared on USB")


if __name__ == "__main__":
    main()
