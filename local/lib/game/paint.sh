#!/bin/bash
#
#  Author: Martin "BruXy" Bruchanov, bruxy at regnet.cz
#

# Check input first
if [ ! $# -eq 1 ] || [ "$1" == "-h"] || [ "$1" == "--help" ] ; then
	printf "Usage:\n"	
	printf "\t$0 saved_image\n"
	printf "\n\tImage data will be saved into given filename, if file exist\n"
	printf "\tit will be displayed and ready to edit!\n"
    printf "\tHit <Ctrl-C> any time to quit the program.\n"
	exit 1
fi

##################
# Initialization #
##################

IMAGE_FILE=$1
_STTY=$(stty -g)    # Save current terminal setup
printf   "\e[2J"    # clear screen, set cursos at beginning
stty -echo -icanon  # Turn off line buffering
printf "\e[?9h"     # Enable terminal mouse reading
printf "\e[?25l"    # Turn of cursor 
printf "\e]0;-=[ ShPaint ]=-\007"

# Hash array with image data,
# ... key is "$Y;$X",
# ... value ANSI colors and brush "b;F;Bm█"
declare -A IMAGE  

# Defaults
BRUSHES=(░ ▒ ▓ █ ▄ ▌ ▐ ▀)
FG=( {30..37} )
BG=( {40..47} ) # 49 ... default background
X=0 
Y=0
ERASE=0
BRUSH=${BRUSHES[3]}
FG_COLOR="1;${FG[7]}"
BG_COLOR=49

#############
# Functions #
#############

function save_image() {
	printf "\e[2J" > $IMAGE_FILE
	for i in ${!IMAGE[@]}
	do
		printf "\e[${i}f\e[${IMAGE[$i]}\e[0m"
	done >> $IMAGE_FILE
	# set cursor under the image
	printf "\e[$(tput lines);1f" >> $IMAGE_FILE
}

function at_exit() {
	printf "\e[?9l"          # Turn off mouse reading
	printf "\e[?12l\e[?25h"  # Turn on cursor
	stty "$_STTY"            # reinitialize terminal settings
	clear
	echo "Thank for using ansipaint!"
	if [ ! -z "$IMAGE_FILE" ] ; then 
		echo "Your image is saved as '$IMAGE_FILE'."
		save_image
	fi
	exit
}

# X = $1, Y = $2
function set_pos() {
 	echo -en  "\e[$2;$1f"
}

function show_pos() {
	set_pos 65 1
	printf "x,y = %3d,%3d" $X $Y
}

function show_brush() {
	set_pos 70 2 
	printf "[ \e[${FG_COLOR};${BG_COLOR}m$BRUSH\e[0m ]"
}

function process_click() {
#	X=$1 Y=$2
	# set foreground color
	if [ $Y -eq 1 ] || [ $Y -eq 2 ] ; then
		if [ $X -gt 2 ] && [ $X -lt 28 ] ; then
			FG_COLOR="$[Y-1];${FG[$[(X-4)/3]]}"
			ERASE=0
		fi
	fi
	
	# set background color
	if [ $Y -eq 1 ] && [ $X -gt 34 ] ; then
		if [ $X -gt 34 ] && [ $X -lt 59 ] ; then
			BG_COLOR="${BG[$[X-35]/3]}"
			ERASE=0
		else
			BG_COLOR="49"
			ERASE=0
		fi
	fi	

	# set brush
	if [ $Y -eq 2 ] && [ $X -gt 36 ] && [ $X -le 51 ] ; then
		BRUSH=${BRUSHES[$[(X-37)/2]]}
		ERASE=0
	fi

	# set erase
	if [ $Y -eq 2 ] && [ $X -ge 54 ] && [ $X -le 62 ] ; then
		BRUSH=" "
		BG_COLOR="49"
		ERASE=1
	fi

	# DEBUG
	# set_pos 0 25
	# printf "$FG_COLOR $BG_COLOR $BRUSH"
}

function draw_menu() {
	set_pos 1 1; echo "FG: "
	for i in ${FG[*]}
	do
		set_pos $[(i-30)*3+4] 1
		echo -en "\e[${i}m███\e[0m"	
		set_pos $[(i-30)*3+4] 2
		echo -en "\e[1;${i}m███\e[0m"	
	done

	set_pos 30 1; echo "BG: "
	for i in ${BG[*]}
	do 
		set_pos $[(i-40)*3+35] 1
		echo -en "\e[${i}m   \e[0m"	
	done
	echo "   |" # default background (49)

	set_pos 30 2; echo -en "Brush: ${BRUSHES[*]}"
	printf "  [ Erase ]"
	show_brush
}

function load_image() {
	if [ -f $IMAGE_FILE ] ; then 
		data=$(sed -e 's/\x1b/E/g;s/E\[0m/\n/g;s/E\[2J//' $IMAGE_FILE | \
			sed -n -e 's/E\[\(.*\)fE\[\(.*m.\)/IMAGE["\1"]="\2"/ p')
		eval $data
		cat < $IMAGE_FILE
	fi
}

##########
#  MAIN  #
##########
trap at_exit ERR EXIT 
load_image
draw_menu
while :
do 
	read -N 6 click
	mouse=( `echo -en ${click#???} | hexdump -v  -e'1/1 " %u"'` )
	X=$[ ${mouse[0]} - 32]	Y=$[ ${mouse[1]} - 32]
	process_click
	show_pos 
	show_brush
	if [ $Y -gt 2 ] ; then	
		echo -en  "\e[${Y};${X}f\e[${FG_COLOR};${BG_COLOR}m$BRUSH\e[0m"
		if [ $ERASE -eq 0 ] ; then
			IMAGE["${Y};${X}"]="${FG_COLOR};${BG_COLOR}m$BRUSH"
		else
			unset IMAGE["${Y};${X}"]
		fi
	fi
done

