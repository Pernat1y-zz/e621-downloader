#!/usr/bin/bash

# Home: https://github.com/Pernat1y/e621-downloader
# e621 API reference: https://e621.net/help/show/api

e621_tags=`echo $1 | sed 's/ /%20/g; s/</%3C/g; s/>/%3E/g'`
e621_page=1

if [ -z $1 ]; then
	echo "Usage: $0 tags"
	exit
fi

which curl jq >>/dev/null
if [ $? -ne "0" ]; then
	echo "I need curl ( https://curl.haxx.se ) and jq ( https://github.com/stedolan/jq ) to work"
	exit
fi

mkdir -p "$e621_tags" 2>/dev/null
cd "$e621_tags"
if [ $? -ne "0" ]; then
	echo "Unable to create/enter directory. Check free space and permissions on current directory."
	exit
fi



while true; do
  for e621_image_url in $(curl --silent --referer "https://e621.net" --user-agent "Mozilla/5.0" --retry 3 --retry-delay 3 \
      "https://e621.net/post/index.json?limit=320&page=$e621_page&tags=$e621_tags" | jq '.[] | .file_url'); do
	  e621_image_url=`echo $e621_image_url | sed 's/\"//g'`
    if [ -z $e621_image_url ]; then
      echo "Done."
      exit
    fi
	  echo "Downloading: $e621_image_url"
	  curl --silent --referer "https://e621.net" --user-agent "Mozilla/5.0" \
		  --continue-at - --remote-name --remote-name-all --retry 3 --retry-delay 3 $e621_image_url
  done
	e621_page=`expr $e621_page + 1`
done
