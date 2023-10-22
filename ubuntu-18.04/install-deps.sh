#!/bin/bash

# Install dependencies for nextest release jobs.

set -euo pipefail

apt-get -qq update
apt-get install -y software-properties-common sudo build-essential curl jq
add-apt-repository ppa:git-core/ppa
apt-get -qq update
apt-get -qq -y install git-core

# gh is required by taiki-e/upload-rust-binary-action
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt-get -qq update \
&& sudo apt-get -qq -y install gh

# node20 is required by actions/checkout, but it depends on glibc 2.28. We install a copy of glibc
# 2.28, then patch node20 to rely on it.
#
# Adapted from https://github.com/nodesource/distributions/issues/1392#issuecomment-1749131791.
curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n
bash n 20

# Install glibc 2.28 to /opt/glibc-2.28
sudo apt-get install -y gawk patchelf bison
cd ~
curl -fsSLO https://ftp.gnu.org/gnu/glibc/glibc-2.28.tar.gz
tar -zxf glibc-2.28.tar.gz
cd glibc-2.28
mkdir build
cd build
../configure --prefix=/opt/glibc-2.28
make "-j$(nproc)"
make install
cd ../..
rm -fr glibc-2.28 glibc-2.28.tar.gz

# Patch node to use glibc 2.28
patchelf --set-interpreter /opt/glibc-2.28/lib/ld-linux-x86-64.so.2 --set-rpath /opt/glibc-2.28/lib/:/lib/x86_64-linux-gnu/:/usr/lib/x86_64-linux-gnu/ /usr/local/bin/node
# Hard link node20 to node
ln /usr/local/bin/node /usr/local/bin/node20
