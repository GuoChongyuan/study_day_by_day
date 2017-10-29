# Tomcat配置文件
    Tomcat依赖<CATALINA_HOME>/conf/server.xml这个配置文件启动server（一个Tomcat实例，核心就是启动容器Catalina）。

    Tomcat部署Webapp时，依赖context.xml和web.xml（<CATALINA_HOME>/conf/目录下的context.xml和web.xml
    在部署任何webapp时都会启动****_`****`_****，他们定义一些默认行为，而具体每个webapp的  META-INF/context.xml  和  WEB-INF/web.xml
    则定义了每个webapp特定的行为）两个配置文件部署web应用。
### 1.配置文件简介
    Tomcat 的配置文件并不多，由4个 xml 文件组成，分别是 context.xml、web.xml、server.xml、tomcat-users.xml 这几个文件。
    　server.xml: Tomcat的主配置文件，包含Service, Connector, Engine, Realm, Valve, Hosts主组件的相关配置信息；
    　web.xml：遵循Servlet规范标准的配置文件，用于配置servlet，并为所有的Web应用程序提供包括MIME映射等默认配置信息；
    　tomcat-user.xml：Realm认证时用到的相关角色、用户和密码等信息；Tomcat自带的manager默认情况下会用到此文件；在Tomcat中添加/删除用户，为用户　　指定角色等将通过编辑此文件实现；
    　catalina.policy：Java相关的安全策略配置文件，在系统资源级别上提供访问控制的能力；
    　catalina.properties：Tomcat内部package的定义及访问相关控制，也包括对通过类装载器装载的内容的控制；Tomcat在启动时会事先读取此文件的相关设置；
    　logging.properties: Tomcat6通过自己内部实现的JAVA日志记录器来记录操作相关的日志，此文件即为日志记录器相关的配置信息，可以用来定义日志记录的组　　件级别以及日志文件的存在位置等；
    　context.xml：所有host的默认配置信息；
### 2.server的组成部分
    Tomcat Server的组成部分

    1.1 – Server
    A Server element represents the entire Catalina servlet container. (Singleton)

    1.2 – Service
    A Service element represents the combination of one or more Connector components that share a single Engine
    Service是这样一个集合：它由一个或者多个Connector组成，以及一个Engine，负责处理所有Connector所获得的客户请求

    1.3 – Connector
    一个Connector将在某个指定端口上侦听客户请求，并将获得的请求交给Engine来处理，从Engine处获得回应并返回客户
    TOMCAT有两个典型的Connector，一个直接侦听来自browser的http请求，一个侦听来自其它WebServer的请求
    Coyote Http/1.1 Connector 在端口8080处侦听来自客户browser的http请求
    Coyote JK2 Connector 在端口8009处侦听来自其它WebServer(Apache)的servlet/jsp代理请求

    1.4 – Engine
    The Engine element represents the entire request processing machinery associated with a particular Service
    It receives and processes all requests from one or more Connectors
    and returns the completed response to the Connector for ultimate transmission back to the client
    Engine下可以配置多个虚拟主机Virtual Host，每个虚拟主机都有一个域名
    当Engine获得一个请求时，它把该请求匹配到某个Host上，然后把该请求交给该Host来处理
    Engine有一个默认虚拟主机，当请求无法匹配到任何一个Host上的时候，将交给该默认Host来处理

    1.5 – Host
    代表一个Virtual Host，虚拟主机，每个虚拟主机和某个网络域名Domain Name相匹配
    每个虚拟主机下都可以部署(deploy)一个或者多个Web App，每个Web App对应于一个Context，有一个Context path
    当Host获得一个请求时，将把该请求匹配到某个Context上，然后把该请求交给该Context来处理
    匹配的方法是“最长匹配”，所以一个path==”"的Context将成为该Host的默认Context
    所有无法和其它Context的路径名匹配的请求都将最终和该默认Context匹配

    1.6 – Context
    一个Context对应于一个Web Application，一个Web Application由一个或者多个Servlet组成
    Context在创建的时候将根据配置文件$CATALINA_HOME/conf/web.xml和$WEBAPP_HOME/WEB-INF/web.xml载入Servlet类
    当Context获得请求时，将在自己的映射表(mapping table)中寻找相匹配的Servlet类
    如果找到，则执行该类，获得请求的回应，并返回
### 3.【Tomcat的启动过程】
    Tomcat 先根据/conf/server.xml 下的配置启动Server，再加载Service，对于与Engine相匹配的Host，每个Host 下面都有一个或多个Context。
      　　注意：Context 既可配置在server.xml 下，也可配置成一单独的文件，放在conf\Catalina\localhost 下，简称应用配置文件。
      　　Web Application 对应一个Context，每个Web Application 由一个或多个Servlet 组成。当一个Web Application 被初始化的时候，它将用自己的ClassLoader 对象载入部署配置文件web.xml 中定义的每个Servlet 类：它首先载入在$CATALINA_HOME/conf/web.xml中部署的Servlet 类，然后载入在自己的Web Application 根目录下WEB-INF/web.xml 中部署的Servlet 类。
      web.xml 文件有两部分：Servlet 类定义和Servlet 映射定义。
      　　每个被载入的Servlet 类都有一个名字，且被填入该Context 的映射表(mapping table)中，和某种URL 路径对应。当该Context 获得请求时，将查询mapping table，找到被请求的Servlet，并执行以获得请求响应。
      　　所以，对于Tomcat 来说，主要就是以下这几个文件：conf 下的server.xml、web.xml，以及项目下的web.xml，加载就是读取这些配置文件。
### 2. context.xml
    Tomcat 公用的环境配置，tomcat 服务器会定时去扫描这个文件。一旦发现文件被修改（时间戳改变了），就会自动重新加载这个文件，而不需要重启服务器。
    推荐在 $CATALINA_BASEconf/context.xml 中进行独立的配置。
    因为 server.xml是不可动态重加载的资源，服务器一旦启动了以后，要修改这个文件，就得重启服务器才能重新加载，而context.xml 文件则不然。
### 3. server.xml
    加载方式：
        通过  Digester 来解析Tomcat的  server.xml 配置文件

### 4.tomcat_user.xml
    Tomcat已经为我们定义了4种不同的角色——也就是4个rolename，我们只需要使用Tomcat为我们定义的这几种角色就足够满足我们的工作需要了。

    以下是Tomcat Manager 4种角色的大致介绍(下面URL中的*为通配符)：

    manager-gui
    允许访问html接口(即URL路径为/manager/html/*)
    manager-script
    允许访问纯文本接口(即URL路径为/manager/text/*)
    manager-jmx
    允许访问JMX代理接口(即URL路径为/manager/jmxproxy/*)
    manager-status
    允许访问Tomcat只读状态页面(即URL路径为/manager/status/*)
    从Tomcat Manager内部配置文件中可以得知，manager-gui、manager-script、manager-jmx均具备manager-status的权限，
    也就是说，manager-gui、manager-script、manager-jmx三种角色权限无需再额外添加manager-status权限，即可直接访问路径/manager/status/*。
#### 远程访问manager(/conf/Catalina/localhost/下  添加manager.xml)
```xml
    <Context privileged="true" antiResourceLocking="false"
             docBase="${catalina.home}/webapps/manager">
                 <Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="^.*$" />
    </Context>
```
# 代办：server.xml web.xml context.xml解析

