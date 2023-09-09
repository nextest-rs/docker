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
