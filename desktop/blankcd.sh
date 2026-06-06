#!/usr/bin/env bash
#
# Blank a CD-R.
#
# Dependencies: cdrecord

cdrecord -dev=0,3,0 -v -blank=all 1>&2
eject
