# Tomcat配置文件
    Tomcat依赖<CATALINA_HOME>/conf/server.xml这个配置文件启动server（一个Tomcat实例，核心就是启动容器Catalina）。

    Tomcat部署Webapp时，依赖context.xml和web.xml（<CATALINA_HOME>/conf/目录下的context.xml和web.xml
    在部署任何webapp时都会启动，他们定义一些默认行为，而具体每个webapp的  META-INF/context.xml  和  WEB-INF/web.xml
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
### 2. context.xml
    Tomcat 公用的环境配置，tomcat 服务器会定时去扫描这个文件。一旦发现文件被修改（时间戳改变了），就会自动重新加载这个文件，而不需要重启服务器。
    推荐在 $CATALINA_BASEconf/context.xml 中进行独立的配置。
    因为 server.xml是不可动态重加载的资源，服务器一旦启动了以后，要修改这个文件，就得重启服务器才能重新加载，而context.xml 文件则不然。
### 3. server.xml
    加载方式：
        通过  Digester 来解析Tomcat的  server.xml 配置文件


