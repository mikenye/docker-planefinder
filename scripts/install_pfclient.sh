#!/usr/bin/env bash
#shellcheck shell=bash

set -xe

# Get system architecture
ARCH=$(uname -m)
echo "System architecture is: ${ARCH}"

# Determine architecture of pfclient to get
if [ "${ARCH}" = "x86_64" ]
then
    PFARCH="i386"
    dpkg --add-architecture i386
    apt-get update
    apt-get install --no-install-recommends -y libc6:i386
elif [ "${ARCH}" = "armv7l" ]
then
    PFARCH="armhf"
    apt-get install --no-install-recommends -y libc6
elif [ "${ARCH}" = "aarch64" ]
then
    PFARCH="armhf"
    dpkg --add-architecture armhf
    apt-get update
    apt-get install --no-install-recommends -y libc6:armhf
else
    echo "Unsupported system architecture: ${ARCH}"
    exit 0
fi

# Determine regex to use
if [ "${PFARCH}" = "armhf" ]
then
    # PFCLIENTREGEX="http:\/\/client\.planefinder\.net\/pfclient_(\w)(\.\w)*_armhf\.deb"
    PFCLIENTURL="http://client.planefinder.net/pfclient_4.1.1_armhf.deb"
elif [ "${PFARCH}" = "i386" ]
then
    # PFCLIENTREGEX="http:\/\/client\.planefinder\.net\/pfclient_(\w)(\.\w)*_i386\.deb"
    PFCLIENTURL="http://client.planefinder.net/pfclient_4.1.1_i386.deb"
else
    echo "Unsupported pfclient architecture: ${ARCH}"
    exit 0
fi
echo "System architecture is: ${PFARCH}"

# Get link to pfclient download
USERAGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:81.0) Gecko/20100101 Firefox/81.0'
# curl -c /tmp/cookiejar -A "$USERAGENT" --location "https://planefinder.net/" > /dev/null 2>&1
# PFCLIENTURL=$(curl --location -b /tmp/cookiejar -A "$USERAGENT" "https://planefinder.net/coverage/client" | grep -oE "$PFCLIENTREGEX")
echo "pfclient download URL is: ${PFCLIENTURL}"

# Download pfclient
curl -A "$USERAGENT" -o /tmp/pfclient.deb "${PFCLIENTURL}" 

# Install pfclient
dpkg --install /tmp/pfclient.deb

# Kill running pfclient
kill -9 "$(cat /run/pfclient.pid)"
rm /run/pfclient.pid
