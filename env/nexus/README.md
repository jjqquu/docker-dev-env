
# 如何搭建本地的nexus

## 概念
[nexus官方文档](http://books.sonatype.com/nexus-book/reference/confignx-sect-manage-repo.html)介绍了3种类型的repository：proxy，hosted和virtual。
而group类型的repository则是将上述类型的多个repository组合成一个逻辑上的repository。  

## 如何配置与管理  
通过http://192.168.99.100:8081/, 登陆的口令缺省是admin/admin123

## 使用本地的nexus作为proxy  
详情参考[nexus官方文档](http://repository.jboss.org/nexus/content/repositories/releases)

1. maven  
	${user.home}/.m2/settings.xml

	```
<settings>  
        <mirrors>  
                 <mirror>
                         <id>Nexus</id>
                         <name>Nexus Public Mirror</name>
                         <url>http://172.17.0.1:8081/content/groups/public</url>
                         <mirrorOf>*</mirrorOf>
                 </mirror>
         </mirrors>
</settings>
```

1. sbt  
	${user.home}/.sbt/repositories

	```
[repositories]
local
my-ivy-proxy-releases: http://172.17.0.1:8081/content/groups/ivy-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
my-maven-proxy-releases: http://172.17.0.1:8081/content/groups/public/
```
	运行sbt时加上 "-Dsbt.override.build.repos=true"

1. 常见问题  
 * sbt需要升级到0.13.9，否则会有[Maven Range-versioned dependencies issue](https://github.com/sbt/sbt/issues/752)  
 * nexus 服务想要区分ivy还是maven repository, 并把它们放到正确的repository group里面去
 * nexus repository policy 分为snapshot/release两种，设为release，则只能去release的artifact，snapshot亦然。所以要注意dependency是snapshot还是release.

