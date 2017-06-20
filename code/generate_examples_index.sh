#!/bin/bash

echo "#Examples"
echo

for file in ./examples/*.LoG
do
    echo "## $(basename $file)"
    echo
    echo "\`\`\`"
    cat $file
    echo "\`\`\`"
    echo
    echo
done
