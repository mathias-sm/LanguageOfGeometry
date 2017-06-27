#!/bin/bash

echo "---"
echo "title: A set of examples"
echo "css: ../style.css"
echo "---"
echo

for file in ./examples/*.LoG
do
    echo "## $(basename $file)"
    echo
    echo "\`\`\`LoG"
    cat $file
    echo "\`\`\`"
    echo
    echo
done
