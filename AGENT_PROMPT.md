I am GitHub Copilot, the intelligent AI agent that will build a project in this repository.

I will take pikvm - a KVM made out of a raspberry pi - and reimplement it for the Raspberry Pi OS. (Pikvm uses Arch Linux)
I will find all of how it sets linux up, and replicate it for the raspberry pi os (debian).
The target hardware platform is raspberry pi 4b.

My intention isn't to replicate it exactly, but instead to find the simplest, fastest way to replicate the setup, without depending on pikvm, arch linux packages, etc.

I want to checkout the git repos that pikvm uses and make shell scripts to reproduce all the packages, configuration, etc, so they can later be run on a raspberry pi.

I will try to set up a github action with an aarch64 build environment (if possible) to try to build and test as much of it as I can, since I don't have a raspberry pi to test on right now.

Pikvm has its own complex, multi-repo system for building its custom Raspberry Pi OS images specific to KVM.
I want to avoid using that since it is too complex and is Arch Linux-specific.
But I will use as it as reference to inform my work and what needs to be done.

I will checkout whatever I need to, browse the web for whatever I need to, to get all the information I need.

I will write down a plan for how I will go about the work before I begin.

I will try to focus on simplicity.
I am basically trying to make a script to install packages and a script to configure installed software.
But I may also need to do things like build new custom packages to patch software which needs patching, or to build it for the pi's architecture if an existing package doesn't exist.
I will make scripts to perform build steps, so that if they don't work in github actions, they can be run on a raspberry pi to build the software on the target architecture.

Links for me to use:
 - [PiKVM GitHub Org](https://github.com/pikvm)
 - [Repository of Arch packages](https://github.com/pikvm/packages.git)
 - [Repository of PiKVMd daemon](https://github.com/pikvm/kvmd.git)
 - [Repository of ustreamer, a lightweight mjpeg-http streamer](https://github.com/pikvm/ustreamer.git)
 - [Repository of pi-builder, an OS builder for pikvm](https://github.com/pikvm/pi-builder.git)
 - [Repository of pikvm os, more custom OS setup files](https://github.com/pikvm/os.git)
 - [Repository of kvmd-fan, a pikvm fan controller](https://github.com/pikvm/kvmd-fan.git)

