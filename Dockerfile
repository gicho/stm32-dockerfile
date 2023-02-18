FROM ubuntu:22.04

# Prep Workspace
RUN apt-get update && apt-get clean &&\
	apt-get install -y \
				curl \
				xz-utils\
				build-essential \
				git \
				cmake \
				openocd \
				libusb-1.0

# Prep Folders
RUN mkdir /opt/gcc-arm-none-eabi &&\
	mkdir /opt/STM32CubeProgrammer &&\
	mkdir /opt/ARM &&\
	mkdir /opt/ST

# Get ARM Toolchain
RUN ARM_TOOLCHAIN_VERSION=$(curl -s https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads | grep -Po '<h4>Version \K.+(?=</h4>)')  &&\
	curl -Lo /opt/ARM/gcc-arm-none-eabi.tar.xz "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_TOOLCHAIN_VERSION}/binrel/arm-gnu-toolchain-${ARM_TOOLCHAIN_VERSION}-x86_64-arm-none-eabi.tar.xz"

# Get ST Toolchain Files
COPY /ST /opt/ST

# Install ARM Toolchain
RUN tar xf /opt/ARM/gcc-arm-none-eabi.tar.xz --strip-components=1 -C /opt/gcc-arm-none-eabi

# Install ST Toolchain
RUN tar xf /opt/ST/STM32CubeProgrammer.tar.xz --strip-components=1 -C /opt/STM32CubeProgrammer &&\
	cp -a /opt/ST/ST-Link /opt

# Clean Up
RUN rm /opt/ST/STM32CubeProgrammer.tar.xz &&\
	rm -r /opt/ARM &&\
	rm -r /opt/ST &&\
	apt-get remove -y xz-utils curl

# Add Toolchain to PATH
ENV PATH="$PATH:/opt/gcc-arm-none-eabi/bin"
ENV PATH="$PATH:/opt/STM32CubeProgrammer/bin/"
ENV PATH="$PATH:/opt/ST-Link/bin/"