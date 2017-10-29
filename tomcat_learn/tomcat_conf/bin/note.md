# Tomcat启动脚本的说明
### 1. startup.sh & shutdown.sh
    主要的作用就是用来寻找当前系统环境的一些变量信息，同时找到catalina.sh文件的真实路径进行启动，避免出现错误
    实际中我们可以使用catalina.sh start|stop|restart进行操作即可启动tomcat.
