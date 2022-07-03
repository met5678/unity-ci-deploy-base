#!/bin/sh

DIRNAME=${PWD##*/}
ORG=${1:-"roo-makes"}

REPO="$ORG/$DIRNAME"

gh repo create $REPO --push --public
