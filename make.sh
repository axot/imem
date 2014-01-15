#!/bin/sh

ldid -Sentitlements.xml build/Release-iphoneos/imem.app/imem
scp build/Release-iphoneos/imem.app/imem root@192.168.11.5:/usr/bin
