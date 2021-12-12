#!/bin/bash

set -x

### Install Build Tools #1

DEBIAN_FRONTEND=noninteractive apt -qq update
DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	appstream \
	automake \
	autotools-dev \
	build-essential \
	checkinstall \
	cmake \
	curl \
	devscripts \
	equivs \
	extra-cmake-modules \
	gettext \
	git \
	gnupg2 \
	lintian \
	wget

### Add Neon Sources

wget -qO /etc/apt/sources.list.d/neon-user-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.neon.user

DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
	55751E5D > /dev/null

curl -L https://packagecloud.io/nitrux/repo/gpgkey | apt-key add -;

wget -qO /etc/apt/sources.list.d/nitrux-repo-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.nitrux

DEBIAN_FRONTEND=noninteractive apt -qq update

### Install Package Build Dependencies #2

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	libkf5config-dev \
	libkf5coreaddons-dev \
	libkf5i18n-dev \
	libkf5kio-dev \
	libkf5notifications-dev \
	libkf5service-dev \
	libqt5svg5-dev \
	libqt5waylandcompositor5-dev \
	mauikit \
	qtbase5-dev \
	qtdeclarative5-dev \
	qtquickcontrols2-5-dev

### Clone repo.

git clone --single-branch --branch master https://github.com/Nitrux/maui-shell.git

rm -rf maui-shell/{screenshots,wallpapers,LICENSE,README.md}

### Compile Source

mkdir -p maui-shell/build && cd maui-shell/build

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR=lib/x86_64-linux-gnu ..

make

### Run checkinstall and Build Debian Package
### DO NOT USE debuild, screw it

>> description-pak printf "%s\n" \
	'Maui Shell is a convergent shell for desktop, tablets and phones.' \
	'' \
	'Cask is the shell container and elements templates, such as panels, popups, cards etc.' \
	'' \
	'Zpace is the composer, which is the layout and places the windows' \
	'surfaces into the Cask container.' \
	'' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=maui-shell \
	--pkgversion=2.1.0 \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=lib \
	--pkgsource=maui-shell \
	--pakdir=../.. \
	--maintainer=uri_herrera@nxos.org \
	--provides=maui-shell \
	--requires="libc6,libkf5configcore5,libkf5coreaddons5,libkf5i18n5,libkf5kiocore5,libkf5service5,mauikit \(\>= 2.1.0\),libqt5core5a,libqt5gui5,libqt5qml5,libqt5widgets5,libstdc++6,qml-module-qt-labs-platform" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
