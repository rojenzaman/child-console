#!/bin/bash

script_dir="$(dirname "$(readlink -f "$0")")"
source "${script_dir}/local/etc/config.conf"
make check || exit 1

list_commands() {
	echo -e "\e[38;5;211m\c"
	ls -1 ${script_dir}/local/lib/ascii |  cut -f 1 -d '.'
	echo -e "\033\e[96m\c"
	ls -1 ${script_dir}/local/lib/vt |  cut -f 1 -d '.'
	echo -e "\033\e[93m\c"
	ls -1 ${script_dir}/local/lib/ansi |  cut -f 1 -d '.'
	echo -e "\e[0m\c"
}

list_games() {
	echo -e "\033\e[92m\c"
	cat <<EOT
__________________________________________________________________________
|          |        |      |       |       |        |       |     |        |
| housenka | matrix | nyan | paint | snake | tetris | speak | plc | number |
|__________|________|______|_______|_______|________|_______|_____|________|
EOT
	echo -e "\e[0m\c"
}

cc_help() { cat ${script_dir}/local/man/README ; }

ascii_interpreter() { cat ${script_dir}/local/lib/ascii/${upper_opt0}.ascii 2> /dev/null ; }

vt_interpreter() {
	pv_vt100() { cat ${script_dir}/local/lib/vt/${upper_opt0}.vt | pv -q -L ${pv_speed} ; }
	[[ -z "${opt1}" ]] || { pv_speed="${opt1}000" ; pv_vt100 ; return ; }
	[[ "${upper_opt0}" == "WRL" ]] && { pv_speed="50000"; pv_vt100 ; return ; }
	[[ "${upper_opt0}" == "TS" ]] && { pv_speed="50000" ; pv_vt100 ; return ; }
	[[ "${upper_opt0}" == "COW" ]] && { pv_speed="1900" ; pv_vt100 ; return ; }
	#vt100 emulator
	${script_dir}/local/bin/vt100emulator.pl ${script_dir}/local/lib/vt/${upper_opt0}.vt
}

ansi_interpreter() { cat ${script_dir}/local/lib/ansi/${upper_opt0}.ANS | iconv -f 437 ; tput init ; }

return_message() { cowsay "${input}" 2>/dev/null ; echo -e "\033[31minterpreter: \e[93m${upper_opt0}\033[31m: not found...\e[0m" ; }

get_art() {
[[ "${upt,,}" =~ ^(h|help|man|ls|list|l|c|clear|cls|sl|train|ascii|vt|ansi|q|quit|exit|p|print|printf|println|echo|message|msg|matrix|tetris|snake|nyan|paint|housenka|game|g|games|gamelist|gamels|gls|alpha|alphabet|abc|s|speak|playabc|plc|ply|number|numbers|nmr)$ ]] && { echo "command exist!" ; return ; }
	[[ "${lower_opt0}" == "ascii" ]] && [[ "${url}" =~ ^(stdin|STDIN)$ ]] && {
		[[ -f "${script_dir}/local/lib/ascii/${upt}.ascii" ]] || [[ -f "${script_dir}/local/lib/vt/${upt}.vt" ]] || [[ -f "${script_dir}/local/lib/ansi/${upt}.ANS" ]] && { echo "file exist!" ; return ; }
		echo -e "paste ascii art\nMissing [CTRL+D] for exit from stdin\n"
		stdText=$(</dev/stdin)
		echo "$stdText" >> ${script_dir}/local/lib/ascii/${upt}.ascii
		return
		}
	url_regex='(https?|http|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
	[[ -z "${upt}" ]] &&  { echo "file name not given!" ; }
	[[ "${url}" =~ ${url_regex} ]] || { echo "invalid url" ; return ; }
	[[ -f "${script_dir}/local/lib/ascii/${upt}.ascii" ]] || [[ -f "${script_dir}/local/lib/vt/${upt}.vt" ]] || [[ -f "${script_dir}/local/lib/ansi/${upt}.ANS" ]] && { echo "file exist!" ; return ; }
	[[ "${lower_opt0}" == "ascii" ]] && { curl -s -o ${script_dir}/local/lib/ascii/${upt}.ascii "${url}" ; return ; }
	[[ "${lower_opt0}" == "vt"  ]] && { curl -s -o ${script_dir}/local/lib/vt/${upt}.vt "${url}" ; return ; }
	[[ "${lower_opt0}" == "ansi"  ]] && { curl -s -o ${script_dir}/local/lib/ansi/${upt}.ANS "${url}" ; return ; }
}

