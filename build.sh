#!/bin/bash

set -e
trap_int() {
    echo "INT signal recieved. stopping build."
    exit 1
}

trap trap_int INT

clean=0
build=0

usage(){
    echo "
Usage: $0
        [ -c | --clean ] Clean files.
        [ -b | --build ] Do a build.
"
    exit 1
}

parse_long_option() {
    case $1 in
        --clean) clean=1 ;;
        --build) build=1 ;;
        --help | -h)  usage ;;
        *) echo "Invalid option: $1" >&2
                usage ;;
    esac
}

parse_short_option() {
    local OPTIND opt
    while getopts "cbh" opt; do
        case $opt in
            c) clean=1 ;;
            b) build=1 ;;
            h) usage ;;
            *) echo "Invalid option: -$OPTARG" >&2
                usage ;;
        esac
    done
    shift $((OPTIND - 1))
}

if [ $# -eq 0 ]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    if [[ $1 == --* ]]; then
        parse_long_option "$1"
    elif [[ $1 == -* ]]; then
        parse_short_option "$1"
    else
        usage
    fi
    shift
done



# now we try to work as per arguments:
. ./setup_env.sh
sdkdir="$(pwd)/nodemcu-firmware"
workdir="$(pwd)"

if [ $clean -eq 1 ]
then
    cd "$sdkdir"
    make clean
fi


if [ $build -eq 1 ]
then
    cp config_esp8266/user_config.h  nodemcu-firmware/app/include/
    cp config_esp8266/user_modules.h nodemcu-firmware/app/include/
    cd "$sdkdir"
    make -j$(nproc)
fi
