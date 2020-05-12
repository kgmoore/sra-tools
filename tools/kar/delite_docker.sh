#!/bin/bash

##
## NOTE: That script does not have permissions for execution, because it should
##       run only from docker container. It is umbrella for sra_delite.sh script
##

usage ()
{
    cat <<EOF >&2

That script will run delite process on SRA fun by it's accession

Syntax:

    `basename $0` <ACCESSION | -h | --help>

Where:

       ACCESSION - valid SRA accession
     -h | --help - print that help message

EOF

}

if [ $# -ne 1 ]
then
    usage

    echo ERROR: ACCESSION parameter is not defined >&2
    exit 1
fi

case $1 in
    -h)
        usage
        exit 0
        ;;
    --help)
        usage
        exit 0
        ;;
    *)
        ACC=$1
        ;;
esac

run_cmd ()
{
    CMD="$@"

    if [ -z "$CMD" ]
    then
        echo ERROR: invalid usage or run_cmd command >&2
        exit 1
    fi

    echo
    echo "## $CMD"
    eval $CMD
    RV=$?
    if [ $RV -ne 0 ]
    then
        echo ERROR: command failed with exit code $RV >&2
        exit $RV
    fi
}

OUTD=/output/$ACC

##
## Usual delite stuff: import/delite/export

run_cmd sra_delite.sh import --accession $ACC --target $OUTD

run_cmd sra_delite.sh delite --target $OUTD  --schema /etc/ncbi/schema

run_cmd sra_delite.sh export --target $OUTD

##
## Removing orig directory

D2R=$OUTD/orig
if [ -d $D2R ]
then
        ## We do not care about if that command will fail
    echo Removing directory $D2R
    vdb-unlock $D2R
    rm -r $D2R
    if [ $? -ne 0 ]
    then
        echo WARNING: can not remove directory $D2R
    fi
fi

echo DONE