alpha() { trap 'break' INT; while true; do read -rsn1 input; toilet -f smmono9 --filter gay "${input}" ; done; trap INT ; }

playabc() {
	mp3_files=${script_dir}/local/lib/alphabet/*.mp3
	trap 'break' INT;
	for i in ${mp3_files}; do
		clear
		base_file=$(basename ${i})
		char=$(echo "$base_file" | cut -f 1 -d '.')
		toilet "$char"
		echo -e "\n$char"
		ffplay -nodisp -hide_banner -autoexit "${i}" &>/dev/null
		read
	done
	trap INT
}

number() {
	mp3_files=$(find numbers/ -name "*.mp3" -exec readlink -f {} \; | xargs echo -n)
	echo "${mp3_files}"
	read
	trap 'break' INT;
	for i in ${mp3_files}; do
		clear
		base_file=$(basename "${i}")
		char=$(echo "$base_file" | cut -f 1 -d '.')
		toilet "$char"
		echo -e "\n$char"
		ffplay -nodisp -hide_banner -autoexit "${i}" &>/dev/null
		read
	done
	trap INT
}

# start message
clear
toilet -f smblock --filter border:metal 'ChildConsole'
cat <<EOT
Welcome to Child Console!
 Type ls to list art commands (ls,l)
 Type help to available function and commands (h)
 Type game to list available games (gls,g)
 Type clear to clean the console (c)
 Press [CTRL+C] to exit.

EOT

# while loop foor console promt
while :
do
read -p "ChildConsole> " input
[[ -z "${input}" ]] && continue
IFS=' '
read -ra input_parse <<<"${input}"
opt0="${input_parse[0]}"
opt1="${input_parse[1]}"
url="${input_parse[2]}"
upper_opt0="${opt0^^}"
lower_opt0="${opt0,,}"
pure_opt1=$(echo "${opt1}" | sed 's/[^a-zA-Z0-9]//g') ; upt="${pure_opt1}^^}"
message=$(echo "${input}" | sed "s/^[^ ]* //" | tr -d '"')
case ${lower_opt0} in
	ls|list|l) list_commands | paste - -; continue ;;
	c|clear|cls) clear; continue ;;
	sl|train) sl; continue ;;
	ascii|vt|ansi) get_art; continue ;;
	q|quit|exit) break ;;
	p|print|printf|println|echo|message|msg) toilet -f smblock "${message}" | lolcat ; continue ;;
	matrix) ${script_dir}/local/lib/game/matrix.sh ; continue ;;
	tetris) ${script_dir}/local/lib/game/tetris.sh ; continue ;;
	snake) ${script_dir}/local/lib/game/snake.sh ; continue ;;
	nyan) ${script_dir}/local/lib/game/nyan.sh ; continue ;;
	paint) ${script_dir}/local/lib/game/paint.sh "$(mktemp)" ; continue ;;
	housenka) ${script_dir}/local/lib/game/housenka.sh ; continue ;;
	s|speak) ${script_dir}/local/lib/game/TTS.sh -l "${lang}" -t "${message}" ; continue ;;
	game|g|games|gamelist|gamels|gls) list_games ; continue ;;
	alpha|alphabet|abc) alpha ; continue ;;
	playabc|plc|ply) playabc ; continue ;;
	number|numbers|nmr) number ; continue ;;
	h|help|man) cc_help | more ; continue ;;
esac
[[ -f "${script_dir}/local/lib/ascii/${upper_opt0}.ascii" ]] && { ascii_interpreter ; continue ; } || {
[[ -f "${script_dir}/local/lib/vt/${upper_opt0}.vt" ]] && { vt_interpreter ; continue ; } || {
[[ -f "${script_dir}/local/lib/ansi/${upper_opt0}.ANS" ]] && { ansi_interpreter ; continue ; } ; } ; return_message ; }
done

echo "by!"
