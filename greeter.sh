#!/bin/bash


#!/bin/bash
##	USAGE
##	=====
##
##	Formating a text directly:
##		FORMATTED_TEXT=$(formatText "Hi!" -c red -b 13 -e bold)
##		echo -e "$FORMATTED_TEXT"
##
##	Getting the control sequences:
##		FORMAT=$(getFormatCode -c blue -b yellow -e bold -e blink)
##		NONE=$(getFormatCode -e none)
##		echo -e $FORMAT"Hello"$NONE
##
##	Options (More than one code may be specified)
##	-c	color name or 256bit code for font face
##	-b	background color name or 256bit code
##	-e	effect name (e.g. bold, blink, etc.)
##
##
##
##
##
##	BASH TEXT FORMATING
##	===================
##
##	Colors and text formatting can be achieved by preceding the text
##	with an escape sequence. An escape sequence starts with an <ESC>
##	character (commonly \e[), followed by one or more formatting codes
##	(its possible) to apply more that one color/effect at a time),
##	and finished by a lower case m. For example, the formatting code 1 
##	tells the terminal to print the text bold face. This is acchieved as:
##		\e[1m Hello World!
##
##	But if nothing else is specified, then eveything that may be printed
##	after 'Hello world!' will be bold face as well. The code 0 is thus
##	meant to remove all formating from the text and return to normal:
##		\e[1m Hello World! \e[0m
##
##	It's also possible to paint the text in color (codes 30 to 37 and
##	codes 90 to 97), or its background (codes 40 to 47 and 100 to 107).
##	Red has code 31:
##		\e[31m Hello World! \e[0m
##
##	More than one code can be applied at a time. Codes are separated by
##	semicolons. For example, code 31 paints the text in red. Thus,
##	the following would print in red bold face:
##		\e[1;31m Hello World! \e[0m
##
##	Some formatting sequences are, in fact, comprised of two codes
##	that must go together. For example, the code 38;5; tells the terminal
##	that the next code (after the semicolon) should be interpreted as
##	a 256 bit formatting color. So, for example, the code 82 is a light
##	green. We can paint the text using this code as follows, plus bold
##	face as follows - but notice that not all terminal support 256 colors:##
##		\e[1;38;5;82m Hello World! \e[0m
##
##	For a detailed list of all codes, this site has an excellent guide:
##	https://misc.flogisoft.com/bash/tip_colors_and_formatting
##
##
##
##
##
##	TODO: When requesting an 8 bit colorcode, detect if terminal supports
##	256 bits, and return appropriate code instead
##
##	TODO: Improve this description/manual text
##
##	TODO: Currently, if only one parameter is passed, its treated as a
##	color. Addsupport to also detect whether its an effect code.
##		Now: getFormatCode blue == getFormatCode -c blue
##		Add: getFormatCode bold == getFormatCode -e bold
##
##	TODO: Clean up this script. Prevent functions like "get8bitCode()"
##	to be accessible from outside. These are only a "helper" function
##	that should only be available to this script
##
##==============================================================================
##	CODE PARSERS
##==============================================================================
##------------------------------------------------------------------------------
##
get8bitCode()
{
	CODE=$1
	case $CODE in
		default)
			echo 9
			;;
		none)
			echo 9
			;;
		black)
			echo 0
			;;
		red)
			echo 1
			;;
		green)
			echo 2
			;;
		yellow)
			echo 3
			;;
		blue)
			echo 4
			;;
		magenta|purple|pink)
			echo 5
			;;
		cyan)
			echo 6
			;;
		light-gray)
			echo 7
			;;
		dark-gray)
			echo 60
			;;
		light-red)
			echo 61
			;;
		light-green)
			echo 62
			;;
		light-yellow)
			echo 63
			;;
		light-blue)
			echo 64
			;;
		light-magenta)
			echo 65
			;;
		light-cyan)
			echo 66
			;;
		white)
			echo 67
			;;
		*)
			echo 0
	esac
}
##------------------------------------------------------------------------------
##
getColorCode()
{
	COLOR=$1
	## Check if color is a 256-color code
	if [ $COLOR -eq $COLOR ] 2> /dev/null; then
		if [ $COLOR -gt 0 -a $COLOR -lt 256 ]; then
			echo "38;5;$COLOR"
		else
			echo 0
		fi
	## Or if color key-workd
	else
		BITCODE=$(get8bitCode $COLOR)
		COLORCODE=$(($BITCODE + 30))
		echo $COLORCODE
	fi
}
##------------------------------------------------------------------------------
##
getBackgroundCode()
{
	COLOR=$1
	## Check if color is a 256-color code
	if [ $COLOR -eq $COLOR ] 2> /dev/null; then
		if [ $COLOR -gt 0 -a $COLOR -lt 256 ]; then
			echo "48;5;$COLOR"
		else
			echo 0
		fi
	## Or if color key-workd
	else
		BITCODE=$(get8bitCode $COLOR)
		COLORCODE=$(($BITCODE + 40))
		echo $COLORCODE
	fi
}
##------------------------------------------------------------------------------
##
getEffectCode()
{
	EFFECT=$1
	NONE=0
	case $EFFECT in
	none)
		echo $NONE
		;;
	default)
		echo $NONE
		;;
	bold)
		echo 1
		;;
	bright)
		echo 1
		;;
	dim)
		echo 2
		;;
	underline)
		echo 4
		;;
	blink)
		echo 5
		;;
	reverse)
		echo 7
		;;
	hidden)
		echo 8
		;;
	strikeout)
		echo 9
		;;
	*)
		echo $NONE
	esac
}
##------------------------------------------------------------------------------
##
getFormattingSequence()
{
	START='\e[0;'
	MIDLE=$1
	END='m'
	echo -n "$START$MIDLE$END"
}
##==============================================================================
##	AUX
##==============================================================================
applyCodeToText()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	TEXT=$1
	CODE=$2
	echo -n "$CODE$TEXT$RESET"
}
##==============================================================================
##	MAIN FUNCTIONS
##==============================================================================
##------------------------------------------------------------------------------
##
getFormatCode()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	## NO ARGUMENT PROVIDED
	if [ "$#" -eq 0 ]; then
		echo -n "$RESET"
	## 1 ARGUMENT -> ASSUME TEXT COLOR
	elif [ "$#" -eq 1 ]; then
		TEXT_COLOR=$(getFormattingSequence $(getColorCode $1))
		echo -n "$TEXT_COLOR"
	## ARGUMENTS PROVIDED
	else
		FORMAT=""
		while [ "$1" != "" ]; do
			## PROCESS ARGUMENTS
			TYPE=$1
			ARGUMENT=$2
			case $TYPE in
			-c)
				CODE=$(getColorCode $ARGUMENT)
				;;
			-b)
				CODE=$(getBackgroundCode $ARGUMENT)
				;;
			-e)
				CODE=$(getEffectCode $ARGUMENT)
				;;
			*)
				CODE=""
			esac
			## ADD CODE SEPARATOR IF NEEDED
			if [ "$FORMAT" != "" ]; then
				FORMAT="$FORMAT;"
			fi
			## APPEND CODE
			FORMAT="$FORMAT$CODE"
			# Remove arguments from stack
			shift
			shift
		done
		## APPLY FORMAT TO TEXT
		FORMAT_CODE=$(getFormattingSequence $FORMAT)
		echo -n "${FORMAT_CODE}"
	fi
}
##------------------------------------------------------------------------------
##
formatText()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	## NO ARGUMENT PROVIDED
	if [ "$#" -eq 0 ]; then
		echo -n "${RESET}"
	## ONLY A STRING PROVIDED -> Append reset sequence
	elif [ "$#" -eq 1 ]; then
		TEXT=$1
		echo -n "${TEXT}${RESET}"
	## ARGUMENTS PROVIDED
	else
		TEXT=$1
		FORMAT_CODE=$(getFormatCode "${@:2}")
		applyCodeToText "$TEXT" "$FORMAT_CODE"
	fi
}
##------------------------------------------------------------------------------
##
removeColorCodes()
{
	printf "$1" | sed 's/\x1b\[[0-9;]*m//g'
}
##==============================================================================
##	DEBUG
##==============================================================================
#formatText "$@"
#FORMATTED_TEXT=$(formatText "HELLO WORLD!!" -c red -b 13 -e bold -e blink -e strikeout)
#echo -e "$FORMATTED_TEXT"
#FORMAT=$(getFormatCode -c blue -b yellow)
#NONE=$(getFormatCode -e none)
#echo -e $FORMAT"Hello"$NONE
#!/bin/bash
##==============================================================================
##	TERMINAL CURSOR
##==============================================================================
enableTerminalLineWrap()
{
	printf '\e[?7h'
}
disableTerminalLineWrap()
{
	printf '\e[?7l'
}
saveCursorPosition()
{
	printf "\e[s"
}
moveCursorToSavedPosition()
{
	printf "\e[u"
}
moveCursorToRowCol()
{
	local row=$1
	local col=$2
	printf "\e[${row};${col}H"
}
moveCursorHome()
{
	printf "\e[;H"
}
moveCursorUp()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1A"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}A"
	fi
}
moveCursorDown()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1B"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}B"
	fi
}
moveCursorRight()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1C"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}D"
	fi
}
moveCursorLeft()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1D"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}C"
	fi
}
##==============================================================================
##	FUNCTIONS
##==============================================================================
##------------------------------------------------------------------------------
##
getTerminalNumRows()
{
	tput lines
}
##------------------------------------------------------------------------------
##
getTerminalNumCols()
{
	tput cols
}
##------------------------------------------------------------------------------
##
getTextNumRows()
{
	## COUNT ROWS
	local rows=$(echo -e "$1" | wc -l )
	echo "$rows"
}
##------------------------------------------------------------------------------
##
getTextNumCols()
{
	## COUNT COLUMNS - Remove color sequences before counting
	## 's/\x1b\[[0-9;]*m//g' to remove formatting sequences (\e=\033=\x1b)
	local columns=$(echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g' | wc -L )
	echo "$columns"
}
##------------------------------------------------------------------------------
##
getTextShape()
{
	echo "$(getTextNumRows) $(getTextNumCols)"
}
##------------------------------------------------------------------------------
##
printWithOffset()
{
	local row=$1
	local col=$2
	local text=${@:3}
	## MOVE CURSOR TO TARGET ROW
	moveCursorDown "$row"
	## EDIT TEXT TO PRINT IN CORRECT COLUMN
	## If spacer is 1 column or more
	## - Add spacer at the start of the text
	## - Add spacer after each line break
	## Otherwise, do not alter the text
	if [ $col -gt 0 ]; then
		col_spacer="\\\\e[${col}C"
		local text=$(echo "$text" |\
		             sed "s/^/$col_spacer/g;s/\\\\n/\\\\n$col_spacer/g")
	fi
	## PRINT TEXT WITHOUT LINE WRAP
	disableTerminalLineWrap
	echo -e "${text}"
	enableTerminalLineWrap
}
##------------------------------------------------------------------------------
##
printTwoElementsSideBySide()
{
	## GET ELEMENTS TO PRINT
	local element_1=$1
	local element_2=$2
	local print_cols_max=$3
	## GET PRINTABLE AREA SIZE
	## If print_cols_max specified, then keep the smaller between it and
	## the current terminal width
	local term_cols=$(getTerminalNumCols)
	if [ ! -z "$print_cols_max" ]; then
		local term_cols=$(( ( $term_cols > $print_cols_max ) ?\
			$print_cols_max : $term_cols ))
	fi
	## GET ELEMENT SHAPES
	local e_1_cols=$(getTextNumCols "$element_1")
	local e_1_rows=$(getTextNumRows "$element_1")
	local e_2_cols=$(getTextNumCols "$element_2")
	local e_2_rows=$(getTextNumRows "$element_2")
	## COMPUTE OPTIMAL HORIZONTAL PADDING
	local free_cols=$(( $term_cols - $e_1_cols - $e_2_cols ))
	if [ $free_cols -lt 1 ]; then
		local free_cols=0
	fi
	if [ $e_1_cols -gt 0 ] && [ $e_2_cols -gt 0 ]; then
		local h_pad=$(( $free_cols/3 ))
		local e_1_h_pad=$h_pad
		local e_2_h_pad=$(( $e_1_cols + 2*$h_pad ))
	elif  [ $e_1_cols -gt 0 ]; then
		local h_pad=$(( $free_cols/2 ))
		local e_1_h_pad=$h_pad
		local e_2_h_pad=0
	elif  [ $e_2_cols -gt 0 ]; then
		local h_pad=$(( $free_cols/2 ))
		local e_1_h_pad=0
		local e_2_h_pad=$h_pad
	else
		local e_1_h_pad=0
		local e_2_h_pad=0
	fi
	## COMPUTE OPTIMAL VERTICAL PADDING
	local e_1_v_pad=$(( ( $e_1_rows > $e_2_rows ) ?\
		0 : (( ($e_2_rows - $e_1_rows)/2 )) ))
	local e_2_v_pad=$(( ( $e_2_rows > $e_1_rows ) ?\
		0 : (( ($e_1_rows - $e_2_rows)/2 )) ))
	local max_rows=$(( ( $e_1_rows > $e_2_rows ) ? $e_1_rows : $e_2_rows ))
	## CLEAN PRINTING AREA
	for i in `seq $max_rows`; do printf "\n"; done
	moveCursorUp $max_rows
	saveCursorPosition
	printWithOffset $e_1_v_pad $e_1_h_pad "$element_1"
	moveCursorToSavedPosition
	printWithOffset $e_2_v_pad $e_2_h_pad "$element_2"
	moveCursorToSavedPosition
	## LEAVE CURSOR AT "SAFE" POSITION	
	moveCursorDown $(( $max_rows ))
}
#!/bin/bash
##==============================================================================
##	printBar
##	Prints a bar that is filled depending on the relation between
##	CURRENT and MAX. Example: [|||||    ]
##
##
##	Arguments:
##	1. CURRENT:       amount to display on the bar.
##	2. MAX:           amount that means that the bar should be printed
##	                  completely full.
##	3. SIZE:          length of the bar as number of characters.
##
##
##	Optional arguments:
##	4. BRACKET_CHAR_L: left bracket character. Defaults to '['
##	5. BAR_FILL_CHAR:  bar character. Defaults to '|'
##	6. BAR_EMPTY_CHAR: bar background. Defaults to ' '
##	7. BRACKET_CHAR_R: left bracket character. Defaults to ']'
##
printBar()
{
	## ARGUMENTS
	local current=$1
	local max=$2
	local size=$3
	local bracket_char_l=${4:-'['}
	local bar_fill_char=${5:-'|'}
	local bar_empty_char=${6:-' '}
	local bracket_char_r=${7:-']'}
	## COMPUTE VARIABLES
	## Clamp to maximum
	local num_bars=$(bc <<< "$size * $current / $max")
	if [ $num_bars -gt $size ]; then
		num_bars=$size
	fi
	## PRINT BAR
	## - Opening bracket
	## - Fill bars
	## - Remaining empty background
	## - Closing bracket
	printf "$bracket_char_l"
	i=0
	while [ $i -lt $num_bars ]; do
		printf "$bar_fill_char"
		i=$[$i+1]
	done
	while [ $i -lt $size ]; do
		printf "$bar_empty_char"
		i=$[$i+1]
	done
	printf "$bracket_char_r"
}
#!/bin/bash
assert_is_set()
{
	local ok=0
	local assert_failed=98
	if [ -z ${1+x} ]; then 
		echo "Assertion failed, variable not set."
		return $assert_failed
	else
		return $ok
	fi
}
##==============================================================================
##
##
assert_not_empty()
{
	local ok=0
	local assert_failed=98
	local variable=$1
	if [ -z $variable ]; then 
		echo "Assertion failed, variable empty. $message"
		return $assert_failed
	else
		return $ok
	fi
}
##==============================================================================
##
##
assert_empty()
{
	local ok=0
	local assert_failed=98
	assert_is_set $1
	local variable=$1
	if [ -n $variable ]; then 
		echo "Assertion failed, variable empty. $message"
		return $assert_failed
	else
		return $ok
	fi
}
#!/bin/bash
##==============================================================================
##	EXTERNAL DEPENDENCIES
##==============================================================================
[ "$(type -t include)" != 'function' ]&&{ include(){ { [ -z "$_IR" ]&&_IR="$PWD"&&cd $(dirname "${BASH_SOURCE[0]}")&&include "$1"&&cd "$_IR"&&unset _IR;}||{ local d=$PWD&&cd "$(dirname "$PWD/$1")"&&. "$(basename "$1")"&&cd "$d";}||{ echo "Include failed $PWD->$1"&&exit 1;};};}
##==============================================================================
##	HELPERS
##==============================================================================
##==============================================================================
##	_getStateColor()
##	Select color formating code according to state:
##	nominal/critical/error
##
_getStateColor()
{
	assert_is_set $fc_ok
	assert_is_set $fc_info
	assert_is_set $fc_deco
	assert_is_set $fc_crit
	assert_is_set $fc_error
	local state=$1
	local E_PARAM_ERR=98
	local fc_none="\e[0m"
	case $state in
		nominal)	echo $fc_ok ;;
		critical)	echo $fc_crit ;;
		error)		echo $fc_error ;;
		*)		echo $fc_none ; exit $E_PARAM_ERR
	esac
}
##==============================================================================
##	FUNCTIONS
##==============================================================================
##==============================================================================
##	printInfoLine()
##	Print a formatted message comprised of a label and a value
##
##	Arguments:
##	1. LABEL
##	2. VALUE
##
##	Optional arguments:
##	3. STATE	Determines the color (nominal/critical/error)
##
printInfoLine()
{
	assert_is_set $info_label_width
	## ARGUMENTS
	local label=$1
	local value=$2
	local state=${3:-nominal}
	## FORMAT
	local fc_label=${fc_info}
	local fc_value=$(_getStateColor $state)
	local fc_none="\e[0m"
	local padding_label=$info_label_width
	## PRINT LABEL AND VALUE
	printf "${fc_label}%-${padding_label}s${fc_value}${value}${fc_none}\n" "$label"
}
##==============================================================================
##	printMonitor()
##
##	Prints a resource utilization monitor, comprised of a bar and a fraction.
##
##	1. CURRENT: current resource utilization (e.g. occupied GB in HDD)
##	2. MAX: max resource utilization (e.g. HDD size)
##	3. CRIT_PERCENT: point at which to warn the user (e.g. 80 for 80%)
##	4. PRINT_AS_PERCENTAGE: whether to print a simple percentage after
##	   the utilization bar (true), or to print a fraction (false).
##	5. UNITS: units of the resource, for display purposes only. This are
##	   not shown if PRINT_AS_PERCENTAGE=true, but must be set nonetheless.
##	6. LABEL: A description of the resource that will be printed in front
##	   of the utilization bar.
##
printInfoMonitor()
{
	assert_is_set $info_label_width
	assert_is_set $bar_num_digits
	assert_is_set $bar_length
	assert_is_set $bar_padding_after
	## ARGUMENTS
	local label=$1
	local value=$2
	local max=$3
	local units=$4
	local format=${5:-fraction}
	local state=${6:-nominal}	
	## FORMAT OPTIONS
	local fc_label=${fc_info}
	local fc_value=$(_getStateColor $state)
	local fc_units=$fc_info
	local fc_fill_color=$fc_value
	local fc_bracket_color=$fc_deco
	local fc_none="\e[0m"
	local padding_label=$info_label_width
	local padding_value=$bar_num_digits
	local padding_bar=$bar_padding_after
	## COMPOSE CHARACTERS FOR BAR
	local bracket_left=$fc_bracket_color$bar_bracket_char_left
	local fill=$fc_fill_color$bar_fill_char
	local background=$fc_none$bar_background_char
	local bracket_right=$fc_bracket_color$bar_bracket_char_right$fc_none
	## PRINT LABEL
	printf "${fc_label}%-${padding_label}s" "$label"
	## PRINT BAR
	printBar "$value" "$max" "$bar_length" \
	         "$bracket_left" "$fill" "$background" "$bracket_right"
	printf "%${bar_padding_after}s" ""
	## PRINT VALUE
	case $format in
		"a/b")	
			printf "${fc_value}%${padding_value}s" $value
			printf "${fc_deco}/"
			printf "${fc_value}%-${padding_value}s" $max
			printf "${fc_units} ${units}${fc_none}"
			;;
		'0/0')		
			if [ -z $(which 'bc' 2>/dev/null) ]; then
				printf "${fc_error} bc not installed${fc_none}"
			else
				local percent=$('bc' <<< "$value*100/$max")
				printf "${fc_value}%${padding_value}s${fc_units}%%%%${fc_none}" $percent
			fi
			;;
		*)	
			echo "Invalid format option $format"
	esac
}
#!/bin/bash
##==============================================================================
##
getNameOS()
{
	if   [ -f /etc/os-release ]; then
		local os_name=$(sed -En 's/PRETTY_NAME="(.*)"/\1/p' /etc/os-release)
	elif [ -f /usr/lib/os-release ]; then
		local os_name=$(sed -En 's/PRETTY_NAME="(.*)"/\1/p' /usr/lib/os-release)
	else
		local os_name=$(uname -sr)
	fi
	printf "$os_name"
}
##==============================================================================
##
getNameKernel()
{
	local kernel=$(uname -r)
	printf "$kernel"
}
##==============================================================================
##
getNameShell()
{
	local shell=$(readlink /proc/$$/exe)
	printf "$shell"
}
##==============================================================================
##
getDate()
{
	local sys_date=$(date +"$date_format")
	printf "$sys_date"
}
##==============================================================================
##
getUptime() 
{
#	local uptime=$(uptime -p | sed 's/^[^,]*up *//g;
#		                        s/s//g;
#		                        s/ year/y/g;
#		                        s/ month/m/g;
#		                        s/ week/w/g;
#		                        s/ day/d/g;
#		                        s/ hour, /:/g;
#		                        s/ minute//g')
	local uptime=$(uptime | sed 's/^[^,]*up *//g;
	                             s/,.*$/ hours/g')
	printf "$uptime"
}
##==============================================================================
##
getUserHost()
{
	printf "$USER@$HOSTNAME"
}
##==============================================================================
##
getNumberLoggedInUsers()
{
	## -n	silent
	## 	replace everything with content of the group inside \( \)
	## p	print
	num_users=$(uptime |\
	            sed -n 's/.*\([[0-9:]]* users\).*/\1/p')
	printf "$num_users"
}
##==============================================================================
##
getNameLoggedInUsers()
{
	## who			See who is logged in
	## awk '{print $1;}'	First word of each line
	## sort -u		Sort and remove duplicates
	local name_users=$(who | awk '{print $1;}' | sort -u)
	printf "$name_users"
}
#!/bin/bash
##==============================================================================
##
getNameCPU()
{
	## Get first instance of "model name" in /proc/cpuinfo, pipe into 'sed'
	## s/model name\s*:\s*//  remove "model name : " and accompanying spaces
	## s/\s*@.*//             remove anything from "@" onwards
	## s/(R)//                remove "(R)"
	## s/(TM)//               remove "(TM)"
	## s/CPU//                remove "CPU"
	## s/\s\s\+/ /            clean up double spaces (replace by single space)
	## p                      print final output
	local cpu=$(grep -m 1 "model name" /proc/cpuinfo |\
	            sed -n 's/model name\s*:\s*//;
	                    s/\s*@.*//;
	                    s/(R)//;
	                    s/(TM)//;
	                    s/CPU//;
	                    s/\s\s\+/ /;
	                    p')
	printf "$cpu"
}
##==============================================================================
##
##==============================================================================
##
getCPULoad()
{
	local avg_load=$(uptime | sed 's/^.*load average: //g')	
	printf "$avg_load"
}
#!/bin/bash
##==============================================================================
##
##	getLocalIPv6()
##
##	Looks up and returns local IPv6-address.
##	Test for the presence of several programs in case one is missing.
##	Program search ordering is based on timed tests, fastest to slowest.
##
##	!!! NOTE: Still need to figure out how to look for IP address that
##	!!!       have a default gateway attached to related interface,
##	!!!       otherwise this returns a list of IPv6's if there are many.
##
getLocalIPv6()
{
	## GREP REGGEX EXPRESSION TO RETRIEVE IP STRINGS
	##
	## The following string is intuitive and easy to read, but only parses
	## strings that look like IPs without checking their value. For instance,
	## it does NOT check value ranges of IPv6
	##
	## grep explanation:
	## -oP				only return matching parts of a line, and use perl regex
	## \s*inet6\s+			any-spaces "inet6" at-least-1-space
	## (addr:?\s*)?			optionally, followed by addr or addr:
	## \K				everything until here, omit
	## (){1,8}			repeat block at least 1 time, up to 8
	## ([0-9abcdef]){0,4}:*		up to 4 chars from [] followed by :
	##
	#local grep_reggex='\s*inet6\s+(addr:?\s*)?\K(([0-9abcdef]){0,4}:*){1,8}'
	##
	## The following string, on the other hand, is harder to read and
	## understand, but is MUCH safer, as it ensures that the IP
	## fulfills some criteria.
	local grep_reggex='^\s*inet6\s+(addr:?\s*)?\K((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?'
	if   ( which ip > /dev/null 2>&1 ); then
		local result=$($(which ip) -family inet6 addr show |\
		grep -oP "$grep_reggex" |\
		sed '/::1/d;:a;N;$!ba;s/\n/,/g')
	elif ( which ifconfig > /dev/null 2>&1 ); then
		local result=$($(which ifconfig) |\
		grep -oP "$grep_reggex" |\
		sed '/::1/d;:a;N;$!ba;s/\n/,/g')
	else
		local result="Error"
	fi
	## Returns "N/A" if actual query result is empty,
	## and returns "Error" if no programs found
	[ $result ] && printf $result || printf "N/A"
}
##==============================================================================
##
##	getExternalIPv6()
##
##	Makes an query to internet-server and returns public IPv6-address.
##	Tests for the presence of several programs in case one is missing.
##	Program search ordering is based on timed tests, fastest to slowest.
##	DNS-based queries are always faster, ~0.1 seconds.
##	URL-queries are relatively slow, ~1 seconds.
##
getExternalIPv6()
{
	if   ( which dig > /dev/null 2>&1 ); then
		local result=$($(which dig) TXT -6 +short o-o.myaddr.l.google.com @ns1.google.com |\
		               awk -F\" '{print $2}')
	elif ( which nslookup > /dev/nul 2>&1 ); then
		local result=$($(which nslookup) -q=txt o-o.myaddr.l.google.com 2001:4860:4802:32::a |\
		               awk -F \" 'BEGIN{RS="\r\n"}{print $2}END{RS="\r\n"}')
	elif ( which curl > /dev/null 2>&1 ); then
		local result=$($(which curl) -s https://api6.ipify.org)
	elif ( which wget > /dev/null 2>&1 ); then
		local result=$($(which wget) -q -O - https://api6.ipify.org)
	else
		local result="Error"
	fi
	## Returns "N/A" if actual query result is empty,
	## and returns "Error" if no programs found
	[ $result ] && printf $result || printf "N/A"
}
##==============================================================================
##
##	getLocalIPv4()
##
##	Looks up and returns local IPv4-address.
##	Tries first program found.
##	!!! NOTE: Still needs to figure out how to look for IP address that
##	!!!       have a default gateway attached to related interface,
##	!!!       otherwise this returns list of IPv4's if there are many
##
getLocalIPv4()
{
	## GREP REGEX EXPRESSION TO RETRIEVE IP STRINGS
	##
	## The following string is intuitive and easy to read, but only parses
	## strings that look like IPs, without checking their value. For instance,
	## it does NOT check whether the IP bytes are [0-255], rather it
	## accepts values from [0-999] as valid.
	##
	## grep explanation:
	## -oP				only return matching parts of a line, and use perl regex
	## \s*inet\s+			any-spaces "inet6" at-least-1-space
	## (addr:?\s*)?			optionally, followed by addr or addr:
	## \K				everything until here, omit
	## (){4}			repeat block at least 1 time, up to 8
	## ([0-9]){1,4}:*		1 to 3 integers [0-9] followed by "."
	##
	#local grep_reggex='^\s*inet\s+(addr:?\s*)?\K(([0-9]){1,3}\.*){4}'
	##
	## The following string, on the other hand, is harder to read and
	## understand, but is MUCH safer, as it ensure that the IP
	## fulfills some criteria.
	local grep_reggex='^\s*inet\s+(addr:?\s*)?\K(((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))'
	if   ( which ip > /dev/null 2>&1 ); then
		local ip=$('ip' -family inet addr show |\
		           grep -oP "$grep_reggex" |\
		           sed '/127.0.0.1/d;:a;N;$!ba;s/\n/, /g')
	elif ( which ifconfig > /dev/null 2>&1 ); then
		local ip=$('ifconfig' |\
		           grep -oP "$grep_reggex"|\
		           sed '/127.0.0.1/d;:a;N;$!ba;s/\n/, /g')
	else
		local ip="N/A"
	fi
	## FIX IP FORMAT AND RETURN
	## Add extra space after commas for readibility
	local ip=$(echo "$ip" | sed 's/,/, /g')
	printf "$ip"
}
##==============================================================================
##
##	getExternalIPv4()
##
##	Makes a query to internet-server and returns public IPv4-address.
##	Test for the presence of several programs in case one is missing.
##	Program search ordering is based on timed tests, fastest to slowest.
##	DNS-based queries are always faster, ~0.1 seconds.
##	URL-queries are relatively slow, ~1 seconds.
##
getExternalIPv4()
{
	if   ( which dig > /dev/null 2>&1 ); then
		local ip=$(dig +time=3 +tries=1 TXT -4 +short \
		           o-o.myaddr.l.google.com @ns1.google.com |\
		           awk -F\" '{print $2}')
	elif ( which drill > /dev/null 2>&1 ); then
		local ip=$(drill +time=3 +tries=1 TXT -4 +short \
		           o-o.myaddr.l.google.com @ns1.google.com |\
		           grep IN | tail -n 1 | cut -f5 -s |\
		           awk -F\" '{print $2}')
	elif ( which nslookup > /dev/null 2>&1 ); then
		local ip=$(nslookup -timeout=3 -q=txt \
		           o-o.myaddr.l.google.com 216.239.32.10 |\
		           awk -F \" 'BEGIN{RS="\r\n"}{print $2}END{RS="\r\n"}')
	elif ( which curl > /dev/null 2>&1 ); then
		local ip=$(curl -s https://api.ipify.org)
	elif ( which wget > /dev/null 2>&1 ); then
		local ip=$(wget -q -O - https://api.ipify.org)
	else
		local result="N/A"
	fi
	printf "$ip"
}
#!/bin/bash
##==============================================================================
##	EXTERNAL DEPENDENCIES
##==============================================================================
[ "$(type -t include)" != 'function' ]&&{ include(){ { [ -z "$_IR" ]&&_IR="$PWD"&&cd "$(dirname "${BASH_SOURCE[0]}")"&&include "$1"&&cd "$_IR"&&unset _IR;}||{ local d="$PWD"&&cd "$(dirname "$PWD/$1")"&&. "$(basename "$1")"&&cd "$d";}||{ echo "Include failed $PWD->$1"&&exit 1;};};}
##==============================================================================
##	ONE LINERS
##==============================================================================
printInfoOS()           { printInfoLine "OS" "$(getNameOS)" ; }
printInfoKernel()       { printInfoLine "Kernel" "$(getNameKernel)" ; }
printInfoShell()        { printInfoLine "Shell" "$(getNameShell)" ; }
printInfoDate()         { printInfoLine "Date" "$(getDate)" ; }
printInfoUptime()       { printInfoLine "Uptime" "$(getUptime)" ; }
printInfoUser()         { printInfoLine "User" "$(getUserHost)" ; }
printInfoNumLoggedIn()  { printInfoLine "Logged in" "$(getNumberLoggedInUsers)" ; }
printInfoNameLoggedIn() { printInfoLine "Logged in" "$(getNameLoggedInUsers)" ; }
printInfoCPU()          { printInfoLine "CPU" "$(getNameCPU)" ; }
printInfoCPULoad()      { printInfoLine "Sys load" "$(getCPULoad)" ; }
printInfoLocalIPv4()    { printInfoLine "Local IPv4" "$(getLocalIPv4)" ; }
printInfoExternalIPv4() { printInfoLine "External IPv4" "$(getExternalIPv4)" ; }
printInfoSpacer()       { printInfoLine "" "" ; }
##==============================================================================
##
##==============================================================================
printInfoGPU()
{
	# DETECT GPU(s)set	
	local gpu_ids=($(lspci 2>/dev/null | grep ' VGA ' | cut -d" " -f 1))
	# FOR ALL DETECTED IDs
	# Get the GPU name, but trim all buzzwords away
	for id in "${gpu_ids[@]}"; do
		local gpu=$(lspci -v -s "$id" 2>/dev/null |\
		            head -n 1 |\
		            sed 's/^.*: //g;s/(.*$//g;
		                 s/Generation Core Processor Family Integrated Graphics Controller /gen IGC/g;
		                 s/Corporation//g;
		                 s/Core Processor//g;
		                 s/Series//g;
		                 s/Chipset//g;
		                 s/Graphics//g;
		                 s/processor//g;
		                 s/Controller//g;
		                 s/Family//g;
		                 s/Inc.//g;
		                 s/,//g;
		                 s/Technology//g;
		                 s/Mobility/M/g;
		                 s/Advanced Micro Devices/AMD/g;
		                 s/\[AMD\/ATI\]/ATI/g;
		                 s/Integrated Graphics Controller/HD Graphics/g;
		                 s/Integrated Controller/IC/g;
		                 s/  */ /g'
		           )
		# If GPU name still to long, remove anything between []
		if [ "${#gpu}" -gt 30 ]; then
			local gpu=$(printf "$gpu" | sed 's/\[.*\]//g' )
		fi
		printInfoLine "GPU" "$gpu"
	done
}
##==============================================================================
##
##==============================================================================
##------------------------------------------------------------------------------
##
printInfoSystemctl()
{
	if [ -z "$(pidof systemd)" ]; then
		local sysctl="systemd not running"
		local state="critical"
	else
		local systcl_num_failed=$(systemctl --failed |\
		                          grep "loaded units listed" |\
		                          head -c 1)
		if   [ "$systcl_num_failed" -eq "0" ]; then
			local sysctl="All services OK"
			local state="nominal"
		elif [ "$systcl_num_failed" -eq "1" ]; then
			local sysctl="1 service failed!"
			local state="error"
		else
			local sysctl="$systcl_num_failed services failed!"
			local state="error"
		fi
	fi
	printInfoLine "Services" "$sysctl" "$state"
}
##------------------------------------------------------------------------------
##
printInfoColorpaletteSmall()
{
	local char="▀▀"
	local palette=$(printf '%s'\
	"$(formatText "$char" -c black -b dark-gray)"\
	"$(formatText "$char" -c red -b light-red)"\
	"$(formatText "$char" -c green -b light-green)"\
	"$(formatText "$char" -c yellow -b light-yellow)"\
	"$(formatText "$char" -c blue -b light-blue)"\
	"$(formatText "$char" -c magenta -b light-magenta)"\
	"$(formatText "$char" -c cyan -b light-cyan)"\
	"$(formatText "$char" -c light-gray -b white)")
	printInfoLine "Color palette" "$palette"
}
##------------------------------------------------------------------------------
##
printInfoColorpaletteFancy()
{
	## Line 1:	▄▄█ ▄▄█ ▄▄█ ▄▄█ ▄▄█ ▄▄█ ▄▄█ ▄▄█ 
	## Line 2:	██▀ ██▀ ██▀ ██▀ ██▀ ██▀ ██▀ ██▀ 
	local palette_top=$(printf '%s'\
		"$(formatText "▄" -c dark-gray)$(formatText "▄" -c dark-gray -b black)$(formatText "█" -c black) "\
		"$(formatText "▄" -c light-red)$(formatText "▄" -c light-red -b red)$(formatText "█" -c red) "\
		"$(formatText "▄" -c light-green)$(formatText "▄" -c light-green -b green)$(formatText "█" -c green) "\
		"$(formatText "▄" -c light-yellow)$(formatText "▄" -c light-yellow -b yellow)$(formatText "█" -c yellow) "\
		"$(formatText "▄" -c light-blue)$(formatText "▄" -c light-blue -b blue)$(formatText "█" -c blue) "\
		"$(formatText "▄" -c light-magenta)$(formatText "▄" -c light-magenta -b magenta)$(formatText "█" -c magenta) "\
		"$(formatText "▄" -c light-cyan)$(formatText "▄" -c light-cyan -b cyan)$(formatText "█" -c cyan) "\
		"$(formatText "▄" -c white)$(formatText "▄" -c white -b light-gray)$(formatText "█" -c light-gray) ")
	local palette_bot=$(printf '%s'\
		"$(formatText "██" -c dark-gray)$(formatText "▀" -c black) "\
		"$(formatText "██" -c light-red)$(formatText "▀" -c red) "\
		"$(formatText "██" -c light-green)$(formatText "▀" -c green) "\
		"$(formatText "██" -c light-yellow)$(formatText "▀" -c yellow) "\
		"$(formatText "██" -c light-blue)$(formatText "▀" -c blue) "\
		"$(formatText "██" -c light-magenta)$(formatText "▀" -c magenta) "\
		"$(formatText "██" -c light-cyan)$(formatText "▀" -c cyan) "\
		"$(formatText "██" -c white)$(formatText "▀" -c light-gray) ")
	printInfoLine "" "$palette_top"
	printInfoLine "Color palette" "$palette_bot"
}
##------------------------------------------------------------------------------
##
printInfoCPUTemp()
{
	if ( which sensors > /dev/null 2>&1 && sensors > /dev/null 2>&1); then
		## GET VALUES
		local temp_line=$(sensors 2>/dev/null |\
		                  grep Core |\
		                  head -n 1 |\
		                  sed 's/^.*:[ \t]*//g;s/[\(\),]//g')
		local units=$(echo $temp_line |\
		              sed -n 's/.*\( [[CF]]*\).*/\1/p' |\
		              sed 's/\ /°/g')
		local current=$(echo $temp_line |\
		                sed -n 's/^.*+\(.*\) [[CF]]*[ \t]*h.*/\1/p')
		local high=$(echo $temp_line |\
		             sed -n 's/^.*high = +\(.*\) [[CF]]*[ \t]*c.*/\1/p')
		local max=$(echo $temp_line |\
		            sed -n 's/^.*crit = +\(.*\) [[CF]]*[ \t]*.*/\1/p')
		## DETERMINE STATE
		## Use bc because we might be dealing with decimals
		if   (( $(echo "$current < $high" | bc -l) )); then 
			local state="nominal"
		elif (( $(echo "$current < $max" | bc -l) )); then 
			local state="critical";
		else                             
			local state="error";
		fi
		## PRINT MESSAGE
		local temp="$current$units"
		printInfoLine "CPU temp" "$temp" "$state"
	else
		printInfoLine "CPU temp" "lm-sensors not installed"
	fi
}
printResourceMonitor()
{
	local label=$1
	local value=$2
	local max=$3
	local units=$4
	local format=$5
	local crit_percent=$6	
	local error_percent=${7:-99}
	## CHECK STATE
	local percent=$('bc' <<< "$value*100/$max")
	local percent=${percent/.*}
	local state="nominal"
	if   [ $percent -gt $error_percent ]; then
		local state="error"
	elif [ $percent -gt $crit_percent ]; then
		local state="critical"
	fi
	printInfoMonitor "$label" "$current_value" "$max" "$units" "$format" "$state"
}
##------------------------------------------------------------------------------
##
printMonitorCPU()
{
	assert_is_set $bar_cpu_crit_percent
	local format=$1
	local label="Sys load avg"
	local units=""
	local current_value=$(awk '{avg_1m=($1)} END {printf "%3.2f", avg_1m}' /proc/loadavg)
	local max=$(nproc --all)
	local crit_percent=$bar_cpu_crit_percent
	printResourceMonitor "$label" "$current_value" "$max" "$units" "$format" "$crit_percent"
}
##------------------------------------------------------------------------------
##
printMonitorRAM()
{
	assert_is_set $bar_ram_units
	assert_is_set $bar_ram_crit_percent
	local format=$1
	local label="Memory"
	case "$bar_ram_units" in
		"MB")		local units="MB"; local option="--mega" ;;
		"TB")		local units="TB"; local option="--tera" ;;
		"PB")		local units="PB"; local option="--peta" ;;
		*)		local units="GB"; local option="--giga" ;;
	esac
	local mem_info=$('free' "$option" | head -n 2 | tail -n 1)
	local current_value=$(echo "$mem_info" | awk '{mem=($2-$7)} END {printf mem}')
	local max=$(echo "$mem_info" | awk '{mem=($2)} END {printf mem}')
	local crit_percent=$bar_ram_crit_percent
	printResourceMonitor "$label" "$current_value" "$max" "$units" "$format" "$crit_percent"
}
##------------------------------------------------------------------------------
##
printMonitorSwap()
{
	assert_is_set $bar_swap_units
	assert_is_set $bar_swap_crit_percent
	local format=$1
	local label="Swap"
	case "$bar_swap_units" in
		"MB")		local units="MB"; local option="--mega" ;;
		"TB")		local units="TB"; local option="--tera" ;;
		"PB")		local units="PB"; local option="--peta" ;;
		*)		local units="GB"; local option="--giga" ;;
	esac
	## CHECK IF SYSTEM HAS SWAP
	## Count number of lines in /proc/swaps, excluding the header (-1)
	## This is not fool-proof, but if num_swap_devs>=1, there should be swap
	local num_swap_devs=$(($(wc -l /proc/swaps | awk '{print $1;}') -1))
	if [ "$num_swap_devs" -lt 1 ]; then
		printInfoLine "$label" "N/A"
	else
		local swap_info=$('free' "$option" | tail -n 1)
		local current_value=$(echo "$swap_info" | awk '{SWAP=($3)} END {printf SWAP}')
		local max=$(echo "$swap_info" | awk '{SWAP=($2)} END {printf SWAP}')
		local crit_percent=$bar_swap_crit_percent
		printResourceMonitor "$label" "$current_value" "$max" "$units" "$format" "$crit_percent"
	fi
}
##------------------------------------------------------------------------------
##
printStorageMonitor()
{
	local label=$1
	local device=$2
	local units=$3
	local format=$4
	local crit_percent=$5	
	local error_percent=${6:-99}
	case "$units" in
		"MB")		local units="MB"; local option="M" ;;
		"TB")		local units="TB"; local option="T" ;;
		"PB")		local units="PB"; local option="P" ;;
		*)		local units="GB"; local option="G" ;;
	esac
	local current_value=$(df "-B1${option}" "${device}" | grep / | awk '{key=($3)} END {printf key}')
	local max=$(df "-B1${option}" "${device}" | grep / | awk '{key=($2)} END {printf key}')
	printResourceMonitor "$label" "$current_value" "$max" "$units" "$format" "$crit_percent" "$error_percent"
}
##------------------------------------------------------------------------------
##
printMonitorHDD()
{
	assert_is_set $bar_hdd_units
	assert_is_set $bar_hdd_crit_percent
	local format=$1
	local label="Storage /"	
	local device="/"
	local units=$bar_hdd_units
	local crit_percent=$bar_hdd_crit_percent
	printStorageMonitor "$label" "$device" "$units" "$format" "$crit_percent"
}
##------------------------------------------------------------------------------
## 
printMonitorHome()
{
	assert_is_set $bar_home_units
	assert_is_set $bar_home_crit_percent
	local format=$1
	local label="Storage /home"	
	local device=$HOME
	local units=$bar_home_units
	local crit_percent=$bar_home_crit_percent
	printStorageMonitor "$label" "$device" "$units" "$format" "$crit_percent"
}
##------------------------------------------------------------------------------
##
printMonitorCPUTemp()
{
	if ( which sensors > /dev/null 2>&1 ); then
		## GET VALUES
		local temp_line=$(sensors |\
		                  grep Core |\
		                  head -n 1 |\
		                  sed 's/^.*:[ \t]*//g;s/[\(\),]//g')
		local units=$(echo $temp_line |\
		              sed -n 's/.*\(°[[CF]]*\).*/\1/p' )
		local current=$(echo $temp_line |\
		                sed -n 's/^.*+\(.*\)°[[CF]]*[ \t]*h.*/\1/p' )
		local high=$(echo $temp_line |\
		            sed -n 's/^.*high = +\(.*\)°[[CF]]*[ \t]*c.*/\1/p' )
		local max=$(echo $temp_line |\
		              sed -n 's/^.*crit = +\(.*\)°[[CF]]*[ \t]*.*/\1/p' )
		local crit_percent=$(bc <<< "$high*100/$max")
		## PRINT MONITOR
		printResourceMonitor $current $max $crit_percent \
	        	     false $units "CPU temp"
	else
		printInfoLine "CPU temp" "lm-sensors not installed"
	fi
}
#!/bin/bash
##
##	USAGE
##	=====
##
##	Formating a text directly:
##		FORMATTED_TEXT=$(formatText "Hi!" -c red -b 13 -e bold)
##		echo -e "$FORMATTED_TEXT"
##
##	Getting the control sequences:
##		FORMAT=$(getFormatCode -c blue -b yellow -e bold -e blink)
##		NONE=$(getFormatCode -e none)
##		echo -e $FORMAT"Hello"$NONE
##
##	Options (More than one code may be specified)
##	-c	color name or 256bit code for font face
##	-b	background color name or 256bit code
##	-e	effect name (e.g. bold, blink, etc.)
##
##
##
##
##
##	BASH TEXT FORMATING
##	===================
##
##	Colors and text formatting can be achieved by preceding the text
##	with an escape sequence. An escape sequence starts with an <ESC>
##	character (commonly \e[), followed by one or more formatting codes
##	(its possible) to apply more that one color/effect at a time),
##	and finished by a lower case m. For example, the formatting code 1 
##	tells the terminal to print the text bold face. This is acchieved as:
##		\e[1m Hello World!
##
##	But if nothing else is specified, then eveything that may be printed
##	after 'Hello world!' will be bold face as well. The code 0 is thus
##	meant to remove all formating from the text and return to normal:
##		\e[1m Hello World! \e[0m
##
##	It's also possible to paint the text in color (codes 30 to 37 and
##	codes 90 to 97), or its background (codes 40 to 47 and 100 to 107).
##	Red has code 31:
##		\e[31m Hello World! \e[0m
##
##	More than one code can be applied at a time. Codes are separated by
##	semicolons. For example, code 31 paints the text in red. Thus,
##	the following would print in red bold face:
##		\e[1;31m Hello World! \e[0m
##
##	Some formatting sequences are, in fact, comprised of two codes
##	that must go together. For example, the code 38;5; tells the terminal
##	that the next code (after the semicolon) should be interpreted as
##	a 256 bit formatting color. So, for example, the code 82 is a light
##	green. We can paint the text using this code as follows, plus bold
##	face as follows - but notice that not all terminal support 256 colors:##
##		\e[1;38;5;82m Hello World! \e[0m
##
##	For a detailed list of all codes, this site has an excellent guide:
##	https://misc.flogisoft.com/bash/tip_colors_and_formatting
##
##
##
##
##
##	TODO: When requesting an 8 bit colorcode, detect if terminal supports
##	256 bits, and return appropriate code instead
##
##	TODO: Improve this description/manual text
##
##	TODO: Currently, if only one parameter is passed, its treated as a
##	color. Addsupport to also detect whether its an effect code.
##		Now: getFormatCode blue == getFormatCode -c blue
##		Add: getFormatCode bold == getFormatCode -e bold
##
##	TODO: Clean up this script. Prevent functions like "get8bitCode()"
##	to be accessible from outside. These are only a "helper" function
##	that should only be available to this script
##
##==============================================================================
##	CODE PARSERS
##==============================================================================
##------------------------------------------------------------------------------
##
get8bitCode()
{
	CODE=$1
	case $CODE in
		default)
			echo 9
			;;
		none)
			echo 9
			;;
		black)
			echo 0
			;;
		red)
			echo 1
			;;
		green)
			echo 2
			;;
		yellow)
			echo 3
			;;
		blue)
			echo 4
			;;
		magenta|purple|pink)
			echo 5
			;;
		cyan)
			echo 6
			;;
		light-gray)
			echo 7
			;;
		dark-gray)
			echo 60
			;;
		light-red)
			echo 61
			;;
		light-green)
			echo 62
			;;
		light-yellow)
			echo 63
			;;
		light-blue)
			echo 64
			;;
		light-magenta)
			echo 65
			;;
		light-cyan)
			echo 66
			;;
		white)
			echo 67
			;;
		*)
			echo 0
	esac
}
##------------------------------------------------------------------------------
##
getColorCode()
{
	COLOR=$1
	## Check if color is a 256-color code
	if [ $COLOR -eq $COLOR ] 2> /dev/null; then
		if [ $COLOR -gt 0 -a $COLOR -lt 256 ]; then
			echo "38;5;$COLOR"
		else
			echo 0
		fi
	## Or if color key-workd
	else
		BITCODE=$(get8bitCode $COLOR)
		COLORCODE=$(($BITCODE + 30))
		echo $COLORCODE
	fi
}
##------------------------------------------------------------------------------
##
getBackgroundCode()
{
	COLOR=$1
	## Check if color is a 256-color code
	if [ $COLOR -eq $COLOR ] 2> /dev/null; then
		if [ $COLOR -gt 0 -a $COLOR -lt 256 ]; then
			echo "48;5;$COLOR"
		else
			echo 0
		fi
	## Or if color key-workd
	else
		BITCODE=$(get8bitCode $COLOR)
		COLORCODE=$(($BITCODE + 40))
		echo $COLORCODE
	fi
}
##------------------------------------------------------------------------------
##
getEffectCode()
{
	EFFECT=$1
	NONE=0
	case $EFFECT in
	none)
		echo $NONE
		;;
	default)
		echo $NONE
		;;
	bold)
		echo 1
		;;
	bright)
		echo 1
		;;
	dim)
		echo 2
		;;
	underline)
		echo 4
		;;
	blink)
		echo 5
		;;
	reverse)
		echo 7
		;;
	hidden)
		echo 8
		;;
	strikeout)
		echo 9
		;;
	*)
		echo $NONE
	esac
}
##------------------------------------------------------------------------------
##
getFormattingSequence()
{
	START='\e[0;'
	MIDLE=$1
	END='m'
	echo -n "$START$MIDLE$END"
}
##==============================================================================
##	AUX
##==============================================================================
applyCodeToText()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	TEXT=$1
	CODE=$2
	echo -n "$CODE$TEXT$RESET"
}
##==============================================================================
##	MAIN FUNCTIONS
##==============================================================================
##------------------------------------------------------------------------------
##
getFormatCode()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	## NO ARGUMENT PROVIDED
	if [ "$#" -eq 0 ]; then
		echo -n "$RESET"
	## 1 ARGUMENT -> ASSUME TEXT COLOR
	elif [ "$#" -eq 1 ]; then
		TEXT_COLOR=$(getFormattingSequence $(getColorCode $1))
		echo -n "$TEXT_COLOR"
	## ARGUMENTS PROVIDED
	else
		FORMAT=""
		while [ "$1" != "" ]; do
			## PROCESS ARGUMENTS
			TYPE=$1
			ARGUMENT=$2
			case $TYPE in
			-c)
				CODE=$(getColorCode $ARGUMENT)
				;;
			-b)
				CODE=$(getBackgroundCode $ARGUMENT)
				;;
			-e)
				CODE=$(getEffectCode $ARGUMENT)
				;;
			*)
				CODE=""
			esac
			## ADD CODE SEPARATOR IF NEEDED
			if [ "$FORMAT" != "" ]; then
				FORMAT="$FORMAT;"
			fi
			## APPEND CODE
			FORMAT="$FORMAT$CODE"
			# Remove arguments from stack
			shift
			shift
		done
		## APPLY FORMAT TO TEXT
		FORMAT_CODE=$(getFormattingSequence $FORMAT)
		echo -n "${FORMAT_CODE}"
	fi
}
##------------------------------------------------------------------------------
##
formatText()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	## NO ARGUMENT PROVIDED
	if [ "$#" -eq 0 ]; then
		echo -n "${RESET}"
	## ONLY A STRING PROVIDED -> Append reset sequence
	elif [ "$#" -eq 1 ]; then
		TEXT=$1
		echo -n "${TEXT}${RESET}"
	## ARGUMENTS PROVIDED
	else
		TEXT=$1
		FORMAT_CODE=$(getFormatCode "${@:2}")
		applyCodeToText "$TEXT" "$FORMAT_CODE"
	fi
}
##------------------------------------------------------------------------------
##
removeColorCodes()
{
	printf "$1" | sed 's/\x1b\[[0-9;]*m//g'
}
##==============================================================================
##	DEBUG
##==============================================================================
#formatText "$@"
#FORMATTED_TEXT=$(formatText "HELLO WORLD!!" -c red -b 13 -e bold -e blink -e strikeout)
#echo -e "$FORMATTED_TEXT"
#FORMAT=$(getFormatCode -c blue -b yellow)
#NONE=$(getFormatCode -e none)
#echo -e $FORMAT"Hello"$NONE
#!/bin/bash
##	Helper functions to print on different places of the screen
##==============================================================================
##	TERMINAL CURSOR
##==============================================================================
enableTerminalLineWrap()
{
	printf '\e[?7h'
}
disableTerminalLineWrap()
{
	printf '\e[?7l'
}
saveCursorPosition()
{
	printf "\e[s"
}
moveCursorToSavedPosition()
{
	printf "\e[u"
}
moveCursorToRowCol()
{
	local row=$1
	local col=$2
	printf "\e[${row};${col}H"
}
moveCursorHome()
{
	printf "\e[;H"
}
moveCursorUp()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1A"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}A"
	fi
}
moveCursorDown()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1B"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}B"
	fi
}
moveCursorRight()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1C"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}D"
	fi
}
moveCursorLeft()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1D"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}C"
	fi
}
##==============================================================================
##	FUNCTIONS
##==============================================================================
##------------------------------------------------------------------------------
##
getTerminalNumRows()
{
	tput lines
}
##------------------------------------------------------------------------------
##
getTerminalNumCols()
{
	tput cols
}
##------------------------------------------------------------------------------
##
getTextNumRows()
{
	## COUNT ROWS
	local rows=$(echo -e "$1" | wc -l )
	echo "$rows"
}
##------------------------------------------------------------------------------
##
getTextNumCols()
{
	## COUNT COLUMNS - Remove color sequences before counting
	## 's/\x1b\[[0-9;]*m//g' to remove formatting sequences (\e=\033=\x1b)
	local columns=$(echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g' | wc -L )
	echo "$columns"
}
##------------------------------------------------------------------------------
##
getTextShape()
{
	echo "$(getTextNumRows) $(getTextNumCols)"
}
##------------------------------------------------------------------------------
##
printWithOffset()
{
	local row=$1
	local col=$2
	local text=${@:3}
	## MOVE CURSOR TO TARGET ROW
	moveCursorDown "$row"
	## EDIT TEXT TO PRINT IN CORRECT COLUMN
	## If spacer is 1 column or more
	## - Add spacer at the start of the text
	## - Add spacer after each line break
	## Otherwise, do not alter the text
	if [ $col -gt 0 ]; then
		col_spacer="\\\\e[${col}C"
		local text=$(echo "$text" |\
		             sed "s/^/$col_spacer/g;s/\\\\n/\\\\n$col_spacer/g")
	fi
	## PRINT TEXT WITHOUT LINE WRAP
	disableTerminalLineWrap
	echo -e "${text}"
	enableTerminalLineWrap
}
##------------------------------------------------------------------------------
##
printTwoElementsSideBySide()
{
	## GET ELEMENTS TO PRINT
	local element_1=$1
	local element_2=$2
	local print_cols_max=$3
	## GET PRINTABLE AREA SIZE
	## If print_cols_max specified, then keep the smaller between it and
	## the current terminal width
	local term_cols=$(getTerminalNumCols)
	if [ ! -z "$print_cols_max" ]; then
		local term_cols=$(( ( $term_cols > $print_cols_max ) ?\
			$print_cols_max : $term_cols ))
	fi
	## GET ELEMENT SHAPES
	local e_1_cols=$(getTextNumCols "$element_1")
	local e_1_rows=$(getTextNumRows "$element_1")
	local e_2_cols=$(getTextNumCols "$element_2")
	local e_2_rows=$(getTextNumRows "$element_2")
	## COMPUTE OPTIMAL HORIZONTAL PADDING
	local free_cols=$(( $term_cols - $e_1_cols - $e_2_cols ))
	if [ $free_cols -lt 1 ]; then
		local free_cols=0
	fi
	if [ $e_1_cols -gt 0 ] && [ $e_2_cols -gt 0 ]; then
		local h_pad=$(( $free_cols/3 ))
		local e_1_h_pad=$h_pad
		local e_2_h_pad=$(( $e_1_cols + 2*$h_pad ))
	elif  [ $e_1_cols -gt 0 ]; then
		local h_pad=$(( $free_cols/2 ))
		local e_1_h_pad=$h_pad
		local e_2_h_pad=0
	elif  [ $e_2_cols -gt 0 ]; then
		local h_pad=$(( $free_cols/2 ))
		local e_1_h_pad=0
		local e_2_h_pad=$h_pad
	else
		local e_1_h_pad=0
		local e_2_h_pad=0
	fi
	## COMPUTE OPTIMAL VERTICAL PADDING
	local e_1_v_pad=$(( ( $e_1_rows > $e_2_rows ) ?\
		0 : (( ($e_2_rows - $e_1_rows)/2 )) ))
	local e_2_v_pad=$(( ( $e_2_rows > $e_1_rows ) ?\
		0 : (( ($e_1_rows - $e_2_rows)/2 )) ))
	local max_rows=$(( ( $e_1_rows > $e_2_rows ) ? $e_1_rows : $e_2_rows ))
	## CLEAN PRINTING AREA
	for i in `seq $max_rows`; do printf "\n"; done
	moveCursorUp $max_rows
	saveCursorPosition
	printWithOffset $e_1_v_pad $e_1_h_pad "$element_1"
	moveCursorToSavedPosition
	printWithOffset $e_2_v_pad $e_2_h_pad "$element_2"
	moveCursorToSavedPosition
	## LEAVE CURSOR AT "SAFE" POSITION	
	moveCursorDown $(( $max_rows ))
}
#!/bin/bash
##==============================================================================
##	HELPERS
##==============================================================================
##==============================================================================
##
##
##==============================================================================
##	FUNCTIONS
##==============================================================================
##==============================================================================
##
##
assert_is_set()
{
	local ok=0
	local assert_failed=98
	if [ -z ${1+x} ]; then 
		echo "Assertion failed, variable not set."
		return $assert_failed
	else
		return $ok
	fi
}
##==============================================================================
##
##
assert_not_empty()
{
	local ok=0
	local assert_failed=98
	local variable=$1
	if [ -z $variable ]; then 
		echo "Assertion failed, variable empty. $message"
		return $assert_failed
	else
		return $ok
	fi
}
##==============================================================================
##
##
assert_empty()
{
	local ok=0
	local assert_failed=98
	assert_is_set $1
	local variable=$1
	if [ -n $variable ]; then 
		echo "Assertion failed, variable empty. $message"
		return $assert_failed
	else
		return $ok
	fi
}
#!/bin/bash
##==============================================================================
##	EXTERNAL DEPENDENCIES
##==============================================================================
[ "$(type -t include)" != 'function' ]&&{ include(){ { [ -z "$_IR" ]&&_IR="$PWD"&&cd "$(dirname "${BASH_SOURCE[0]}")"&&include "$1"&&cd "$_IR"&&unset _IR;}||{ local d="$PWD"&&cd "$(dirname "$PWD/$1")"&&. "$(basename "$1")"&&cd "$d";}||{ echo "Include failed $PWD->$1"&&exit 1;};};}
##==============================================================================
##	
##==============================================================================
##------------------------------------------------------------------------------
##
reportLastLogins()
{
	assert_is_set ${fc_highlight}
	assert_is_set ${fc_info}
	## DO NOTHING FOR NOW -> This is disabled intentionally for now.
	## Printing logins should only be done under special circumstances:
	## 1. User configurable set to always on
	## 2. If the IP/terminal is very different from usual
	## 3. Other anomalies...
	if false; then
		printf "${fc_highlight}\nLAST LOGINS:\n${fc_info}"
		last -iwa | head -n 4 | grep -v "reboot"
	fi
}
##------------------------------------------------------------------------------
##
reportSystemctl()
{
	assert_is_set ${fc_highlight}
	assert_is_set ${fc_info}
	assert_is_set ${fc_crit}
	assert_is_set ${fc_none}
    ## 1. Check if systemd is running (it might not on some distros/Windows)
    ## 2. Get number of failed daemons
    ## 3. Report those that failed
    if [ -n "$(pidof systemd)" ]; then
	    systcl_num_failed=$(systemctl --failed |\
	                        grep "loaded units listed" |\
	                        head -c 1)
	    if [ "$systcl_num_failed" -ne "0" ]; then
		    local failed=$(systemctl --failed | awk '/UNIT/,/^$/')
		    printf "\n${fc_crit}SYSTEMCTL FAILED SERVICES:\n"
		    printf "${fc_info}${failed}${fc_none}\n"
	    fi
    fi
}
##------------------------------------------------------------------------------
##
reportHogsCPU()
{
	assert_is_set ${cpu_crit_print}
	assert_is_set ${bar_cpu_crit_percent}
	assert_is_set ${fc_highlight}
	assert_is_set ${fc_info}
	assert_is_set ${fc_crit}
	assert_is_set ${fc_none}
	export LC_NUMERIC="C"
	## EXIT IF NOT ENABLED
	if [ "$cpu_crit_print" == true ]; then
		## CHECK CPU LOAD
		local current=$(awk '{avg_1m=($1)} END {printf "%3.2f", avg_1m}' /proc/loadavg)
		local max=$(nproc --all)
		local percent=$(bc <<< "$current*100/$max")
		if [ "$percent" -gt "$bar_cpu_crit_percent" ]; then
			## CALL TOP IN BATCH MODE
			## Check if "%Cpus(s)" is shown, otherwise, call "top -1"
			## Escape all '%' characters
			local top=$(nice 'top' -b -d 0.01 -n 1 )
			local cpus=$(echo "$top" | grep "Cpu(s)" )
			if [ -z "$cpus" ]; then
				local top=$(nice 'top' -b -d 0.01 -1 -n 1 )
				local cpus=$(echo "$top" | grep "Cpu(s)" )
			fi
			local top=$(echo "$top" | sed 's/\%/\%\%/g' )
			## EXTRACT ELEMENTS FROM TOP
			## - load:    summary of cpu time spent for user/system/nice...
			## - header:  the line just above the processes
			## - procs:   the N most demanding procs in terms of CPU time
			local load=$(echo "${cpus:9:36}" | tr '', ' ' )
			local header=$(echo "$top" | grep "%CPU" )
			local procs=$(echo "$top" |\
				      sed  '/top - /,/%CPU/d' |\
				      head -n "$cpu_crit_print_num" )
			## PRINT WITH FORMAT
			printf "\n${fc_crit}SYSTEM LOAD:${fc_info}  ${load}\n"
			printf "${fc_crit}$header${fc_none}\n"
			printf "${fc_text}${procs}${fc_none}\n"
		fi
	fi
}
##------------------------------------------------------------------------------
##
reportHogsMemory()
{
	assert_is_set ${ram_crit_print}
	assert_is_set ${bar_ram_crit_percent}
	assert_is_set ${fc_highlight}
	assert_is_set ${fc_info}
	assert_is_set ${fc_crit}
	assert_is_set ${fc_none}
	## EXIT IF NOT ENABLED
	if [ "$ram_crit_print" == true ]; then
		## CHECK RAM
		local ram_is_crit=false
		local mem_info=$('free' -m | head -n 2 | tail -n 1)
		local current=$(echo "$mem_info" | awk '{mem=($2-$7)} END {printf mem}')
		local max=$(echo "$mem_info" | awk '{mem=($2)} END {printf mem}')
		local percent=$(bc <<< "$current*100/$max")
		if [ $percent -gt $bar_ram_crit_percent ]; then
			local ram_is_crit=true
		fi
		## CHECK SWAP
		## First check if there is any swap at all by checking /proc/swaps
		## If there is at least one swap partition listed, proceed
		local swap_is_crit=false
		local num_swap_devs=$(($(wc -l /proc/swaps | awk '{print $1;}') -1))	
		if [ "$num_swap_devs" -ge 1 ]; then
			local swap_info=$('free' -m | tail -n 1)
			local current=$(echo "$swap_info" | awk '{SWAP=($3)} END {printf SWAP}')
			local max=$(echo "$swap_info" | awk '{SWAP=($2)} END {printf SWAP}')
			local percent=$(bc <<< "$current*100/$max")
			if [ $percent -gt $bar_swap_crit_percent ]; then
				local swap_is_crit=true
			fi
		fi
		## PRINT IF RAM OR SWAP ARE ABOVE THRESHOLD
		if $ram_is_crit || $swap_is_crit ; then
			local available=$(echo $mem_info | awk '{print $NF}')
			local procs=$(ps --cols=80 -eo pmem,size,pid,cmd --sort=-%mem |\
				      head -n $(($ram_crit_print_num + 1)) |\
			              tail -n $ram_crit_print_num |\
				      awk '{$2=int($2/1024)"MB";}
				           {printf("%5s%8s%8s\t%s\n", $1, $2, $3, $4)}')
			printf "\n${fc_crit}MEMORY:\t "
			printf "${fc_info}Only ${available} MB of RAM available!!\n"
			printf "${fc_crit}    %%\t SIZE\t  PID\tCOMMAND\n"
			printf "${fc_info}${procs}${fc_none}\n"
		fi
	fi
}
##==============================================================================
## LOGO
##
## Configure the logo to your liking. You can either use the default or
## set your own ASCII art down below. 
##
## - You can either add it as a single line, or multiline (terminated with \).
## - You have to escape backslashes if you want them to show inside your logo.
##   Use \\\\ for 1 backslash, \\\\\\\\ for two. All other characters work fine.
## - You can also add individual color codes to the logo using '\e[ ··· m'.
## - For example:   \e[1;31mHello World!   prints in bright red.
## - If you want extra spaces between the logo and the status info, just add
##   extra spaces at the last line and end it with '\n'.
##==============================================================================
logo="\e[38;5;213m
 ___ __    _ _______ ___     __   __ __   __
|   |  |  | |       |   |   |  | |  |  |_|  |
|   |   |_| |    ___|   |   |  | |  |       |
|   |       |   |___|   |   |  |_|  |       |
|   |  _    |    ___|   |___|       ||     |
|   | | |   |   |   |       |       |   _   |
|___|_|  |__|___|   |_______|_______|__| |__|
 ______  _______ _______ _______
|      ||   _   |       |   _   |
|  _    |  |_|  |_     _|  |_|  |
| | |   |       | |   | |       |
| |_|   |       | |   | |       |
|       |   _   | |   | |   _   |
|______||__| |__| |___| |__| |__|
"
##==============================================================================
## STATUS INFO
##
## Choose what to print and in what order
## Valid options are:
##
##                      ## SIMPLE ONE-LINERS
## OS                   Linux distribution name
## KERNEL               Kernel version
## CPU                  CPU Name
## SHELL                Shell name
## DATE                 Current date
## UPTIME               System uptime (time since boot)
## USER                 Current user and host names
## NUMLOGGED            Show number of logged in users
## NAMELOGGED           Show names of logged in users
## LOCALIPV4            IPv4
## EXTERNALIPV4         External IPv4 (might be slow)
## SERVICES             Summary of failed services
## CPULOAD              Sys load average(eg. 0.23, 0.26, 0.27 )
## CPUTEMP              CPU temperature (requires lm-sensors)
##
##                      ## SYS LOAD MONITORS
## SYSLOAD_MON          Current CPU load
## MEMORY_MON           Occupied memory
## SWAP_MON             Occupied SWAP
## HDDROOT_MON          / partition occupied
## HDDHOME_MON          /home/user occupied
## CPUTEMP_MON          CPU temperature (requires lm-sensors)
## SYSLOAD_MON%         Current CPU load in %
## MEMORY_MON%          Occupied memory in %
## SWAP_MON%            Occupied SWAP in %
## HDDROOT_MON%         / partition occupied in %
## HDDHOME_MON%         /home/user occupied in %
##
##                      ## MISC
## SPACER               Print decorative spacer (empty line)
## PALETTE              Show 16-bit palette (add SPACER before for best results)
## PALETTE_SMALL        Show smaller version of 16-bit color palette
##
##==============================================================================
print_info="
        OS
        KERNEL
        CPU
        GPU
        SHELL
        DATE
        UPTIME
        LOCALIPV4
        EXTERNALIPV4
        SERVICES
        CPUTEMP
        SYSLOAD_MON%
        MEMORY_MON
        SWAP_MON
        HDDROOT_MON
        HDDHOME_MON"
##==============================================================================
## COLORS
## 
## Control the color and format scheme of the status report.
## -c color: color name or 256bit color code
## -b background color: color name or 256bit color code
## -e effect: bold, blink, dim, underline...
##
## Valid color names (16 bit):
## white, light-gray, dark-gray, black,
## red, green, yellow, blue, magenta, cyan,
## light-red, light-green, light-yellow, light-blue, light-magenta, light-cyan
##
##==============================================================================
format_info="           -c light-gray          "
format_highlight="      -c blue         -e bold"
format_crit="           -c 45           -e bold"
format_deco="           -c light-gray          "
format_ok="             -c blue         -e bold"
format_error="          -c 45           -e bold -e blink"
format_logo="           -c blue         -e bold"
##==============================================================================
## STATUS BARS
##
## These option controls the behaviour of the visual status bars that are
## plotted for CPU, Memory, Swap and HDD usage. You can set the percentage that
## determines when the current usage is deemed critical. If said percentage
## is surpassed, the color of the bars will change and extra information
## might be plotted in addition (e.g. if the CPU usage is too high, the most
## demanding processes are printed to terminal).
##==============================================================================
bar_cpu_crit_percent=40
bar_ram_crit_percent=75
bar_swap_crit_percent=25
bar_hdd_crit_percent=85
bar_home_crit_percent=85
bar_ram_units="MB"
bar_swap_units="MB"
bar_hdd_units="GB"
bar_home_units="GB"
cpu_crit_print=true
cpu_crit_print_num=3
ram_crit_print=true
ram_crit_print_num=3
bar_length=9                    # Number of characters that comprise a bar
bar_num_digits=5                # Control num digits next to bar
bar_padding_after=0		# Extra spaces after bar
info_label_width=16             # Desired length of the info labels
bar_bracket_char_left='['
bar_bracket_char_right=']'
bar_fill_char='|'
bar_background_char=' '
##==============================================================================
## OTHERS
##
## For date format setup, see `man date`
##==============================================================================
print_cols_max=100              # Keep logo and info text together
print_logo_right=false          # Change where the logo is plotted
date_format="%Y.%m.%d - %T"     # see 'man date'
clear_before_print=false        # Dangerous if true, some messages might be lost
print_extra_new_line_top=true   # Extra line before logo and info
print_extra_new_line_bot=true   # Extra line after logo and info
#!/bin/bash
##==============================================================================
##	EXTERNAL DEPENDENCIES
##==============================================================================
[ "$(type -t include)" != 'function' ]&&{ include(){ { [ -z "$_IR" ]&&_IR="$PWD"&&cd "$(dirname "${BASH_SOURCE[0]}")"&&include "$1"&&cd "$_IR"&&unset _IR;}||{ local d="$PWD"&&cd "$(dirname "$PWD/$1")"&&. "$(basename "$1")"&&cd "$d";}||{ echo "Include failed $PWD->$1"&&exit 1;};};}
greeter()
{
##==============================================================================
##	CONFIGURATION
##==============================================================================
## LOAD CONFIGURATION
## Load default configuration file with all arguments, then try to load any of
## following in order, until first match, to override some or all config params.
## 1. Apply specific configuration file if specified as argument.
## 2. User specific configuration if in user's home folder.
## 3. If root, apply root configuration file if it exists in the system.
## 4. System wide configuration file if it exists.
## 5. Fall back to defaults.
##
local target_config_file="$1"
local user_config_file="$HOME/.config/synth-shell/synth-shell-greeter.config"
local root_config_file="/etc/synth-shell/os/synth-shell-greeter.root.config"
local sys_config_file="/etc/synth-shell/synth-shell-greeter.config"
if   [ -f "$target_config_file" ]; then source "$target_config_file" ;
elif [ -f "$user_config_file" ]; then source "$user_config_file" ;
elif [ -f $root_config_file ] && [ "$USER" == "root" ]; then source "$root_config_file" ;
elif [ -f "$sys_config_file" ]; then source "$sys_config_file" ;
else : # Default config already "included" ; 
fi
## COLOR AND TEXT FORMAT CODE
local fc_info=$(getFormatCode $format_info)
local fc_highlight=$(getFormatCode $format_highlight)
local fc_crit=$(getFormatCode $format_crit)
local fc_deco=$(getFormatCode $format_deco)
local fc_ok=$(getFormatCode $format_ok)
local fc_error=$(getFormatCode $format_error)
local fc_logo=$(getFormatCode $format_logo)
local fc_none=$(getFormatCode -e reset)
#fc_logo
#fc_ok
#fc_crit
#fc_error
#fc_none
local fc_label="$fc_info"
local fc_text="$fc_highlight"
##==============================================================================
##	STATUS INFO COMPOSITION
##==============================================================================
printStatusInfo()
{
	## HELPER FUNCTION
	statusSwitch()
	{
		case $1 in
		## 	INFO (TEXT ONLY)
		##	NAME            FUNCTION
			OS)             printInfoOS;;
			KERNEL)         printInfoKernel;;
			CPU)            printInfoCPU;;
			GPU)            printInfoGPU;;
			SHELL)          printInfoShell;;
			DATE)           printInfoDate;;
			UPTIME)         printInfoUptime;;
			USER)           printInfoUser;;
			NUMLOGGED)      printInfoNumLoggedIn;;
			NAMELOGGED)     printInfoNameLoggedIn;;
			LOCALIPV4)      printInfoLocalIPv4;;
			EXTERNALIPV4)   printInfoExternalIPv4;;
			SERVICES)       printInfoSystemctl;;
			PALETTE_SMALL)  printInfoColorpaletteSmall;;
			PALETTE)        printInfoColorpaletteFancy;;
			SPACER)         printInfoSpacer;;
			CPULOAD) 	printInfoCPULoad;;
			CPUTEMP)        printInfoCPUTemp;;
		## 	USAGE MONITORS (BARS)
		##	NAME            FUNCTION               AS %
			SYSLOAD_MON)    printMonitorCPU        'a/b';;
			SYSLOAD_MON%)   printMonitorCPU        '0/0';;
			MEMORY_MON)     printMonitorRAM        'a/b';;
			MEMORY_MON%)    printMonitorRAM        '0/0';;
			SWAP_MON)       printMonitorSwap       'a/b';;
			SWAP_MON%)      printMonitorSwap       '0/0';;
			HDDROOT_MON)    printMonitorHDD        'a/b';;
			HDDROOT_MON%)   printMonitorHDD        '0/0';;
			HDDHOME_MON)    printMonitorHome       'a/b';;
			HDDHOME_MON%)   printMonitorHome       '0/0';;
			CPUTEMP_MON)    printMonitorCPUTemp;;
			*)              printInfoLine "Unknown" "Check your config";;
		esac
	}
	## ASSEMBLE INFO PANE
	local status_info=""
	for key in $print_info; do
		if [ -z "$status_info" ]; then
			local status_info="$(statusSwitch "$key")"
		else
			local status_info="${status_info}\n$(statusSwitch "$key")"
		fi
	done
	printf "${status_info}\n"
}
##==============================================================================
##	PRINT
##==============================================================================
##------------------------------------------------------------------------------
##
printHeader()
{
	## GET ELEMENTS TO PRINT
	local logo=$(echo "$fc_logo$logo$fc_none")
	local info=$(printStatusInfo)
	## GET ELEMENT SIZES
	local term_cols=$(getTerminalNumCols)
	local logo_cols=$(getTextNumCols "$logo")
	local info_cols=$(getTextNumCols "$info")
	## PRINT ONLY WHAT FITS IN THE TERMINAL
	if [ $(( $logo_cols + $info_cols )) -le "$term_cols" ]; then
		: # everything fits
	else
		local logo=""
	fi
	if $print_logo_right ; then
		local right="$logo"
		local left="$info"
	else
		local right="$info"
		local left="$logo"
	fi
	printTwoElementsSideBySide "$left" "$right" "$print_cols_max"
}
printReports()
{
	reportLastLogins
	reportSystemctl
	reportHogsCPU
	reportHogsMemory
}
##==============================================================================
##	MAIN
##==============================================================================
## CHECKS
if [ -z "$(which 'bc' 2>/dev/null)" ]; then
	printf "${fc_error}synth-shell-greeter: 'bc' not installed${fc_none}"
	exit 1
fi
## PRINT TOP SPACER
if $clear_before_print; then clear; fi
if $print_extra_new_line_top; then echo ""; fi
## PRINT GREETER ELEMENTS
printHeader
printReports
## PRINT BOTTOM SPACER
if $print_extra_new_line_bot; then echo ""; fi
}
## RUN SCRIPT
## This whole script is wrapped with "{}" to avoid environment pollution.
## It's also called in a subshell with "()" to REALLY avoid pollution.
## If not running interactively, don't do anything
## Run only in interactive session
## If not running interactively, don't do anything.
## Run with `LANG=C` so the code uses `.` as decimal separator.
if [ -n "$( echo $- | grep i )" ]; then
	(LC_ALL=C greeter "$1") 
fi
unset greeter
