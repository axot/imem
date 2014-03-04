#!/bin/sh

if [ $# -eq 0 ]; then

echo "$0" "[ent|trans|repo]"

elif [ "$1" == "ent" ] ; then

echo ldid entilements
ldid -Sentitlements.xml build/Release-iphoneos/imem.app/imem

elif [ "$1" == "trans" ] ; then

scp build/Release-iphoneos/imem.app/imem root@192.168.0.108:/usr/bin
ssh root@192.168.0.108 "chmod 4755 /usr/bin/imem; chown root:wheel /usr/bin/imem;"

elif [ "$1" == "repo" ] ; then

echo make repo
./make.sh ent

rm -rf pkg/Applications/*
cp -a build/Release-iphoneos/imem.app/imem pkg/usr/bin/
find pkg | egrep ".*DS_Store|.*~" | xargs rm
chmod -R 755 pkg/DEBIAN

export COPYFILE_DISABLE
export COPY_EXTENDED_ATTRIBUTES_DISABLE
dpkg-deb-fat -b pkg
mv pkg.deb imem.deb
cp imem.deb ../cydia/

fi
