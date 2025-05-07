#!/bin/bash

#created by Anthony Darlow 07/05/2025

## Example script that reads preferences delivered by a profile

## Funcations for reading preferences from the targeted profile / preference domain
MANAGED_PREFERENCE_DOMAIN="com.jamf.localUserInfo"

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

## Second getPrefs function for the Student / Teacher prefs. Crude way of doing it but it'll do the trick
MANAGED_PREFERENCE_DOMAIN_2="com.zuludesk.macos.selfservice"

getPref2() { # $1: key, $2: default value, $3: domain
	local key=${1:?"key required"}
	local defaultValue=${2-:""}
	local domain=${3:-"$MANAGED_PREFERENCE_DOMAIN_2"}
	
	value=$(osascript -l JavaScript \
		-e "$.NSUserDefaults.alloc.initWithSuiteName('$domain').objectForKey('$key').js")
	
	if [[ -n $value ]]; then
		echo $value
	else
		echo $defaultValue
	fi
}


#Logic for choosing which icon to use in the dialog window
studentIcon="/Applications/Jamf Student.app"
teacherIcon="/Applications/Jamf Teacher.app"

if [ -e "/Library/Managed Preferences/com.zuludesk.macos.selfservice.plist" ]; then
	dialogIcon="$(getPref2 "photo")"
	
	if [ "$(getPref2 "isTeacher")" == true ]; then
		dialogOverlayIcon="$teacherIcon"
	else
		dialogOverlayIcon="$studentIcon"
	fi
	
else
	if [[ -d "$studentIcon" && -d "$teacherIcon" ]]; then
		dialogIcon="SF=graduationcap.circle.fill"
	elif [ -d "$studentIcon" ]; then 
		dialogIcon="$studentIcon"
	elif [ -d "$teacherIcon" ]; then  
		dialogIcon="$teacherIcon"
	else
		dialogIcon="SF=graduationcap.circle"
	fi
fi

# Swift Dialog configuration 
/usr/local/bin/dialog --title "Hello $(getPref "UsersFullName")" \
--message "These are the preferences read from the custom profile, which used the Jamf School variables  \n  \n **Device Name:** $(getPref "DeviceName")  \n **Device Groups:** $(getPref "DeviceGroups")  \n **User Groups:** $(getPref "UserGroup")  \n **User ID:** $(getPref "UserId")  \n **Username:** $(getPref "Username")  \n **User Email:** $(getPref "UserEmail")  \n **Managed Apple Account:** $(getPref "UserManagedAppleId")  \n **Asset Tag:** $(getPref "AssetTag")  \n  \n Jamf School Console details  \n  \n **School Name:** $(getPref "CompanyName")  \n **Jamf School ID:** $(getPref "CompanyID")  \n **Jamf School Location:** $(getPref "LocationName")  \n **Network ID:** $(getPref "NetworkID")  \n" \
--icon "$dialogIcon" \
--overlayicon "$dialogOverlayIcon" \
--big
