#!/bin/sh

if [[ $(git rev-parse --show-toplevel 2>/dev/null) = "$PWD" ]]; then
  echo "In root of git repo"
else
  echo "Not in root of git repo"
fi
