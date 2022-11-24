#!/bin/bash
# Author: Rojen Zaman <rojen@riseup.net>
# License: GPLv3
# Source Code: https://github.com/rojenzaman/google-translate-mp3-download
# Modified for ChildConsole
#
# Usage:
# $ download_for_your_language.sh -l en -f number-list.txt"

[ -x "$(command -v ffplay)" ] || { echo "ffplay not found, please install it." ; exit 1 ; }
[ -x "$(command -v wget)" ] || { echo "wget not found, please install it." ; exit 1 ; }

function guide() { echo -e "usage:\n  `basename $0` -l <lang-code> -f number-list.txt" ; }

urlencode() {
    # urlencode <string>
    #   * https://github.com/sixarm/urldecode.sh
    #
    # Command: urlencode
    # Version: 1.0.0
    # Created: 2016-09-12
    # Updated: 2016-09-12
    # License: MIT
    # Contact: Joel Parker Henderson (joel@joelparkerhenderson.com)

    old_lang=$LANG
    LANG=C
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LANG=$old_lang
    LC_COLLATE=$old_lc_collate
}

function forFile() {
rm *.mp3 &>/dev/null
while IFS='' read -r line || [[ -n "$line" ]]; do
    words=$(echo $line | tr "," "\n")
    echo "$words"
    for word in $words
    do
	en_char=$(urlencode "$word")
      	echo "> [$word]"
        url="http://translate.google.com/translate_tts?ie=UTF-8&total=1&idx=0&textlen=${#word}&client=tw-ob&q=$en_char&tl=$langCode"
        echo $url
        wget -q -U Mozilla -O $word.mp3 $url
    done
echo "for outputs look current folder"
done < "$fileName"
exit 0
}

while getopts ":l:f:" opt; do
  case ${opt} in
    l )
      langCode=${OPTARG};
      ;;
    f )
      fileName=${OPTARG};
      forFile
      ;;
    : )
      echo "Missing option argument for -$OPTARG"
      exit 0
      ;;
  esac
done

if [ "$#" -lt 1 ]; then
    guide
    exit 0
fi
