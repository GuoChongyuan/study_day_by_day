#!/bin/sh
# tomcat的startup.sh脚本主要用来判断环境，找到catalina.sh脚本源路径，
# 将启动命令参数传递给catalina.sh执行。然而catalina.sh脚本中也涉及
# 到判断系统环境和找到catalina.sh脚本原路径的相关代码，
# 所以执行tomcat启动时，无需使用startup.sh脚本（下一篇分析的shutdown.sh也类似），
# 直接./catalina.sh start|stop|restart 即可。
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# -----------------------------------------------------------------------------
# Start Script for the CATALINA Server
#
# $Id: startup.sh 1130937 2011-06-03 08:27:13Z markt $
# -----------------------------------------------------------------------------
# Better OS/400 detection: see Bugzilla 31132
os400=false
darwin=false
#os400是 IBM的AIX
#darwin是MacOSX 操作环境的操作系统成份
#Darwin是windows平台上运行的类UNIX模拟环境
case "`uname`" in
CYGWIN*) cygwin=true;;
OS400*) os400=true;;
Darwin*) darwin=true;;
esac
#上一个判断是为了判断操作系统，至于何用，往下看
# resolve links - $0 may be a softlink
#读取脚本名
PRG="$0"
#test –h File 文件存在并且是一个符号链接（同-L）
while [ -h "$PRG" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done
#上面循环语句的意思是保证文件路径不是一个连接，使用循环直至找到文件原地址expr 'lrwxrwxrwx 1 root root 19 3月  17 10:12 ./bbb.sh -> /root/shell/test.sh' : '.*-> \(.*\)$'
#遇到一时看不明白的shell，可以拆解后自己在linux反复运行验证，一点点拆解就会明白的
#link=`expr "$ls" : '.*-> \(.*\)$'` 模拟后：
#很明确的发现是用expr来提取/root/shell/test.sh的内容
#而这个循环就可以明确其目的，排除命令为链接，找出命令真正的目录，防止后面的命令出错
#这段代码如果在以后有这方面的找出链接源头的需求可以完全借鉴

#获取这个脚本的目录
PRGDIR=`dirname "$PRG"`
EXECUTABLE=catalina.sh
# Check that target executable exists
#这些判断是否气是其他的操作系统
if $os400; then
  # -x will Only work on the os400 if the files are:
  # 1. owned by the user
  # 2. owned by the PRIMARY group of the user
  # this will not work if the user belongs in secondary groups
  eval
  #不用扫描直接执行
else
  if [ ! -x "$PRGDIR"/"$EXECUTABLE" ]; then
  #判断脚本catalina.sh是否存在并有可执行权限，没有执行权限就退出
    echo "Cannot find $PRGDIR/$EXECUTABLE"
    echo "The file is absent or does not have execute permission"
    echo "This file is needed to run this program"
    exit 1
  fi
fi
exec "$PRGDIR"/"$EXECUTABLE" start "$@"
#exec命令在执行时会把当前的shell process关闭，然后换到后面的命令继续执行。
#exec命令可以很好的进行脚本之间过渡，并且结束掉前一个脚本这样不会对后面执行的脚本造成干扰。
#exec 命令：常用来替代当前 shell 并重新启动一个 shell，换句话说，并没有启动子 shell。使用这一命令时任何现
#有环境都将会被清除。exec 在对文件描述符进行操作的时候，也只有在这时，exec 不会覆盖你当前的 shell 环境。
#exec 可以用于脚本执行完启动需要启动另一个脚本是使用，但须考虑到环境变量是否被继承。