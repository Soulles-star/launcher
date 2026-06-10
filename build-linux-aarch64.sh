#!/bin/bash

set -e

pushd native
cmake -DCMAKE_TOOLCHAIN_FILE=arm64-linux-gcc.cmake -B build-aarch64 .
cmake --build build-aarch64 --config Release
popd


umask 022

source .jdk-versions.sh

rm -rf build/linux-aarch64
mkdir -p build/linux-aarch64

if ! [ -f linux_aarch64_jre.tar.gz ] ; then
    curl -Lo linux_aarch64_jre.tar.gz $LINUX_AARCH64_LINK
fi

echo "$LINUX_AARCH64_CHKSUM linux_aarch64_jre.tar.gz" | sha256sum -c

# Note: Host umask may have checked out this directory with g/o permissions blank
chmod -R u=rwX,go=rX appimage
# ...ditto for the build process
chmod 644 target/Eldritch.jar

cp native/build-aarch64/src/Eldritch build/linux-aarch64/
cp target/Eldritch.jar build/linux-aarch64/
cp packr/linux-aarch64-config.json build/linux-aarch64/config.json
cp target/filtered-resources/eldritch.desktop build/linux-aarch64/
cp appimage/eldritch.png build/linux-aarch64/
mkdir -p build/linux-aarch64/usr/share/icons/hicolor/128x128/apps/
cp appimage/eldritch.png build/linux-aarch64/usr/share/icons/hicolor/128x128/apps/

tar zxf linux_aarch64_jre.tar.gz
mv jdk-$LINUX_AARCH64_VERSION-jre build/linux-aarch64/jre

pushd build/linux-aarch64
mkdir -p jre/lib/amd64/server/
ln -s ../../server/libjvm.so jre/lib/amd64/server/ # packr looks for libjvm at this hardcoded path

# Symlink AppRun -> Eldritch
ln -s Eldritch AppRun

# Ensure Eldritch is executable to all users
chmod 755 Eldritch
popd

# AppImageKit release assets were removed when the project split; use the
# maintained appimagetool + type2-runtime continuous releases (same as
# upstream runelite/launcher).
curl -z appimagetool-x86_64.AppImage -o appimagetool-x86_64.AppImage -L https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
curl -z runtime-aarch64 -o runtime-aarch64 -L https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-aarch64

chmod +x appimagetool-x86_64.AppImage

ARCH=arm_aarch64 ./appimagetool-x86_64.AppImage \
	--runtime-file runtime-aarch64  \
	build/linux-aarch64/ \
	Eldritch-aarch64.AppImage
