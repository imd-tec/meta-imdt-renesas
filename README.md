# IMDT Renesas EVK Board Support Package

## Prerequisites

* Ubuntu 20.04 desktop, laptop or virtual machine
* The following packages must be installed via **`apt`**:

```
gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm p7zip-full libyaml-dev libssl-dev
```

Follow the instructions on the [imdt-renesas-manifest-dev repository](https://github.com/imd-tec/imdt-renesas-manifest-dev) to install **`repo`** and create a working directory.

## Setting up the BitBake environment

### Production Builds

Support for production builds will be made available when public versions of the **`meta-imdt-renesas`**, **`renesas-u-boot-cip`** and **`renesas-rz-linux-cip`** repositories have been uploaded to GitHub.

### Development Builds

Run the following command to set up the environment, using the template configuration in the **`meta-imdt-renesas-internal`** layer:

```sh
TEMPLATECONF=${PWD}/sources/meta-imdt-renesas-internal/docs/template/conf/ source sources/poky/oe-init-build-env
```

## Building the Board Support Package

The BSP supports the Renesas RZ/V2H EVKs (**`rzv2h-evk-dev`**, **`rzv2h-evk-alpha`** and **`rzv2h-evk-ver1`**), in addition to the IMDT RZ/V2H EVK (**`imdt-rzv2h-evk`**).

You can either add the **`MACHINE`** definition to the **`conf/local.conf`** file, or specify it on the command line as shown below.

### Renesas EVK (Alpha)

```sh
MACHINE=rzv2h-evk-alpha bitbake core-image-minimal
```

### IMDT EVK

```sh
MACHINE=imdt-rzv2h-evk bitbake core-image-minimal
```
