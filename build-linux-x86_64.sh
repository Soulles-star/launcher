#!/bin/bash

set -e

pushd native
cmake -B build-x64 .
cmake --build build-x64 --config Release
popd


umask 022

source .jdk-versions.sh

rm -rf build/linux-x64
mkdir -p build/linux-x64

if ! [ -f linux64_jre.tar.gz ] ; then
    curl -Lo linux64_jre.tar.gz $LINUX_AMD64_LINK
fi

echo "$LINUX_AMD64_CHKSUM linux64_jre.tar.gz" | sha256sum -c

# Note: Host umask may have checked out this directory with g/o permissions blank
chmod -R u=rwX,go=rX appimage
# ...ditto for the build process
chmod 644 target/Eldritch.jar

cp native/build-x64/src/Eldritch build/linux-x64/
cp target/Eldritch.jar build/linux-x64/
cp packr/linux-x64-config.json build/linux-x64/config.json
cp target/filtered-resources/eldritch.desktop build/linux-x64/
cp appimage/eldritch.png build/linux-x64/
mkdir -p build/linux-x64/usr/share/icons/hicolor/128x128/apps/
cp appimage/eldritch.png build/linux-x64/usr/share/icons/hicolor/128x128/apps/

tar zxf linux64_jre.tar.gz
mv jdk-$LINUX_AMD64_VERSION-jre build/linux-x64/jre

pushd build/linux-x64/
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
curl -z runtime-x86_64 -o runtime-x86_64 -L https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64

chmod +x appimagetool-x86_64.AppImage

./appimagetool-x86_64.AppImage \
	--runtime-file runtime-x86_64 \
	build/linux-x64/ \
	Eldritch.AppImage
