#!/bin/bash

cd $(dirname $0)/../..
export BASEDIR=$(pwd)
. $BASEDIR/new-tasks/scripts/commons.sh

LIBS=(arrow-core arrow-ui arrow-fx arrow-incubator arrow-optics arrow-ank arrow-integrations)
REPOSITORIES=(arrow arrow-examples)
ARROW_LIB=$1

echo "Check and prepare the environment ..."
for repository in ${REPOSITORIES[*]}; do
    check_and_download $repository $repository
done
for lib in ${LIBS[*]}; do
    check_and_download $lib ${lib}-lib
done

changeGlobalConf
for lib in ${LIBS[*]}; do
    installLib ${lib}-lib
done
#undoGlobalConfChange
