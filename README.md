

[TOC]  

---

本文描述如何利用docker工具集(engine/machine/compose等）为一个简化的云应用（nginx＋jetty+memcached)搭建测试床（testbed），方便本地的调试与集成。

涵盖的内容内容如下：  
- 安装依赖的软件  
- 利用docker machine创建docker host
- 书写dockerfile来构建 docker image  
- 利用docker compose搭建集成环境  
- 调试java程序  

# 测试床的拓扑

   ![topology of testbed](http://cdn3.infoqstatic.com/statics_s1_20160105-0313u5/resource/articles/docker-source-code-analysis-part6/zh/resources/1224000.jpg)

几点解释：  

- 涉及的每个进程都以容器（docker container）的方式运行。  
  归功于docker虚拟化技术，每个进程都仿佛运行在独立的物理主机上，拥有自己独立的ip地址。
  
- 每个容器都使用网桥模式（bridge mode）  
  连接同一个docker0 bridge的container彼此可以通过ip直接通信，无需使用NAT或者其它技术。但是不建议直接使用各个容器的ip地址，而建议利用container的link机制（docker run的 link和name属性）来让container相互引用（link的container name会作为一条主机名记录添加到容器的/etc/hosts）。
  
- 所有容器都运行在同一个宿主机（host）上
  在Mac OSx上，host是一个运行精简版linux（boot2docker）的virtualbox；在linux（本文特指ubuntu）上，host就是你的物理机。  
  
  各个容器与外部Internet的通信:  
  
  - 出去的方向：归功于docker bridge模式的masquerade (NAT)，所有container可以直接与外部Internet通信  
  - 进入的方向：缺省情况下，host是不知道如何把流量转发到docker0的bridge上去，docker0也不知道转发给哪个container。但是，我们利用端口映射机制（docker run的 -p属性），是到达host某个端口的流量被转发到正确的容器  
  	
  	注意，进入的方向可能需要考虑host本身的防火墙设置（比如mac OSx上的virtualbox的NAT端口转发规则等等）  

可参考下面资料了解docker networking的原理:  
1. [docker network官方文档](<https://docs.docker.com/engine/userguide/networking/dockernetworks/>)  
2. [docker network 101](<http://www.dasblinkenlichten.com/docker-networking-101/>)  

# 测试床的搭建
## 依赖软件的安装 

* 如果你是mac osx用户

 按照 https://www.docker.com/docker-toolbox” 安装 docker－toolbox（Docker Client，Docker Machine，Docker Compose，Docker Kitematic，VirtualBox）

* 如果你是ubuntu用户
  
 1.安装最新版本的docker-engine

 `$ curl -sSL https://get.docker.com/ | sh`

 建议详细阅读 [官方安装手册](https://docs.docker.com/engine/installation/ubuntulinux/)
  
 2.安装最新版本的docker compose

 ```
 $ curl -L https://github.com/docker/compose/releases/download/1.5.2/run.sh 	/>usr/local/bin/docker-compose
 $ chmod +x /usr/local/bin/docker-compose
 ```

 建议详细阅读 [官方安装手册](https://docs.docker.com/compose/install/)
	
 注：在ubuntu上不需要安装虚拟机即可运行

## 开发环境脚本和demo的安装

假设你将整个开发环境目录搭建在“~/git/”下，
 
### 源码的下载  

 ```
  $ cd ~/git/    
  $ git clone https://github.com/jjqquu/docker-dev-env.git  
  $ cd docker-dev-env/env  
  $ ./bootstrap.sh  
 ```
bootstrap.sh脚本将build构建本demo所依赖的base images（centos，java, golang等等）

### env项目的安装与启动 

env是一个docker compose 项目（project），它用于定义，构建和启动3个通用辅助服务：  
- **docker registry**，用作private registry，目前主要是作image pull through cache  
- **dns**，一个本地的dnsmasq服务，方便添加域名帮助集成。目前没有用到
	配置文件是`env/dnsmasq/dnsmasq.hosts`  
- **nexus**，用作maven/sbt pull through cache，避免build时“download the internet”的问题([问题详细解释和解决方法](http://blog.flurdy.com/2014/11/dont-download-internet-share-maven-ivy-docker.html))。  
	对maven proxy的设置参考“docker-dev-env/javademo/jetty”, 在mvn调用时使用setting.xml指定nexus作为mirror。  
	对sbt proxy的设置，参见[sbt proxy官方文档](http://www.scala-sbt.org/0.13/docs/Proxy-Repositories.html)。  
	使用proxy的方式解决maven/sbt build时“download the internet”的问题，要优雅于使用bind mount volumn的方式，因为proxy在build时也适用。

 ```
  $ cd ~/git/docker-dev-env/env
  $ docker-compse up -d
 ```
 
docker compose 按照docker-compose.yml的定义构建和启动3个通用辅助服务。

之所以为env单独定义一个compose project，是使这3个服务的生命周期独立于其它project。这样，其它project在build的阶段也可以使用这几个服务。

###javademo项目的安装与启动  

java demo是一个docker compose 项目（project），它用于定义，构建和启动组成javademo的3个服务:  
- **nginx**，角色是web frontend，将收到的http请求转发给中间层业务服务器jetty。其配置文件参见"docker-dev-env/javademo/nginx/sites/default.conf"  
- **jetty**，角色是中间层业务服务，基于jetty＋guice＋jersey实现了restful的api，所有状态都存储在后台memcached里  
- **memcached**，角色是后台数据存储服务

 ```
  $ cd ~/git/docker-dev-env/javademo
  $ docker-compse up -d
 ```

docker compose 会按照docker-compose.yml的定义构建和启动组成javademo的3个服务。

### 测试床的验证

执行完上述操作，我们即可验证测试床工作是否正确。

```
查看运行的container
$ docker ps
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS                     PORTS                    NAMES
7d5bc563e664        javademo_nginx       "nginx -g 'daemon off"   4 days ago          Up 4 minutes               80/tcp, 443/tcp          javademo_nginx_1
d11df0579fcf        javademo_jetty       "java -Djava.security"   4 days ago          Up 4 minutes                                        javademo_jetty_1
c18e697aa479        javademo_memcached   "/docker-entrypoint.s"   4 days ago          Up 4 minutes               11211/tcp                javademo_memcached_1
19740aac04a6        env_registry         "registry /etc/docker"   4 days ago          Up 4 minutes               0.0.0.0:8082->5000/tcp   env_registry_1
0f6dd6ff00ef        env_nexus            "/bin/sh -c 'java   -"   4 days ago          Up 4 minutes               0.0.0.0:8081->8081/tcp   env_nexus_1
714fb8dc55a8        env_nexusdata        "/bin/bash"              4 days ago          Exited (0) 4 minutes ago                            env_nexusdata_1
b488e989604c        env_registrydata     "/bin/bash"              4 days ago          Exited (0) 4 minutes ago                            env_registrydata_1

连上nginx所在的container
$ docker exec -ti javademo_nginx_1 bash

验证restful服务工作正常
$  curl -X GET http://localhost/people?text=blabla
$  curl -X PUT -H "content-type: application/json" -d '{"name":"qjp", "age": 100}' http://localhost/people
$  curl -X GET http://localhost/people/qjp
$  curl -X POST -H "content-type: application/json" -d '{"name":"qjp", "age": 66}' http://localhost/people/qjp
$  curl -X GET http://localhost/people/qjp
$  curl -X DELETE http://localhost/people/qjp
$  curl -X GET http://localhost/people/qjp
  
```

# docker machine  
如果你是ubuntu用户，由于不需要安装machine即可在ubuntu上搭建测试床，所以忽略本节内容。如果你是mac OSx用户，则需要了解下面描述的docker machine的内容。  

Machine帮我们在自己的主机上创建运行docker环境的虚拟机。它自动创建虚拟机作为宿主机host，在host上安装docker，配置docker client，配置运行环境（比如ssh和virtualbox的 sync folder）等等。一个“machine” 即是一个docker host和配置好的client的组合。

Mac OSx上machine是基于Oracle的virtualbox，所以一些高级功能可以利用`VBoxManage`。比如，`env/utils/vbportpf.sh` 就利用`modifyvm`命令为host增加了端口转发规则。

machine的具体使用我们参考[官方使用手册](https://docs.docker.com/machine/)

## machine常用命令  

```
1. 调用create命令可创建一个docker主机

$ docker-machine create --driver virtualbox qjp
Running pre-create checks...
Creating machine...
(qjp) Creating VirtualBox VM...
(qjp) Creating SSH key...
(qjp) Starting VM...
Waiting for machine to be running, this may take a few minutes...
Machine is running, waiting for SSH to be available...
Detecting operating system of created instance...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect Docker to this machine, run: docker-machine env qjp

运行下面命令来配置你的shell
$ eval $(docker-machine env my-machine-name)
```

说明：在virtualbox创建一个docker虚拟机，也可以指定别的driver

```
2. 通过ls命令可查看当前已安装的主机

$  docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER   ERRORS
default   *        virtualbox   Running   tcp://192.168.99.100:2376           v1.9.1
qjp       -        virtualbox   Running   tcp://192.168.99.101:2376           v1.9.1
```


```
3. 可以通过docker-machine config dev查看docker client连接信息

$ docker-machine config qjp
--tlsverify
--tlscacert="/Users/qujinping/.docker/machine/certs/ca.pem"
--tlscert="/Users/qujinping/.docker/machine/certs/cert.pem"
--tlskey="/Users/qujinping/.docker/machine/certs/key.pem"
-H=tcp://192.168.99.101:2376

通过此命令可以构造docker相关命令,例如：

$ docker $(docker-machine config dev) run busybox echo hello world
```


```
4. 其他命令：
info（查看信息） 
stop（停止主机） 
kill（强制停止） 
start（启用主机）
restart（重启主机） 
rm（删除主机） 
ssh（登陆主机） 
url（获取docker的url） 
upgrade（升级docker）
```

# 如何利用compose定义自己的测试床

compose 是用来自动化搭建本地开放环境和持续集成（continuous integration）的利器。其使用基本上是一个3步的过程：  
1. 为你的每一个application进程定义dockerfile，这样它们可以在其它地方重新构建  
2. 把你的application进程组成服务（service），并为之定义docker-compose.yml，这样可以在一个隔离的环境里面组织它们协同运行  
3. 通过运行“docker-compose up”等命令，高度自动化地管理（start／stop／romove／build）service和包含的各个application  

## 定义dockerfile

### 文档
dockerfile编写的几篇重要文档:  
- [使用参考手册](https://docs.docker.com/engine/reference/builder/)   
- [最佳实践总结](https://docs.docker.com/engine/articles/dockerfile_best-practices/)
- [容器data volume的管理](https://docs.docker.com/engine/userguide/dockervolumes/)
- [项目atomic的dockerimage编写指南] (http://www.projectatomic.io/docs/docker-image-author-guidance/)

### 本demo所编写的docker image的层次
 
> **centos**
> > **jdk**  
> > > **env_nexus**  
> > > **env_nexusdata**  
> > > **mvn**  
> > > > **javademo_jetty**  

> > **javademo_nginx**  
> > **javademo_memcached** 
 
> > **golang**  
> > > **env_registry**  
> > > **env_registrydata**  

出于安全原因，我们不应该从公司外部的image repository去拉取image，而应该从公司private registery拉取我们自己build的 image。在编写其dockefile时，我们可以从<https://hub.docker.com>找参考。

#### 到如何写java app的dockerfile
可以参考:  
1. jetty app: javademo/jetty/Dockfile  
2. [java spring boot app docker](https://spring.io/guides/gs/spring-boot-docker/)  
3. [mesos marathon scala app](https://github.com/mesosphere/marathon)  

#### 到如何写golang app的dockerfile
可以参考:  
1. golang app: env/registry/Dockfile  

#### 到如何写c/c++ app的dockerfile
可以参考:  
1. c app: javademo/memcached/Dockfile  


## compose的使用

理论上讲，我们通过docker命令可以手工做到compose帮我们做的所有事情。compose只是把这一切用脚本的方式声明（delcare）和自动化了。

### 文档  

[官方手册](https://docs.docker.com/compose/) 描述了如何如何编写docker-compose.yml来定义如何构建和启动docker compose project里的各个容器。

### compose Yaml文件参考  

我们可以看到compose文件的基本结构如下：

```
memcached:
    build: memcached

nginx:
    build: nginx
    volumes:
      - "./nginx/sites/:/etc/nginx/conf.d"
      - "./nginx/certs/:/etc/nginx/certs"
      - "./nginx/logs/:/var/log/nginx"
      - "./nginx/www/:/var/www"
    links:
      - jetty

jetty:
    build: jetty
    links:
      - memcached
```

首先是定义一个服务名，随后为该服务中指定一些选项条目：  

`image`:镜像的ID
`build`:直接从pwd的Dockerfile来build，而非通过image选项来pull  
`links`：连接到那些容器。 每个占一行，格式为SERVICE[:ALIAS],例如 – db[:database]
`external_links`：连接到该compose.yaml文件之外的容器中，比如是提供共享或者通用服务的容器服务。格式同links  
`command`：替换默认的command命令  
`ports`: 导出端口。格式可以是：｀ports:-"3000"-"8000:8000"-"127.0.0.1:8001:8001"｀
`expose`：导出端口，但不映射到宿主机的端口上。它仅对links的容器开放。格式直接指定端口号即可。
`volumes`：加载路径作为卷，可以指定只读模式：  

```
volumes:-/var/lib/mysql
 - cache/:/tmp/cache
 -~/configs:/etc/configs/:ro
```
`volumes_from`：加载其他容器或者服务的所有卷

```
environment:- RACK_ENV=development
  - SESSION_SECRET
```
env_file：从一个文件中导入环境变量，文件的格式为RACK_ENV=development
extends:扩展另一个服务，可以覆盖其中的一些选项。一个sample如下：

```
common.yml
webapp:
  build:./webapp
  environment:- DEBUG=false- SEND_EMAILS=false
development.yml
web:extends:
    file: common.yml
    service: webapp
  ports:-"8000:8000"
  links:- db
  environment:- DEBUG=true
db:
  image: postgres
```

`net`：容器的网络模式，可以为”bridge”, “none”, “container:[name or id]”, “host”中的一个。
`dns`：可以设置一个或多个自定义的DNS地址。
`dns_search`:可以设置一个或多个DNS的扫描域。
其他的`working_dir, entrypoint, user, hostname, domainname, mem_limit, privileged, restart, stdin_open, tty, cpu_shares`，和`docker run`命令是一样的，这些命令都是单行的命令。

以上内容摘自：  [一个中文的说明](http://debugo.com/docker-compose/)

### docker-compose常用命令
`docker-compose up`，启动的容器都是在前台运行的。我们可以指定-d命令以daemon的方式启动容器。除此之外，docker-compose还支持下面参数：  
`--verbose`：输出详细信息  
`-f` 制定一个非docker-compose.yml命名的yaml文件  
`-p` 设置一个项目名称（默认是directory名）  
docker-compose的动作包括：  
`build`：构建服务  
`kill -s SIGINT`：给服务发送特定的信号。  
`logs`：输出日志  
`port`：输出绑定的端口  
`ps`：输出运行的容器  
`pull`：pull服务的image  
`rm`：删除停止的容器  
`run`: 运行某个服务，例如docker-compose run web python manage.py shell  
`start`：运行某个服务中存在的容器。  
`stop`:停止某个服务中存在的容器。  
`up`：create + run + attach容器到服务。  
`scale`：设置服务运行的容器数量。例如：docker-compose scale web=2 worker=3  

以上内容摘自：  [一个中文的说明](http://debugo.com/docker-compose/)

# debug测试床里的java程序
下文主体内容也适用于非java程序，因其显而易见，所以不赘述。

**强烈建议阅读下面参考资料**：  
1. [Debugging Java Apps in Containers: No Heavy Welding Gear Required](http://www.slideshare.net/dbryant_uk/j1-2015-debugging-java-apps-in-containers-no-heavy-welding-gear-required)  
2. [debugging java applications running in docker](https://www.opencredo.com/2015/11/03/debugging-java-applications-running-in-docker/)

前面提到，我们的各个application都运行在docker container里面。container级别，os级别和jvm界别的debug工具有哪些呢？

## container级别debug工具
登陆上正在运行或者已经启动的的<<container>>，去查看当前或者过去发生的问题  
`docker exec –it <<container>> /bin/bash`
 
查看某个docker container消耗的的 CPU and memory  
`docker stats <<contain>>`

查看docker daemon的消息：  
`docker info`

查看某个docker image或者container的详情  
`docker inspect <<image>> | <<contain>>`

## os级别debug工具  
登陆上正在运行的<<container>>  
`docker exec –it <<container>> /bin/bash`

```
OS debugging tools:
	top, htop, 
	ps, 
	mpstat, 
	free, df -h
	vmstat,
	iostat 
	/proc filesystem
		meminfo and vmstat not cgroup aware

network debugging tools:		
	tcpdump, 
	netstat, ntop
	dig (not nslookup)
	ping, traceroute
	lsof –u <<username>>		
```

## jvm级别debug工具
登陆上正在运行的<<container>>  
`docker exec –it <<container>> /bin/bash`

```
$jps
Local VM id (lvmid)

$jstat
JVM Statistics
-class 
-compiler 
-gcutil

$jstack
Stack trace
```
 
### java远程调试
当java应用出现问题时，我们还可以利用java remote debug机制([工作原理](https://www.ibm.com/developerworks/cn/opensource/os-eclipse-javadebug/))，对它进行跟踪调试。

jvm debugger 架构如下： 

```
             Components                      Debugger Interfaces

                 /    |--------------|
                /     |     VM       |
 debuggee -----(      |--------------|  <---- JVMTI - Java VM Tool Interface
                \     |   back-end   |
                 \    |--------------|
                 /           |
 comm channel --(            |  <------------ JDWP - Java Debug Wire Protocol
                 \           |
                 /    |--------------|
                /     |  front-end   |
 debugger -----(      |--------------|  <---- JDI - Java Debug Interface
                \     |      UI      |
                 \    |--------------|
```   
  

我们把java app当成远程host机上的debuggee，我们本机的java ide（如intellij）当成debugger，调试时的具体做法如下：

1. 在Dockerfile, 加上jvm启动参数如下, 使之成为debuggee 
"-Xdebug", "-Xrunjdwp:transport=dt_socket,address=62911,server=y,suspend=n", "-Xnoagent”

	参见javademo/jetty/Dockerfile

	注：按照[这篇博客](http://www.adam-bien.com/roller/abien/entry/what_are_the_options_of)下面设置可能性能会好一些，不过还没有验证
-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044

2. 在运行java app container时，加上端口映射，使得外部debugger可以访问该端口  
	参考javademo/docker-compose.yml  

	```
	jetty:
      build: jetty
    links:
      - memcached
    ports:
      - "62911:62911"
	```

3. 如果是在mac／windows上运行docker machine，由于虚拟机vm的原因，还需要加上 NAT 端口转发规则. 我们提供了env/utils/vbportpf.sh，用来查找，增加和删除NAT端口转发规则。  
	
	```  
	为host default加上一条端口映射规则，名字是javadebug，
	把host的62911映射到container的62911  
	$ env/utils/vbportpf.sh -n default -a javadebug -h 62911 -g 62911  
	
	罗列host default的所有端口映射规则  
	$ env/utils/vbportpf.sh -n default -l  
	
	删除host default的名为javadebug的端口映射规则
	$ env/utils/vbportpf.sh -n default -d javadebug
	```

4. 获得host的ip地址

	```
	$ docker-machine ip default
	192.168.99.100
	```
Point debugger to image host 


5. 在你的IDE里面配置remote debug  
	以jdb为例：`jdb -attach 192.168.99.100:62911 -sourcepath .`
	以intellij为例: `Run | Edit configurations | + | Remote`

	下面就可以愉快地跟踪调试了。
	
### image和container的垃圾回收
`env/utils/gc.sh -p “env javademo”`
