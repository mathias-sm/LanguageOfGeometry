#!/bin/bash

echo "---"
echo "title: A set of examples"
echo "css: ../style.css"
echo "---"
echo


for file in ./examples/*.LoG
do
    echo "## $(basename -s .LoG $file)"
    echo
    echo "\`\`\`{.LoG contenteditable= autocomplete=off spellcheck=false}"
    cat $file
    echo "\`\`\`"
    echo
    echo
done
