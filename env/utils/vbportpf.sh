#!/bin/bash

# docker－machine 是基于VirutalBox工作的

# 查询虚拟机及网络
# 查询虚拟机名称，默认启动的虚拟机名为boot2docker-vm
# $ VBoxManage list vms

# 查询boot2docker-vm虚拟机的网络状态
# $ VBoxManage showvminfo "default" | grep NIC

# 关闭运行中的虚拟机
# 由于Boot2Docker会自动运行VirtualBox中的虚拟机，所以在设置网络映射时必须先关闭运行中的虚拟机。否则，将出现The machine 'boot2docker' is already locked for a session (or being unlocked)的错误提示
# $ VBoxManage controlvm "boot2docker-vm" poweroff

# 修改虚拟机与Mac系统的网络映射
# 根据实际需要进行网络映射，其中
# 	rulename: 自定义规则名称
# 	hostip: Mac访问地址，可不填
# 	hostport: Mac映射端口
# 	guestip: 虚拟机访问地址，可不填
# 	guestport: 虚拟机映射端口
# $ VBoxManage modifyvm "default" --natpf1 "<Rule Name>,<tcp|udp>,<Host IP>,<Host Port>,<Guest IP>,<Guest Port>"

# 启动虚拟机
# 设置完成后重新启动虚拟机 $ VBoxManage startvm "boot2docker-vm"

# 其他 - 删除映射端口，也需要关闭虚拟机，删除命令如下
# $ VBoxManage modifyvm "default" --natpf1 delete <Rule Name>


#Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`

#Initialize variables to default values.
VMNAME="default"
RULENAME=""
IS_ADD=1
IS_LIST=0
HOST_PORT=""
GUEST_PORT=""

#Set fonts for Help.[译注: 这里tput用来更改终端文本属性,比如加粗，高亮等]
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`
#Help function
function HELP {
echo -e \\n"Help documentation for ${BOLD}${SCRIPT}.${NORM}"\\n
echo -e "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT ${NORM}"\\n
echo "Command line switches are optional. The following switches are recognized."
echo "${REV}-n${NORM} --Specifies the virutalbox vm name ${BOLD}${NORM}. Default is ${BOLD}default${NORM}."
echo "${REV}-a${NORM} --Specifies name of port forwarding rule to be added"
echo "${REV}-d${NORM} --Specifies name of port forwarding rule to be deleted"
echo "${REV}-h${NORM} --Specifies the host port"
echo "${REV}-g${NORM} --Specifies the guest port"
echo -e "${REV}-h${NORM} --Displays this help message. No further functions are performed."\\n
echo -e "Example: ${BOLD}$SCRIPT -n default -a javadebug -h 62911 -g 62911 ${NORM}"\\n
echo -e "     or: ${BOLD}$SCRIPT -n default -d javadebug ${NORM}"\\n
echo -e "     or: ${BOLD}$SCRIPT -n default -l ${NORM}"\\n
exit 1
}


#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
if [ $NUMARGS -eq 0 ]; then
	HELP
fi

#Parse command line flags
#如果选项需要后跟参数，在选项后面加":"
#注意"-h"选项后面没有":"，因为他不需要参数。选项字符串最开始的":"是用来去掉来自getopts本身的报错的，同时获取不能识别的选项。（译注：如果选项字符串不以":"开头，发生错误（非法的选项或者缺少参数）时，getopts会向错误输出打印错误信息；如果以":"开头，则不会打印[在man中叫slient error reporting]，同时将出错的选项赋给OPTARG变量）
while getopts :n:la:d:h:g: FLAG;do
	case $FLAG in
		n)#set option "n"
			VMNAME=$OPTARG
			;;
		l)#set option "l"
			IS_LIST=1
			;;
		a)#set option "a"
			RULENAME=$OPTARG
			;;
		d)#set option "d"
			RULENAME=$OPTARG
			IS_ADD=0
			;;
		h)#set option "h"
			HOST_PORT=$OPTARG
			;;
		g)#set option "g"
			GUEST_PORT=$OPTARG
			;;
		\?)#unrecognized option - show help
			echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
			HELP
			;;
	esac
done
shift $((OPTIND-1))   #This tells getopts to move on to the next argument.

### Main loop to process files ###
if [[ $IS_LIST -eq 1 ]]; then
	VBoxManage showvminfo ${VMNAME} |grep 'NIC 1'
	exit 0
fi

if [[ $IS_ADD -eq 1 && ($RULENAME = "" || $HOST_PORT = "" || $GUEST_PORT = "") ]]; then
	HELP
fi

if [[ $IS_ADD -eq 0 && $RULENAME = "" ]]; then
	HELP
fi

if [[ $IS_ADD -eq 1 ]]; then
	echo -e "virtualbox vm: ${BOLD}$VMNAME ${NORM} will be ${BOLD}restarted and ${RULENAME} will be added ${NORM}"\\n
	read -p "Are you sure? [n/Y]" -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		docker-machine stop $VMNAME 
		VBoxManage modifyvm $VMNAME --natpf1 $RULENAME,tcp,,$HOST_PORT,,$GUEST_PORT
		docker-machine start $VMNAME 
	else
		exit 0
	fi
else
	echo -e "virtualbox vm: ${BOLD}$VMNAME ${NORM} will be ${BOLD}restarted and ${RULENAME} will be deleted ${NORM}"\\n
	read -p "Are you sure? [n/Y]" -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		docker-machine stop $VMNAME 
		VBoxManage modifyvm $VMNAME --natpf1 delete $RULENAME
		docker-machine start $VMNAME
	else
		exit 0
	fi
fi

### End main loop ###
exit 0

