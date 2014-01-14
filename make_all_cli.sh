#!/bin/sh

if [ $# -eq 0 ]; then
    mkdir -p build
    cd build
    rm memhack
    #clang -x objective-c -arch armv7 -fmessage-length=0 -std=c99 -Wno-trigraphs -fpascal-strings -Os -Wno-missing-field-initializers -Wno-missing-prototypes -Wno-return-type -Wno-implicit-atomic-properties -Wno-receiver-is-weak -Wformat -Wno-missing-braces -Wno-parentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter -Wno-unused-variable -Wno-unused-value -Wno-empty-body -Wno-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wno-constant-conversion -Wno-int-conversion -Wno-enum-conversion -Wno-shorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wno-undeclared-selector -Wno-deprecated-implementations -framework Foundation -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk -Wprotocol -Wdeprecated-declarations -g -Wno-sign-conversion -miphoneos-version-min=6.0 ../src/*.m -o memhack

    clang -x objective-c -arch armv7 -std=c99 -framework Foundation -Os -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk ../src/*.m -o memhack

    ldid -S../entitlements.xml memhack
    cd ../

elif [ "$1" == "trans" ] ; then
    #scp build/memhack root@192.168.0.108:/usr/bin
    scp build/memhack root@192.168.11.5:/usr/bin

elif [ "$1" == "-h" ] ; then
    echo usage:
    echo "$0            // compile"
    echo "$0 trans      // transfer to iDevice"
fi

