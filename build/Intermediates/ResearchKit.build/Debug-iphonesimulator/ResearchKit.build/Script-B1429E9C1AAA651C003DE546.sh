#!/bin/sh
# License check: all

echo "Checking for BSD license text (files missing licenses listed below):"

LICENSE_MISSING=`find . -name '*.[hm]' -o -name '*.vsh' -o -name '*.fsh' -exec grep -iL "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS" {} \;`
echo "$LICENSE_MISSING"

test "$LICENSE_MISSING" == ""


