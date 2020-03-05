#!/bin/bash

cd $(dirname $0)/../..
export BASEDIR=$(pwd)
. $BASEDIR/new-tasks/scripts/commons.sh

ARROW_LIB=$1

changeGlobalConf
testLib ${ARROW_LIB}
#undoGlobalConfChange
