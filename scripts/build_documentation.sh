#!/bin/bash

# Copyright (C) 2005-2015 Alfresco Software Limited.
#
# This file is part of the Alfresco Mobile SDK.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

if ! which jazzy >/dev/null; then
echo "Could not find jazzy. Use \"[sudo] gem install jazzy\""
exit
fi

# -----------------------------------------------------------------------------
# Build documentation
#

SOURCE=ActivitiSDK
SOURCE_FILES=($(find ActivitiSDK/ -maxdepth 5 -type f -exec basename {} \;))
SOURCE_FILES_LOCATION=($(find ActivitiSDK/ -maxdepth 5 -type f))

for f in "${SOURCE_FILES_LOCATION[@]}"
do
cp $f $SOURCE
done

jazzy \
--clean \
--objc \
--author 'Alfresco' \
--author_url 'https://www.alfresco.com' \
--github_url 'https://github.com/Alfresco/activiti-ios' \
--sdk iphonesimulator \
--module 'ActivitiSDK' \
--framework-root . \
--umbrella-header ActivitiSDK/ActivitiSDK.h \
--hide-documentation-coverage \
--theme apple \
--readme README.md \
--output Help \
--exclude 'Pods/*'

cd $SOURCE

for f in  "${SOURCE_FILES[@]}"
do
if [[ $f != ActivitiSDK.h ]] &&
[[ $f != Info.plist ]] ;
then
rm $f
fi
done
