# #!/bin/bash
#VERSIONNUM=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${PROJECT_DIR}/${INFOPLIST_FILE}")
#SHORTVERSIONNUM=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${PROJECT_DIR}/${INFOPLIST_FILE}")
#NEWSUBVERSION=`echo $VERSIONNUM`
#NEWSUBVERSION=$(($NEWSUBVERSION + 1))
#/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEWSUBVERSION" "${PROJECT_DIR}/${INFOPLIST_FILE}"
#
#SETTINGSBUNDLEPATH="${PROJECT_DIR}/${PRODUCT_NAME}/Resources/Settings.bundle/Root.plist"
#key=1
#/usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:$key:DefaultValue '$SHORTVERSIONNUM ($NEWSUBVERSION)'" "$SETTINGSBUNDLEPATH"
