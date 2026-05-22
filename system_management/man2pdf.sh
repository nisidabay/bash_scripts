#!/usr/bin/env bash
#
# Convert man page to PDF.
#
# Dependencies: man, ps2pdf

read -p "What man page do you want?: "
if [ -n "$REPLY" ]; then
    man -t "$REPLY" | ps2pdf - "${REPLY}.pdf"
    exit 0
fi
