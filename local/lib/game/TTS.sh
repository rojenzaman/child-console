#!/bin/bash
# Author: Rojen Zaman <rojen@riseup.net>
# License: GPLv3
# Source Code: https://github.com/rojenzaman/google-translate-mp3-download
# Modified for ChildConsole
#
# Usage:
# $ TTS.sh -l en -t "Hello World!"

[ -x "$(command -v ffplay)" ] || { echo "ffplay not found, please install it." ; exit 1 ; }
[ -x "$(command -v wget)" ] || { echo "wget not found, please install it." ; exit 1 ; }

function guide() { echo -e "usage:\n  `basename $0` -l <lang-code> -t \"write some text to here\" " ; exit 0 ; }

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

function forArgument() {
   savedFile=$(cat /dev/urandom | tr -dc 'a-e0-9' | fold -w 8 | head -n 1)
   echo "> [$String]"
   urlString=$(urlencode "$String")
   url="https://translate.google.com/translate_tts?ie=UTF-8&total=1&idx=0&textlen=${#word}&client=tw-ob&q=$urlString&tl=$langCode"
   echo $url
   wget -q -U Mozilla -O - $url | ffplay -nodisp -hide_banner -autoexit -
}

while getopts ":l:t:" opt; do
  case ${opt} in
    l )
      langCode=${OPTARG};
      ;;
    t )
      String=${OPTARG};
      forArgument
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
