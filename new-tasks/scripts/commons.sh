#!/bin/bash

OSS_REPOSITORY="maven { url \"https:\/\/oss.jfrog.org\/artifactory\/oss-snapshot-local\/\" }"
MAVEN_LOCAL_REPOSITORY="mavenLocal()"
INCLUDE_ARROW_DOCS="include 'arrow-docs'"
ERROR_LOG=error.log

function check_and_download()
{
    REPOSITORY_ID=$1
    DIRECTORY=$2

    if [ ! -d $DIRECTORY ]; then
        cd $BASEDIR
        git clone git@github.com:arrow-kt/${REPOSITORY_ID}.git $DIRECTORY
    fi
}

function removeArrowDocs()
{
    echo "Removing Arrow Docs ($1)..."
    sed -i "/$INCLUDE_ARROW_DOCS/d" $1
}

function addArrowDocs()
{
    echo "Adding Arrow Docs ($1)..."
    echo $INCLUDE_ARROW_DOCS >> $1
}

function replaceGlobalPropertiesbyLocalConf()
{
    echo "Replacing global properties by local conf ($1) ..."
    #sed -i "s/GENERIC_CONF/#GENERIC_CONF/g" $1
    sed -i "/^GENERIC_CONF/d" $1
    echo "GENERIC_CONF=file://$BASEDIR/arrow/generic-conf.gradle" >> $1
}

function replaceLocalConfbyGlobalProperties()
{
    echo "Replacing local conf by global properties ($1) ..."
    sed -i "/^GENERIC_CONF/d" $1
    sed -i "s/#GENERIC_CONF/GENERIC_CONF/g" $1
}

function changeGlobalConf()
{
    echo "Replacing OSS by local repository ($BASEDIR/arrow/generic-conf.gradle)..."
    sed -i "s/$OSS_REPOSITORY/$MAVEN_LOCAL_REPOSITORY/g" $BASEDIR/arrow/generic-conf.gradle
}

function undoGlobalConfChange() 
{
    echo "Replacing local repository by OSS ($BASEDIR/arrow/generic-conf.gradle) ..."
    sed -i "s/$MAVEN_LOCAL_REPOSITORY/$OSS_REPOSITORY/g" $BASEDIR/arrow/generic-conf.gradle
}

function changeLocalConf()
{
    LIB=$1

    replaceGlobalPropertiesbyLocalConf $BASEDIR/$LIB/gradle.properties
    removeArrowDocs $BASEDIR/$LIB/settings.gradle
}

function undoLocalConfChange()
{
    LIB=$1

    #replaceLocalConfbyGlobalProperties $BASEDIR/$LIB/gradle.properties
    addArrowDocs $BASEDIR/$LIB/settings.gradle
}

function manageExitCode()
{
    EXIT_CODE=$1
    LIB=$2

    if [[ $EXIT_CODE -ne 0 ]]; then
        cat $ERROR_LOG
        rm $ERROR_LOG
        undoLocalConfChange $LIB
        #undoGlobalConfChange
        exit $EXIT_CODE
    fi
}

function runAndManageExitCode()
{
    LIB=$1
    COMMAND=$2

    changeLocalConf $LIB
    $COMMAND $LIB 2> $ERROR_LOG
    manageExitCode $? $LIB
    undoLocalConfChange $LIB
}

function installLib()
{
    LIB=$1

    runAndManageExitCode "$LIB" "$BASEDIR/new-tasks/scripts/project-install.sh"
}

function testLib() {
    LIB=$1

    runAndManageExitCode "$LIB" "$BASEDIR/arrow/scripts/project-test.sh"
}
