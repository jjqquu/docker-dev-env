#!/bin/bash

# docker－machine 是基于VirutalBox工作的

# 查询虚拟机及网络
# 查询虚拟机名称，默认启动的虚拟机名为boot2docker-vm
# $ VBoxManage list vms

# 查询boot2docker-vm虚拟机的网络状态
# $ VBoxManage showvminfo "boot2docker-vm" | grep NIC

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
# $ VBoxManage modifyvm "boot2docker-vm" --natpf1 "<Rule Name>,<tcp|udp>,<Host IP>,<Host Port>,<Guest IP>,<Guest Port>"

# 启动虚拟机
# 设置完成后重新启动虚拟机 $ VBoxManage startvm "boot2docker-vm"

# 其他 - 删除映射端口，也需要关闭虚拟机，删除命令如下
# $ VBoxManage modifyvm "boot2docker-vm" --natpf1 delete

if  [ $# -eq 1 ]; then
	echo "hello"
fi

