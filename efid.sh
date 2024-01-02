#!/bin/sh
#print user information

echo "Efective user-ID:"
id -un

echo "Real user-ID:"
id -unr

echo "group ID:"
id -gn
