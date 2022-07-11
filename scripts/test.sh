#!/bin/sh

if [[ $(git diff Assets .gitattributes) ]]; then 
    echo 'Changed'
else
    echo "Not changed"
fi