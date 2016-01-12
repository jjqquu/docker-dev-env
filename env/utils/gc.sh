#!/bin/bash

#Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`

#Initialize variables to default values.
PROJPREFIXS=""

#Set fonts for Help.[译注: 这里tput用来更改终端文本属性,比如加粗，高亮等]
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`
#Help function
function HELP {
echo -e \\n"Help documentation for ${BOLD}${SCRIPT}.${NORM}"\\n
echo -e "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT ${NORM}"\\n
echo "Command line switches are optional. The following switches are recognized."
echo "${REV}-p${NORM} --Sets the docker-compose project name list ${BOLD}a${NORM}. Default is ${BOLD}no exception${NORM}."
echo -e "${REV}-h${NORM} --Displays this help message. No further functions are performed."\\n
echo -e 'Example: ${BOLD}$SCRIPT -p "env javademo"${NORM}'\\n
exit 1
}

#check if the container should be gced
function GC_CONTAINER {
# step 1: check & gc those containers whose image is out of date
IMAGES=`docker ps -a |awk '{print $2}' |uniq`
IMAGES_TO_BE_DEL=""
for IMAGE in $IMAGES
do
	if [ $IMAGE = "ID" ]; then
		# exclude the colume name
		continue
	fi

	IF_DELETED=1
	for PREFIX in $PROJPREFIXS
	do
		if [[ $IMAGE = $PREFIX* ]]; then
			IF_DELETED=0
			break
		fi
	done

	if [ $IF_DELETED -eq 1 ]; then
		IMAGES_TO_BE_DEL="${IMAGES_TO_BE_DEL} ${IMAGE}"
	fi
done

for IMAGE in $IMAGES_TO_BE_DEL
do
	CONTAINERS=$(docker ps -a | grep $IMAGE | awk '{print $NF}')

	for CONTAINER in $CONTAINERS
	do
		if [[ $CONTAINER = $IMAGE* ]]; then 
			echo
		else
			CONTS_TO_BE_DEL="${CONTS_TO_BE_DEL} ${CONTAINER}"
		fi
	done
done

RM_CONTAINER

# step 2: check & gc those containers whose name is out of date
CONTAINERS=`docker ps -a |awk '{print $NF}'`

CONTS_TO_BE_DEL=""
for CONTAINER in $CONTAINERS
do
        if [ $CONTAINER = "NAMES" ]; then
                # exclude the colume name
                continue
        fi

        IF_DELETED=1
        for PREFIX in $PROJPREFIXS
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

RM_CONTAINER
}

function RM_CONTAINER {
if [[ $CONTS_TO_BE_DEL"" != "" ]]; then
	docker ps -a
        echo -e "Container: ${BOLD}$CONTS_TO_BE_DEL ${NORM} will be ${BOLD}removed${NORM}"\\n
        read -p "Are you sure? " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
                docker rm -f -v ${CONTS_TO_BE_DEL}
	else
		exit 0
        fi
fi
}

function GC_IMAGES {
GARBADGE_IMG=`docker images -f "dangling=true" -q`
if [[ $GARBADGE_IMG"" != "" ]]; then
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
while getopts :p:h FLAG;do
	case $FLAG in
		p)#set option "p"
			PROJPREFIXS=$OPTARG
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
GC_CONTAINER
GC_IMAGES

### End main loop ###
exit 0

