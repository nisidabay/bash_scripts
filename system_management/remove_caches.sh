#!/usr/bin/env bash
#
# Remove Python cache directories.
#
# Dependencies: find

find . -type d -name '.mypy_cache' -exec rm -rf {} +
find . -type d -name '__pycache__' -exec rm -rf {} +
