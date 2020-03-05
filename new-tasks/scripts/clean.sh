#!/bin/bash

cd $(dirname $0)/../..
export BASEDIR=$(pwd)

cd $BASEDIR/$1
./gradlew clean
