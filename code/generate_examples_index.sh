#!/bin/bash

echo "---"
echo "title: A set of examples"
echo "header-includes:"
cat examples/figures.js
echo "css: ../style.css"
echo "---"
echo


for file in ./examples/*.LoG
do
    echo "## $(basename -s .LoG $file)"
    echo
    echo "\`\`\`LoG"
    cat $file
    echo "\`\`\`"
    echo
    echo
done
