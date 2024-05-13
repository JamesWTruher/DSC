#!/bin/sh

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

export exist=true
export NONINTERACTIVE=1

# $packageName and $_exist are sent as env vars by dsc converting the JSON input to name/value pairs

check_args() {
    if [[ -z $packageName ]]; then
        echo "packageName not set"
        exit 1
    fi
}

to_json() {
    while read line; do
        echo $line | awk '{print "{ \"packageName\": \""$1"\", \"version\": \""$2"\", \"_exist\": "ENVIRON["exist"]" }"}'
    done
}

get_yum() {
    pkgname=$1
    InstalledSection=0
    AvailableSection=0
    yum list $pkgname | while read line; do
        if [ "$line" = "Installed Packages" ]; then
            InstalledSection=1
        elif [ "$line" = "Available Packages" ]; then
            AvailableSection=1
            InstalledSection=0
        elif [ $InstalledSection = 1 ]; then
            echo $line | awk '{
                split($0, a, " ");
                printf("{ \"_exists\": \"%s\", \"packageName\": \"%s\", \"Version\": \"%s\", \"Source\": \"%s\" }\n", ENVIRON["exist"], a[1], a[2], a[3]);
            }'
        fi
    done
}


if [ $# -eq 0 ]; then
    echo "Command not provided, valid commands: get, set, export"
    exit 1
elif [[ $1 == "get" ]]; then
    check_args
    output="$(get_yum $packageName)"
    if [[ -z $output ]]; then
        exist=false
        output="${packageName}"
    fi
    echo $output | to_json
elif [[ $1 == "set" ]]; then
    check_args
    if [[ -z $_exist ]]; then
        # if $_exist is not defined in the input, it defaults to `true`
        _exist=true
    fi
    if [[ $_exist = true ]]; then
        yum install -y "${packageName}"
    else
        yum remove -y "${packageName}"
    fi
elif [[ $1 == "export" ]]; then
    get_yum
else
    echo "Invalid command, valid commands: get, set, export"
    exit 1
fi
