#!/bin/bash
# Source: https://gist.github.com/dhaiducek/174cdb04a5a51f016c6ca69ece721b17
# Author: Dale Haiducek <Red Hat>

trap '' 2				# disable CTRL+C for ChildConsole

lines=$(tput lines)
cols=$(tput cols)

awkscript='
  {
    lines=$1
    random_col=$3
    letter=$4
    cols[random_col]=0;
    for (col in cols) {
      rnum = int(20*rand());
      if (cols[col] < 0) {
        line=-cols[col];
        cols[col]=cols[col]-1;
        subline = -cols[col] + 1
        printf "\033[%s;%sH%s", line, col, " ";
        printf "\033[%s;%sH%s\033[0;0H", newline, col, " ";
        if (actcol >= lines) {
          cols[col]=0;
        } else if (rnum < 1) {
          cols[col]=0
        }
      } else {
        line=cols[col];
        cols[col]=cols[col]+1;
        if (rnum < 3) {
          printf "\033[%s;%sH\033[1;32m%s\033[0m", line, col, letter;
        } else {
          printf "\033[%s;%sH\033[2;32m%s\033[0m", line, col, letter;
        }
        printf "\033[%s;%sH\033[37m%s\033[0;0H\033[0m", cols[col], col, letter;
        if (cols[col] >= lines) {
          if (rnum < 2) {
            cols[col]=0
          } else {
            cols[col]=-1;
          }
        }
      }
    }
  }
'

echo -e "\e[1;40m"
clear

if [[ -t 0 ]]; then
  stty -echo -icanon -icrnl time 0 min 0;
fi

keypress=''
while [ "x$keypress" = "x" ]; do
  echo $lines $cols $(( $RANDOM % $cols)) $(( $RANDOM % 2 ))
  sleep 0.04
  keypress="`cat -v`"
done | awk "$awkscript"

if [[ -t 0 ]]; then
  stty sane;
fi

clear

trap 2
