#!/bin/sh
#Erase CDR

cdrecord -dev=0,3,0 -v -blank=all 1>&2
eject 
