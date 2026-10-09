<img src="docs/logo.png" alt="IMD Technologies" width="200"/>

# meta-imdt-renesas - Getting Started Guide 

[![Build Status](https://github.com/imd-tec/meta-imdt-renesas/actions/workflows/build-imdt-base-image.yml/badge.svg)](../../actions/workflows/build-imdt-base-image.yml)
<!-- TODO: add per-image LAVA QA badges (as in meta-imdt-qcom-oss) once LAVA publishes results for both boards -->

![IMDT V2H/V2N SBC](docs/imdt-v2-sbc-top.png)

The role of this meta layer is the following:
  - Provide a BSP for the IMDT Renesas RZ/V2H and RZ/V2N boards
  - Track the Yocto/OpenEmbedded Scarthgap branch and [meta-renesas](https://github.com/renesas-rz/meta-renesas) (`scarthgap/rz`)
  - Linux 6.1 CIP kernel, U-Boot 2024.07 and Trusted Firmware-A 2.10
  - Optional Renesas AI SDK features (DRP-AI, OpenCVA, H.264/H.265 codecs)
  - Easy-to-use kas based build process 

The images are built on top of the Renesas `rz-vlp` distribution from [meta-renesas](https://github.com/renesas-rz/meta-renesas).

## Table of Contents

- [Feature Support](#feature-support)
- [Hardware Overview](#hardware-overview)
- [Boot Chain](#boot-chain)
- [Device Tree Overlays](#device-tree-overlays)
- [Storage Layout](#storage-layout)
- [References](#references)
- [Prerequisites](#prerequisites)
- [Building release images](#building-release-images)
- [Deploying images](#deploying-images)
- [Working with the board](#working-with-the-board)
- [OS Updates](#os-updates)
- [Appendix](#appendix)

## Feature Support
> [!NOTE]
> Both boards are built by CI on every commit, and the V2H SBC is also tested
> on hardware with LAVA (see [Hardware Testing](#hardware-testing)). LAVA
> testing of the V2N SBC is planned.
>
> Both SBCs use the same carrier board. The V2N SoC has fewer USB, CSI and PCIe
> lanes than the V2H, so some connectors are only functional on the V2H — see
> [USB](#usb).

| Feature | Hardware | Interface | Kernel Driver | V2H SBC (16GB) Status | V2N SBC (8GB) Status |
|---|---|---|---|---|---|
| ADC | On-SoC ADC | — | rzv2h-adc (IIO) | ✅ | ✅ |
| Android Debug Bridge (ADB) | — | Micro USB (OTG) | configfs gadget | ✅ | ✅ |
| Audio | TI TLV320AIC3x codec | I2S | rsnd / tlv320aic3x | ✅ | ✅ |
| CAN FD | J10 header | CAN-FD (`can0`) | rcar_canfd | ✅ | ✅ |
| Camera (AR1335 - 13MP) | ON Semiconductor AR1335 + AP1302 ISP | CSI0 / CSI1 | ap1302 | ✅ | ✅ |
| Core Thermal Sensor | On-SoC TSU (2 zones) | — | thermal | ✅ | ✅ |
| DDR Memory | 16GB / 8GB LPDDR4-3200 | — | — | ✅ 16GB | ✅ 8GB |
| Debug Serial Console | USB-C "DEBUG" connector | SCIF0 (115200 baud) | sh-sci | ✅ | ✅ |
| Docker | — | — | — | ✅ Optional feature | ✅ Optional feature |
| DRP-AI | DRP-AI3 accelerator | — | drpai | ✅ Optional feature | ✅ Optional feature |
| eMMC Storage | on-SoM eMMC | SDHI | renesas_sdhi | ✅ | ✅ |
| Gigabit Ethernet (x2) | ET0 / ET1 RJ45 | GbE (`end0`, `end1`) | renesas-gbeth | ✅ | ✅ |
| GPU | Arm Mali-G31 | — | panfrost | ✅ | ✅ |
| HDMI Display | ST B-LCDAD-HDMI1 DSI-to-HDMI adapter | DSI | — | ✅ Requires DTBO overlay | ✅ Requires DTBO overlay |
| Humidity & Temperature Sensor | Sensirion SHT4x | I2C | sht4x (hwmon) | ✅ | ✅ |
| ISP (Mali-C55) | Arm Mali-C55 | CSI2 / CSI3 | — | 🚧 Not yet ported to Scarthgap | ❌ |
| LTE Cat 4 modem (M.2 Key-B) | Quectel EM05 | USB3 | qmi_wwan / option | ✅ | ✅ |
| Magnetometer | MEMSIC MMC5633 | I2C | mmc5633 (IIO) | ✅ | ✅ |
| microSD Card | — | SDHI | renesas_sdhi | ✅ | ✅ |
| MIPI DSI Display | IMDT 7" touchscreen (IM-MSC-0006) | DSI | — | ✅ | ✅ |
| OpenCV Accelerator (OpenCVA) | DRP | — | — | ✅ Optional feature | ✅ Optional feature |
| OTA Rootfs Updates | — | — | — | ✅ SWUpdate | ✅ SWUpdate |
| PCIe | M.2 slots | PCIe (x4 on V2H, x2 on V2N) | — | ✅ | ✅ |
| RS232 | J9 header | SCIF (`ttySC1`) | sh-sci | ✅ | ✅ |
| RTC / Watchdog / I2C / GPIO | — | — | — | ✅ | ✅ |
| USB 2.0 Type-A | — | USB2 | ehci/ohci | ✅ Host | ❌ |
| USB 3.0 Type-A (J8) | — | USB3 | xhci | ✅ Host | ❌ |
| USB Micro-B (OTG) | — | USB2 | renesas_usbhs | ✅ Host or peripheral mode | ✅ Host or peripheral mode |
| Video Encode (H.264 / H.265) | Renesas codec IP | — | proprietary | ✅ Requires `meta-rz-codecs` | ❌ |
| Wi-Fi 802.11b/g/n | Murata 1XK (NXP IW416) | SDIO | moal / mlan | ✅ | ✅ |
| xSPI Flash (16 MB) | — | xSPI | — | ✅ | ✅ |
| Yocto / OpenEmbedded Scarthgap branch | — | — | — | ✅ | ✅ |

## Hardware Overview

Both the IMDT V2H SBC and IMDT V2N SBC consist of an IMDT SoM mounted onto the
same carrier board. The main differences between the two SoMs are:

| Feature | V2H SoM | V2N SoM |
|---|---|---|
| SRAM | **6 MB** | **1.5 MB** |
| Memory | **16 GB 2-channel LPDDR4-3200** | **8 GB 1-channel LPDDR4-3200** |
| Main CPU | Quad 64-bit Arm® Cortex®-A55 (up to 1.8 GHz) | Quad 64-bit Arm® Cortex®-A55 (up to 1.8 GHz) |
| Co-processor 1 | 32-bit Arm® Cortex®-M33 (up to 200 MHz) | 32-bit Arm® Cortex®-M33 (up to 200 MHz) |
| Co-processor 2 | **Dual 32-bit Arm® Cortex®-R8 real-time processors (up to 800 MHz)** | **N/A** |
| MIPI CSI | **4x** | **2x** |
| MIPI DSI | 1x | 1x |
| PCIe | **2x2 / x4** | **x2** |
| USB3 | **2x** | **1x** |
| USB2 | **2x** | **1x** |
| SDIO | 2x | 2x |
| SPI | 3x | 3x |
| GbE | 2x | 2x |
| I2C | 9x | 9x |
| I3C | 1x | 1x |
| SCI (UART/I2C/SPI) | 10x | 10x |

## Boot Chain

The boot chain used to boot into Linux is shown below.
![V2H/V2N SBC boot chain](docs/boot-flow.png)

1. **BootROM** — on-chip ROM that reads the [boot mode DIP switches](#13-boot-mode-switch) and either loads the next stage from xSPI flash or eMMC, or enters SCIF download mode so the bootloader can be programmed over the debug serial console.
2. **Trusted Firmware-A BL2 / BL31** — loaded from xSPI flash or the eMMC boot partition. Initialises DDR and the rest of the system and starts U-Boot.
3. **U-Boot** — packed with BL31 in the FIP image and stored next to BL2. It loads its environment from the `env` partition, applies the [device tree overlays](#device-tree-overlays) and boots the kernel from the active root partition.
4. **Linux** — the kernel (`/boot/Image`) and device tree are loaded from the active A/B rootfs partition on the SD card or eMMC.

Only two combinations of bootloader and kernel location are supported:

| Boot mode | Bootloader | Kernel and rootfs |
|---|---|---|
| eMMC boot | eMMC boot partition 1 | eMMC |
| xSPI boot | xSPI flash | SD card |

## Device Tree Overlays

The board boots the base device tree for its machine (`imdt-v2h-sbc.dtb` or
`imdt-v2n-sbc.dtb`). U-Boot then **applies the overlays named in its
`overlay_list` environment variable** before handing the device tree to the
kernel. By default this is the **IMDT DSI display** panel.

The overlays that are built are listed in `KERNEL_DEVICETREE` in
[`conf/machine/include/imdt-v2-sbc.inc`](conf/machine/include/imdt-v2-sbc.inc):

| Overlay | Purpose |
|---|---|
| `imdt-v2-sbc-dsi-panel.dtbo` | IMDT 7" DSI touchscreen display (**default**) |
| `imdt-v2-sbc-dsi-hdmi.dtbo` | ST DSI-to-HDMI adapter |
| `imdt-v2-sbc-ar1335-csi2.dtbo` | AR1335 camera on CSI2 |
| `imdt-v2-sbc-ar1335-csi3.dtbo` | AR1335 camera on CSI3 |

To **change the applied overlays** at runtime, set `overlay_list` from Linux
with `fw_setenv` or from the [U-Boot prompt](#entering-u-boot) — see
[Using the HDMI adapter](#using-the-hdmi-adapter) for an example. To change the
**default** list baked into the image, edit `CONFIG_ADD_OVERLAYS` in
[`recipes-bsp/u-boot/files/overlays.cfg`](recipes-bsp/u-boot/files/overlays.cfg)
and rebuild. A new overlay must also be added to `KERNEL_DEVICETREE` so it is
compiled and installed.

## Storage Layout

The SD card and eMMC images (`.wic.gz`) share the same layout, generated from
[`wic/imdt-image.wks`](wic/imdt-image.wks). The bootloader is not part of this
image — it lives in xSPI flash or in the eMMC boot partition (see
[Flashing the bootloader](#flashing-the-bootloader)).

![Storage layout](docs/storage-layout.png)

| Partition | Size | Contents |
|---|---|---|
| `env` | 2 MiB | FAT partition holding the U-Boot environment (`u-boot-env.img`), including the active root partition and `overlay_list`. |
| `root0` | rootfs | Root filesystem A (ext4), including the kernel `/boot/Image` and the device trees. |
| `root1` | rootfs | Root filesystem B (ext4). [OS updates](#os-updates) are written to whichever of `root0` / `root1` is inactive. |

## Hardware Testing

Every commit is automatically built for both boards, and the V2H build is tested on a physical IMDT V2H SBC via [LAVA](https://lava.readthedocs.io/). Each run executes these jobs in sequence:

1. **Fastboot deploy** — flashes the freshly built rootfs to the inactive A/B slot through U-Boot fastboot, boots it once and verifies the board came up on the new image
2. **Hardware tests** — checks the SoC, memory, thermal zones, eMMC, SD card, xSPI flash, Ethernet, CAN, Wi-Fi, I2C, GPIO, RTC, watchdog, USB, PCIe, sensors, audio, GPU and kernel health over SSH

See [lava/fastboot-deploy.yaml](lava/fastboot-deploy.yaml) and [lava/hardware-tests.yaml](lava/hardware-tests.yaml) for the full list of test cases.

## References

[1] [RZ/V2H Homepage](https://www.renesas.com/en/products/microcontrollers-microprocessors/rz-mpus/rzv2h-quad-core-vision-ai-mpu-drp-ai3-accelerator-and-high-performance-real-time-processor)

[2] [RZ/V2N Homepage](https://www.renesas.com/en/products/microcontrollers-microprocessors/rz-mpus/rzv2n-15tops-quad-core-vision-ai-mpu-2-camera-connection-and-excellent-power-efficiency)

[3] [RZ/V2H Group User's Manual: Hardware](https://www.renesas.com/en/document/mah/rzv2h-group-users-manual-hardware)

[4] [RZ/V2N Group User's Manual: Hardware](https://www.renesas.com/en/document/mah/rzv2n-group-users-manual-hardware)

[5] [RZ/V2H/V2N Linux Interface Specification GStreamer](https://www.renesas.com/en/document/mas/rzv2h-group-linux-interface-specification-gstreamer-users-manual-software)

[6] [Renesas AI SDK 5.00 Documentation](https://renesas-rz.github.io/rzv_ai_sdk/5.00/ai-sdk.html)

## Prerequisites

This process requires a machine with the following:

- Ubuntu 22.04
- Docker Engine
- At least 100GB of free disk space on an ext4 formatted drive
- Python3 installed
- Git LFS installed (`sudo apt install git-lfs`) — this layer stores the
  documentation images in Git LFS

It's recommended that anything older than Ubuntu 22.04 isn't used due to quirks with Docker security.

## Building release images

This section describes the process for building the release images from source.

### Prerequisites

This needs to be performed once on your machine:

```bash
sudo apt install git-lfs
git lfs install
git clone https://github.com/imd-tec/meta-imdt-renesas.git
python3 -m venv venv
. venv/bin/activate
pip3 install kas
```

> [!NOTE]
> `git lfs install` must be run before cloning. If you have already cloned the
> repository without Git LFS, run `git lfs pull` inside it to fetch the real
> files.

Once this has been completed, you can then restore the python environment using:

```bash
. venv/bin/activate
```

### Building

To build an image:

```bash
# V2H base image
kas-container build meta-imdt-renesas/kas/imdt-v2h-base.yml

# V2N base image
kas-container build meta-imdt-renesas/kas/imdt-v2n-base.yml

# Weston image (adds the Weston compositor)
kas-container build meta-imdt-renesas/kas/imdt-v2h-base.yml:meta-imdt-renesas/kas/images/weston.yml
```

Once complete, the images are located in `build/tmp/deploy/images/imdt-v2h-sbc/`
or `build/tmp/deploy/images/imdt-v2n-sbc/`.

| Image | kas config | Description |
|---|---|---|
| `imdt-image-base` | `kas/images/base.yml` (default) | Base image with the IMDT utilities, Wi-Fi, SWUpdate and ADB |
| `imdt-image-weston` | `kas/images/weston.yml` | Base image plus the Weston compositor |

### Optional features

Optional features are enabled by appending their kas config from
[`kas/features/`](kas/features) to the build command, separated by `:`:

```bash
# V2H base image with DRP-AI
kas-container build meta-imdt-renesas/kas/imdt-v2h-base.yml:meta-imdt-renesas/kas/features/v2h-drpai.yml
```

| Feature | kas config | Boards |
|---|---|---|
| DRP-AI | `kas/features/v2h-drpai.yml` / `kas/features/v2n-drpai.yml` | V2H / V2N |
| OpenCVA | `kas/features/v2h-opencva.yml` / `kas/features/v2n-opencva.yml` | V2H / V2N |
| H.264 / H.265 codecs | `kas/features/codecs.yml` | V2H — requires the [proprietary codecs layer](#adding-the-proprietary-renesas-codecs) |
| Docker | `kas/features/docker.yml` | V2H / V2N |

Some features target the same hardware resources and cannot be enabled together:

- **V2H:** Codecs and OpenCVA are mutually exclusive.
- **V2N:** DRP-AI, Codecs and OpenCVA are mutually exclusive.

### Adding the proprietary Renesas codecs

The codecs layer (`meta-rz-codecs`) requires acceptance of Renesas's Terms and
Conditions and must be downloaded separately. If it is enabled without the layer
in place, the build fails with:

```
ERROR: The following layer directories do not exist:
ERROR:    .../sources/meta-rz-features/meta-rz-codecs
```

1. Download the **RZ/V2N AI SDK v5.00 Source Code** from the [Renesas website](https://www.renesas.com/en/software-tool/rzv2n-ai-software-development-kit#downloads) (~16GB). The exact version is given in the comments of [`kas/features/codecs.yml`](kas/features/codecs.yml).
2. Extract the archive, then extract `rzv2n_ai-sdk_yocto_recipe_v5.00.tar.gz` inside it.
3. Copy the codecs layer into your kas workspace and re-run the build with `kas/features/codecs.yml` appended:

```bash
mkdir -p sources/meta-rz-features
cp -r <path-to-extracted-sdk>/meta-rz-features/meta-rz-codecs sources/meta-rz-features/
```

### Building an SDK

To generate a cross-compilation SDK for developing applications outside of Yocto:

```bash
kas-container shell meta-imdt-renesas/kas/imdt-v2h-base.yml:meta-imdt-renesas/kas/images/weston.yml \
  -c "bitbake -c populate_sdk imdt-image-weston"
```

The SDK installer is generated in `build/tmp/deploy/sdk/`. See [Using the SDK](#using-the-sdk).

### Boot SBC into SCIF Download mode

To boot the SBC into SCIF download mode, do the following:

1. Power off the board
2. Set the boot mode DIP switches to OFF, ON, OFF (switch 1, 2, 3)
3. Connect the debug serial console
4. Power on the board via the DC Jack or the USB PD port

The BootROM prints the following on the serial console:

```
Download mode (Normal SCI boot)
-- Load Program to SRAM ---------------
```

Refer to [Boot Mode Switch](#13-boot-mode-switch) to see the location of the DIP switches.

## Deploying images

It's recommended to use a Linux host for deploying images.

### SD card

Insert the microSD card (8GB or larger) into the host machine and unmount any
partitions that were automatically mounted. Then write the image, replacing
`<device>` with the SD card device:

```bash
zcat imdt-image-base-imdt-v2h-sbc.rootfs.wic.gz | sudo dd of=/dev/<device> bs=1M status=progress conv=fsync oflag=sync
```

[Balena Etcher](https://etcher.balena.io/) can be used instead on Linux and Windows.

### eMMC

The image can only be programmed onto the eMMC from a running system. Boot the
board from an SD card, copy the `.wic.gz` image to it (e.g. with `scp`) and run:

```bash
zcat /path/to/imdt-image-base-imdt-v2h-sbc.rootfs.wic.gz | dd of=/dev/mmcblk0 iflag=fullblock bs=1M oflag=direct conv=fsync
sync
```

Then program the bootloader to the eMMC as described in [Flashing the bootloader to eMMC](#flashing-the-bootloader-to-emmc).

### Flashing the bootloader

> [!WARNING]
> Pre-installed bootloaders may not support features in newer images, such as
> device tree overlays, software updates and DRP-AI/codecs. Flash the
> bootloader from the same build as the image.

The bootloader is programmed over the debug serial console with the Renesas
Flash Writer. The files are in the deploy directory:

| File | V2H SBC | V2N SBC |
|---|---|---|
| Flash Writer | `Flash_Writer_SCIF_RZV2H_DEV_INTERNAL_MEMORY.mot` | `Flash_Writer_SCIF_RZV2N_EVK_LPDDR4X.mot` |
| BL2 (xSPI) | `bl2_bp_spi-imdt-v2h-sbc.srec` | `bl2_bp_spi-imdt-v2n-sbc.srec` |
| BL2 (eMMC) | `bl2_bp_mmc-imdt-v2h-sbc.srec` | `bl2_bp_mmc-imdt-v2n-sbc.srec` |
| FIP (BL31 + U-Boot) | `fip-imdt-v2h-sbc.srec` | `fip-imdt-v2n-sbc.srec` |

#### Loading the Flash Writer

Please make sure that the board is powered and in SCIF download mode as per [these instructions](#boot-sbc-into-scif-download-mode).

> [!IMPORTANT]
> From this point onward, only press the keys listed in the instructions.
> Unexpected key presses are processed by the SCIF bootloader and will disrupt
> the programming process.

Send the Flash Writer `.mot` file for your board through the serial console. In GTKTerm, use **File → Send RAW file**:

![GTKTerm - Send RAW file](docs/gtkterm-send-raw-file.png)

Once loaded, the Flash Writer prompt appears:

```
Flash writer for RZ/V2H Series V0.60 Jan.26,2023
 Product Code : RZ/V2H
>
```

To speed up the upload, enter `SUP` and change the terminal baud rate to `921600` when prompted.

#### Flashing the bootloader to xSPI

Enter `XLS2`, then `8101E00` as the program top address and `0000` as the Qspi save address, and send `bl2_bp_spi-<machine>.srec`:

```
>XLS2
===== Please Input Program Top Address ============
  Please Input : H'8101E00
===== Please Input Qspi Save Address ===
  Please Input : H'0000
please send ! ('.' & CR stop load)
```

Repeat `XLS2` with `0000` as the program top address and `60000` as the save address, and send `fip-<machine>.srec`.

Power off the board, set the DIP switches to **xSPI boot** (OFF, ON, ON) and the terminal back to 115200 baud.

#### Flashing the bootloader to eMMC

Enter `em_w`, then partition area `1`, start sector `1` and program start address `8101e00`, and send `bl2_bp_mmc-<machine>.srec`:

```
>em_w
  Select area(0-2)>1
-- Boot Partition 1 Program -----------------------------
Please Input Start Address in sector :1
Please Input Program Start Address : 8101e00
please send ! ('.' & CR stop load)
```

Repeat `em_w` with partition area `1`, start sector `300` and program start address **`44000000` on the V2H** or **`0000` on the V2N**, and send `fip-<machine>.srec`.

Configure the eMMC to boot from boot partition 1:

```
>em_secsd
  Please Input EXT_CSD Index(H'00 - H'1FF) :b1
  Please Input Value(H'00 - H'FF) :2
>em_secsd
  Please Input EXT_CSD Index(H'00 - H'1FF) :b3
  Please Input Value(H'00 - H'FF) :8
```

Power off the board, set the DIP switches to **eMMC boot** (OFF, OFF, OFF) and the terminal back to 115200 baud.

#### Entering U-Boot

With the serial console open, power on the board and press any key during the autoboot countdown:

```
Hit any key to stop autoboot:  0
=>
```

#### Resetting the U-Boot environment

After flashing a new bootloader onto a board that already has an IMDT image, reset the U-Boot environment to its defaults from the U-Boot prompt:

```
env default -a
saveenv
```

## Working with the board

### Powering the Board

The board can be powered from the DC jack (12V–24V, 2A min) or the USB-C PD "POWER" port (9V, 3A min).

For access to the serial console, the USB-C "DEBUG" port must be connected to the host machine. Once the board has finished booting, the login prompt should appear in the serial console:

```
imdt-v2h-sbc login:
```

Log in over the serial console with the username `root`; there is no password by default.

### Connecting to the Debug Serial Consoles

When connected to a Linux host system, the serial ports will appear as USB devices (typically `/dev/ttyUSB0` and `/dev/ttyUSB1`). On Ubuntu systems, the serial consoles can be accessed using GTKTerm. Adding the current user to the `dialout` group will allow serial port access without requiring super-user privileges:

```bash
sudo apt install gtkterm
sudo usermod -a -G dialout <username>
# Log out and back in for the change to take effect
```

The screenshot below shows the serial port settings:

![Serial port settings](docs/serial-port-settings.png)

### Android Debug Bridge (ADB)

ADB is a command line tool used to communicate with devices running the ADB daemon. It can be used to launch a shell on the host which can be used to execute commands on the device. The ADB daemon runs on the micro USB (OTG) port.

#### Setting up ADB

Install ADB on the host machine:

```bash
sudo apt-get install adb
```

Check connected devices with ADB:

```bash
adb devices
```

#### Development Workflow using ADB

Once the device is connected to the ADB server on the host machine, shell commands can then be issued from the host machine to the device. The device filesystem can then be accessed using `adb push` or `pull`. And a terminal can be launched on the device using `adb shell`.

Copying files onto the device:

```bash
adb push /path/to/application /home/root/
```

Launch ADB shell:

```bash
adb shell
```

### Using the Display

The following section describes how to connect IMDT's display to the V2H/V2N SBC. Both the IMDT DSI display and HDMI displays (via the [ST B-LCDAD-HDMI1](https://www.st.com/en/evaluation-tools/b-lcdad-hdmi1.html) DSI to HDMI adapter) are supported.

To use the IMDT display (PN:IM-MSC-0006), connect it to the DSI adapter using the display flex cables. Once connected, the adapter can then be connected to the SBC display connector as shown in the following image:

![Display connection](docs/display-connection.jpg)

On `imdt-image-weston`, Weston starts automatically when a display is attached.

#### Using the HDMI adapter

The images output to the IMDT display by default. To use the HDMI adapter instead, change the [device tree overlay](#device-tree-overlays) from Linux:

```bash
fw_setenv overlay_list 'imdt-v2-sbc-dsi-hdmi.dtbo'
sync
reboot
```

or from the [U-Boot prompt](#entering-u-boot):

```
setenv overlay_list 'imdt-v2-sbc-dsi-hdmi.dtbo'
saveenv
reset
```

### Streaming from MIPI Cameras

#### Streaming from AR1335

The AR1335 sensors are connected through AP1302 ISPs on CSI0 and CSI1. `/dev/media0` corresponds to CSI0 and `/dev/media1` to CSI1:

```
$ v4l2-ctl --list-devices
RZG2L_CRU (platform:16000000.cru0):
        /dev/video0
        /dev/media0

RZG2L_CRU (platform:16010000.cru1):
        /dev/video1
        /dev/media1
```

Configure the media pipeline, then capture a JPEG with GStreamer:

```bash
/home/root/v4l2-init.sh --device 0 --width 1920 --height 1080
gst-launch-1.0 -e v4l2src io-mode=4 device=/dev/video0 num-buffers=1 ! \
  "video/x-raw,format=YUY2,width=1920,height=1080" ! videoconvert ! jpegenc ! \
  filesink location=/home/root/test.jpg
```

See the [GStreamer guide](#references) for more pipelines.

### Hardware Video Encode

H.264 and HEVC hardware encoding is available on the **V2H** only and requires the [proprietary codecs](#adding-the-proprietary-renesas-codecs). The pipeline is AP1302 (YUYV) → `vspmfilter` (NV12) → `omxh264enc` / `omxh265enc`.

Encode the camera stream to H.264:

```bash
/home/root/v4l2-init.sh --device 0 --width 1920 --height 1080
gst-launch-1.0 -e v4l2src device=/dev/video0 io-mode=4 ! \
  video/x-raw,format=YUY2,width=1920,height=1080,framerate=30/1 ! queue ! \
  vspmfilter dmabuf-use=true ! video/x-raw,format=NV12 ! \
  omxh264enc control-rate=2 target-bitrate=10485760 interval_intraframes=14 periodicty-idr=2 ! \
  video/x-h264,profile=\(string\)high,level=\(string\)4 ! h264parse ! \
  video/x-h264,stream-format=avc,alignment=au ! qtmux ! filesink location=/tmp/out_h264.mp4
```

Encode the camera stream to HEVC:

```bash
gst-launch-1.0 -e v4l2src device=/dev/video0 io-mode=4 ! \
  video/x-raw,format=YUY2,width=1920,height=1080,framerate=30/1 ! \
  vspmfilter dmabuf-use=true ! video/x-raw,format=NV12 ! \
  omxh265enc control-rate=2 target-bitrate=10485760 interval_intraframes=14 use-dmabuf=true ! \
  video/x-h265,profile=\(string\)main,level=\(string\)5 ! h265parse ! \
  video/x-h265,alignment=au ! qtmux ! filesink location=/tmp/out_h265.mp4
```

### Onboard WiFi

The onboard WiFi (Murata 1XK / NXP IW416, `wlan0`) is managed by systemd-networkd. Helper scripts in `/opt/imdt/wifi` configure it, and the configuration is kept across reboots. WiFi is off by default.

All commands below run on the target board.

#### 1. Connect to a network (station mode)

```bash
/opt/imdt/wifi/connect-to-access-point.sh 'NETWORK_NAME' 'NETWORK_PASSWORD'
```

#### 2. Verify the connection

```bash
/opt/imdt/wifi/get-connection-status.sh
```

Should show:

```
{"wpa_state":"COMPLETED","ssid":"NETWORK_NAME","rssi":"-79","frequency":"2427"}
```

#### 3. Access point mode (optional)

The board can also act as an access point, with the default SSID `imdt-v2h-sbc-ap` and password `imdtpass`:

```bash
/opt/imdt/wifi/create-access-point.sh                     # default SSID / password
/opt/imdt/wifi/create-access-point.sh 'MY_SSID' 'MY_PASS'
/opt/imdt/wifi/get-number-of-ap-clients.sh
```

`get-wifi-mode.sh` prints the current mode (`AP`, `STA` or `OFF`) and `disable-wifi.sh` turns WiFi off.

### Gigabit Ethernet

The two Ethernet ports (ET0 = `end0`, ET1 = `end1`) default to **LAN mode** and request an address from a DHCP server on your network.

In **Ad Hoc mode** the board runs its own DHCP server so a host can be connected directly, without a router. The board uses `172.16.30.100` on ET0 and `172.16.20.100` on ET1:

```bash
/opt/imdt/ethernet/get-eth-mode.sh 0       # LAN
/opt/imdt/ethernet/set-eth-mode.sh 0 2     # port 0 -> Ad Hoc (1 = LAN, 2 = Ad Hoc)
```

> **Note:** Do not connect the board to a LAN while in Ad Hoc mode — it may disrupt your network.

### LTE Modem (M.2 Key-B)

The board supports a Quectel EM05 LTE Cat 4 modem in the M.2 Key-B slot. The modem is supplied by IMDT with a one-time configuration — contact IMDT if you are interested. The `pico-modem` tool is designed for [emnify](https://www.emnify.com/) SIMs and may not work with SIMs from other providers.

With the board powered off, insert the modem (green) and the SIM card (red):

![LTE modem and SIM card](docs/lte-modem-sim.jpg)

```bash
pico-modem on        # takes ~60 seconds to come up
pico-modem signal
pico-modem sim
pico-modem connect   # brings up wwan0
pico-modem off
```

### USB

The V2N SoC has fewer USB controllers than the V2H, so not every connector on the carrier board works on both boards:

| Connector | V2H SBC | V2N SBC |
|---|---|---|
| Type-A USB 2.0 | Host | Not supported |
| Micro USB (USB 2.0) | OTG | OTG |
| M.2 Key-B USB (USB 3.0) | Host | Host |
| Type-A USB 3.0 (J8) | Host | Not supported |

### Audio

The 3.5mm jack is the default output (headphones) and input (microphone). Some variants also have a stereo speaker connector:

![Audio connectors](docs/audio-connectors.png)

```bash
aplay /opt/imdt/audio/mozart.wav               # play through the headphone jack
arecord -f S16_LE -r 44100 -c 2 /tmp/test.wav  # record from the mic (Ctrl+C to stop)
```

`/opt/imdt/audio/audio-ctl.sh` simplifies common controls, and `save` persists them across reboots:

```bash
/opt/imdt/audio/audio-ctl.sh master 80
/opt/imdt/audio/audio-ctl.sh mic mute
/opt/imdt/audio/audio-ctl.sh speakers unmute
/opt/imdt/audio/audio-ctl.sh save
```

For finer control of the TLV320AIC3x codec, use `alsamixer` (preferably over SSH, as it is slow over the serial console) or `amixer`:

![alsamixer](docs/alsamixer.png)

| Control | Description |
|---|---|
| `numid=1` 'PCM Playback Volume' | Master volume for all outputs (0–127, per channel) |
| `numid=15` / `numid=20` 'Line DAC / Line Playback Volume' | Speaker volume, fine / coarse |
| `numid=21` 'Line Playback Switch' | Speaker mute/unmute |
| `numid=17` / `numid=22` 'HP DAC / HP Playback Volume' | Headphone volume, fine / coarse |
| `numid=23` 'HP Playback Switch' | Headphone mute/unmute |
| `numid=34` 'PGA Capture Volume' | Microphone capture volume |
| `numid=35` 'PGA Capture Switch' | Microphone mute/unmute |

### CAN

CAN FD is available on the **J10** header:

![CAN connector](docs/can-connector.png)

```bash
/opt/imdt/can/start-can.sh       # brings up can0 at 250 kbit/s
candump can0
cansend can0 123#DEADBEEF
/opt/imdt/can/stop-can.sh
```

### RS232

RS232 is available on the **J9** header as `/dev/ttySC1`:

![RS232 connector](docs/rs232-connector.png)

```bash
minicom -b 115200 -8 -o -D /dev/ttySC1
```

### Sensors

```bash
cat /sys/class/hwmon/hwmon2/humidity1_input            # humidity, milli-percent
cat /sys/class/hwmon/hwmon2/temp1_input                # temperature, millidegree Celsius
cat /sys/class/thermal/thermal_zone0/temp              # SoC temperature (zones 0 and 1)
cat /sys/bus/iio/devices/iio:device1/in_magn_x_raw     # magnetometer (x, y, z)
```

The magnetometer needs a calibration step to remove its bias in a practical application. For the SoC thermal shutdown thresholds, see the thermal sensor manual in the [RZ/V2H and RZ/V2N BSP Manual Set](https://www.renesas.com/en/document/mas/rzv2h-and-rzv2n-bsp-manual-set-rtk0ef0045z94001azj-v103zip?r=25471761).

### Using the SDK

Install the SDK generated in [Building an SDK](#building-an-sdk) and source its environment script in every shell that uses it:

```bash
./imdt-glibc-x86_64-imdt-image-weston-cortexa55-imdt-v2h-sbc-toolchain-<version>.sh
. /opt/imdt/<version>/environment-setup-cortexa55-*-linux
```

The cross toolchain can then build applications with CMake or make, which can be copied to the board with `adb push` or `scp`.

A helper repository for building Linux and the out-of-tree kernel modules outside of Yocto is available at [imd-tec/renesas-kernel-build-script](https://github.com/imd-tec/renesas-kernel-build-script).

## OS Updates

Rootfs updates are managed by [SWUpdate](https://sbabic.github.io/swupdate/swupdate.html). The SD card and eMMC hold two root partitions (`root0` and `root1`), and an update writes a **new image** to the inactive one — the running system is not touched. U-Boot is then switched to boot the updated partition, and you can switch back to the previous one manually from U-Boot.

### Performing an update

Build the update file (`.swu`) for your image:

```bash
kas-container shell meta-imdt-renesas/kas/imdt-v2h-base.yml -c "bitbake imdt-image-base-swu"
```

The `.swu` file is written to `build/tmp/deploy/images/<machine>/`. Use `imdt-image-weston-swu` for the Weston image.

Copy it to the board, apply it and reboot:

```bash
scp imdt-image-base-swu-imdt-v2h-sbc.swu root@<board-ip>:/tmp/
ssh root@<board-ip> "swupdate -v -i /tmp/imdt-image-base-swu-imdt-v2h-sbc.swu && reboot"
```

Alternatively, browse to `http://<board-ip>:8080` and drop the `.swu` file onto the page. Type the `http://` prefix, as newer browsers do not fall back to HTTP.

![SWUpdate web interface](docs/swupdate-web-ui.png)

### Updating the bootloader

By default an update does **not** rewrite the bootloader, because there is no fail-safe fallback for it. To update it as well, set `overwrite_bl` before applying the update:

```bash
fw_setenv overwrite_bl 1
```

> [!WARNING]
> If the bootloader write fails you may have to [reflash it manually](#flashing-the-bootloader).
> Writing the bootloader also resets any non-default U-Boot environment variables.

## Appendix

### 1.1. Board - Top Side

![Board - top side](docs/imdt-v2-sbc-top.png)

### 1.2. Board - Bottom Side

![Board - bottom side](docs/imdt-v2-sbc-bottom.png)

### 1.3. Boot Mode Switch

![Boot mode switch location](docs/boot-mode-switch-location.png)

| Switch 1, 2, 3 | Boot mode |
|---|---|
| <img src="docs/dip-scif-download.png" width="60"/> OFF, ON, OFF | **SCIF download** — program the bootloader into xSPI flash or eMMC over the debug serial console. |
| <img src="docs/dip-xspi-boot.png" width="60"/> OFF, ON, ON | **xSPI boot** — bootloader from xSPI flash, kernel from the SD card. Falls back to SCIF download if xSPI boot fails. |
| <img src="docs/dip-emmc-boot.png" width="60"/> OFF, OFF, OFF | **eMMC boot** — bootloader and kernel from eMMC. Falls back to SCIF download if eMMC boot fails. |

---

Copyright © 2026 IMD Technologies
