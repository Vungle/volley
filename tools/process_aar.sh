#!/bin/bash


if [ $# = 0 ] 
	then
	echo 'should pass tha aar dir'
	exit 1
fi

aar_dir=$1
jarjar=$(pwd)/jarjar-1.4.jar
rules_txt=$(pwd)/rules.txt
domain=vungle

pushd $aar_dir
aar_files=($(ls *release.aar 2>/dev/null))
aar_num=${#aar_files[@]}
if [ "$aar_num" = "0" ]; then
	echo "No aar files, something must be wrong, please check!"
	exit 2
fi

if [ "$aar_num" -gt "1" ]; then
	echo "More than one aar files, something must be wrong, please check!"
	exit 3
fi

aar="${aar_files[0]}"
unzip $aar
# manifest
sed -i '' "s/com.android.volley/com.${domain}.volley/g" AndroidManifest.xml
# proguard
sed -i '' "s/com.android.volley/com.${domain}.volley/g" proguard.txt
# annotations.zip
unzip annotations.zip
mv com/android com/$domain
sed -i '' "s/com.android.volley/com.${domain}.volley/g" com/$domain/volley/annotations.xml
rm -f annotations.zip && zip -r annotations.zip com && rm -rf com

# jar
java -jar $jarjar process $rules_txt classes.jar classes.jar

# zip
rm -rf $aar && zip $aar *

# cleanup
ls | grep -v $aar | xargs rm 
popd