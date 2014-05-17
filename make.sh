#!/bin/sh

usage()
{
    echo "$0" "[package|install]"
    echo "set SSH_INSTALL_IP for remote install"
}

if [ $# -eq 0 ]; then
    usage
    exit
fi

while [ "$1" != "" ]; do
    case $1 in
        package)
            echo make package
            echo ldid entilements
            ldid -Sentitlements.xml build/Release-iphoneos/imem.app/imem

            rm -rf pkg/Applications/*
            cp -a build/Release-iphoneos/imem.app/imem pkg/usr/bin/
            find pkg | egrep ".*DS_Store|.*~" | xargs rm
            chmod -R 755 pkg/DEBIAN

            export COPYFILE_DISABLE
            export COPY_EXTENDED_ATTRIBUTES_DISABLE
            dpkg-deb-fat -b pkg
            mv pkg.deb imem.deb
            cp imem.deb ../cydia/
            ;;
        install)
            if [[ -z $SSH_INSTALL_IP ]]; then
                echo SSH_INSTALL_IP is not set
                exit
            fi            
            scp build/Release-iphoneos/imem.app/imem root@$SSH_INSTALL_IP:/usr/bin
            ssh root@$SSH_INSTALL_IP "chmod 4755 /usr/bin/imem; chown root:wheel /usr/bin/imem;"
            ;;
        *)
            usage
            ;;
    esac
    shift
done
