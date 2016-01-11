#!/bin/bash

#Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`
#Initialize variables to default values.
OPT_A=A
OPT_B=B
OPT_C=C
OPT_D=D
#Set fonts for Help.[译注: 这里tput用来更改终端文本属性,比如加粗，高亮等]
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`
#Help function
function HELP {
echo -e \\n"Help documentation for ${BOLD}${SCRIPT}.${NORM}"\\n
echo -e "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT ${NORM}"\\n
echo "Command line switches are optional. The following switches are recognized."
echo "${REV}-a${NORM} --Remove all containers."
echo "${REV}-e${NORM} --Sets the exception for container name ${BOLD}a${NORM}. Default is ${BOLD}no exception${NORM}."
echo -e "${REV}-h${NORM} --Displays this help message. No further functions are performed."\\n
echo -e "Example: ${BOLD}$SCRIPT -e env_ ${NORM}"\\n
exit 1
}


#check if the container should be removed
FILTER=1
CONTS_TO_BE_DEL=""
CONT_PREFIXS=""
function FILTER_CONTAINER {
for CONTAINER in $CONTAINERS
do
	if [ $CONTAINER = "NAMES" ]; then
		# exclude the colume name
		continue
	fi

	IF_DELETED=1
	for PREFIX in $CONTPREFIXS
	do
		if [[ $CONTAINER = $PREFIX* ]]; then
			IF_DELETED=0
			break
		fi
	done

	if [ $IF_DELETED -eq 1 ]; then
		CONTS_TO_BE_DEL="${CONTS_TO_BE_DEL} ${CONTAINER}"
	fi
done
}

#remove the container 
function DEL_CONTAINER {
docker rm -f -v ${CONTS_TO_BE_DEL}
}

function DEL_IMAGES {
GARBADGE_IMG=`docker images -f "dangling=true" -q`
if [ $GARBADGE_IMG"" != "" ]; then
docker rmi $GARBADGE_IMG
fi
}


#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
if [ $NUMARGS -eq 0 ]; then
	HELP
fi

#Parse command line flags
#如果选项需要后跟参数，在选项后面加":"
#注意"-h"选项后面没有":"，因为他不需要参数。选项字符串最开始的":"是用来去掉来自getopts本身的报错的，同时获取不能识别的选项。（译注：如果选项字符串不以":"开头，发生错误（非法的选项或者缺少参数）时，getopts会向错误输出打印错误信息；如果以":"开头，则不会打印[在man中叫slient error reporting]，同时将出错的选项赋给OPTARG变量）
while getopts :ae:h FLAG;do
	case $FLAG in
		a)#set option "a"
			FILTER=0
			;;
		e)#set option "e"
			CONTPREFIXS=$OPTARG
			;;
		h)#show help
			HELP
			;;
		\?)#unrecognized option - show help
			echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
			HELP
			;;
	esac
done
shift $((OPTIND-1))   #This tells getopts to move on to the next argument.

### Main loop to process files ###
CONTAINERS=`docker ps -a |awk '{print $NF}'`
if [[ $FILTER -eq 1 ]]; then
	FILTER_CONTAINER
fi
DEL_CONTAINER
DEL_IMAGES

### End main loop ###
exit 0

