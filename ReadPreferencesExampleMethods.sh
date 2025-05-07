#!/bin/bash

#created by Anthony Darlow 07/05/2025

## Methods for reading key / values from preferences in scripts
## Method One: Used inspired by Thijs Xhaflaire and his DiskEncrypter project
## https://github.com/txhaflaire/DiskEncrypter
##
## Mehtod Two: Shared with me by Armin Briegel during the creations of my
## SchoolAssembly project.


## Method One Funcation

## The function readPref is reading the managedPlist and the configured key, if there is no key value pair then we are using the $2 default value.

managedPlist="/Library/Managed Preferences/com.cantscript.localUserInfo.plist"

readPref() {
	# $1: key
	# $2: default (optional)
	local key=$1
	local defaultValue=$2
	
	if ! value=$( /usr/libexec/PlistBuddy -c "Print :$key" "$managedPlist" 2>/dev/null ); then
		value="$defaultValue"
	fi
	echo "$value"
}

##Method One Usage - Store result as script variable

schoolAssetTag1=$( readPref assestTag "no data")
echo "Result from method 1: $schoolAssetTag1"


################################


## Method Two Funcations

## The function getPref is reading the MANAGED_PREFERENCE_DOMAIN and the configured key, if there is no key value pair then we are using the $2 default value. $3 is targeting the required preference domain 

MANAGED_PREFERENCE_DOMAIN="com.cantscript.localUserInfo"

getPref() { # $1: key, $2: default value, $3: domain
	local key=${1:?"key required"}
	local defaultValue=${2-:""}
	local domain=${3:-"$MANAGED_PREFERENCE_DOMAIN"}
	
	value=$(osascript -l JavaScript \
		-e "$.NSUserDefaults.alloc.initWithSuiteName('$domain').objectForKey('$key').js")
	
	if [[ -n $value ]]; then
		echo $value
	else
		echo $defaultValue
	fi
}

getPrefIsManaged() { # $1: key, $2: domain
	local key=${1:?"key required"}
	local domain=${2:-"$MANAGED_PREFERENCE_DOMAIN"}
	
	osascript -l JavaScript -e "$.NSUserDefaults.alloc.initWithSuiteName('$domain').objectIsForcedForKey('$key')"
}

##Method One Usage - Store result as script variable
schoolAssetTag2=$(getPref assestTag "no data")
echo "Result from method 2: $schoolAssetTag2"