# IMDT Renesas V2H SBC Board Support Package

## Prerequisites

* Ubuntu 20.04 desktop, laptop or virtual machine
* The following packages must be installed via **`apt`**:

```
gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm p7zip-full libyaml-dev libssl-dev
```

Follow the instructions on the [imdt-renesas-manifest repository](https://github.com/imd-tec/imdt-renesas-manifest) to install **`repo`** and create a working directory.

## Setting up the BitBake environment

Run the following command to set up the environment, using the template configuration in the **`meta-imdt-renesas`** layer:

```sh
TEMPLATECONF=${PWD}/sources/meta-imdt-renesas/docs/template/conf/ source sources/poky/oe-init-build-env
```

## Building the Board Support Package

The BSP supports the IMDT V2H SBC (**`imdt-v2h-sbc`**). It is set as the default machine in the **`local.conf`** file.


### IMDT SBC

```sh
bitbake imdt-image-core
```
