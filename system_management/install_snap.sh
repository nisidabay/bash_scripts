#!/usr/bin/env bash
#
# Install snapd and snap-store.
#
# Dependencies: apt, snap

sudo apt install snapd -y && snap install snap-store
