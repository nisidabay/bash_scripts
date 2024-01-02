#!/usr/bin/bash

# Man page to PDF
read -p "What man page do you want?: "
if [ -n "$REPLY" ]
then
  man -t "$REPLY" | ps2pdf - "${REPLY}.pdf"
  exit 0
fi
