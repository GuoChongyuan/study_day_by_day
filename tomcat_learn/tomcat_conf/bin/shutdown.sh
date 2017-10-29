#!/bin/sh
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
# Stop script for the CATALINA Server
#
# $Id: shutdown.sh 1130937 2011-06-03 08:27:13Z markt $
# -----------------------------------------------------------------------------
# resolve links - $0 may be a softlink
PRG="$0"
while [ -h "$PRG" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done
#上面循环语句的意思是保证文件路径不是一个连接，使用循环直至找到文件原地址
#遇到一时看不明白的shell，可以拆解后自己在linux反复运行验证，一点点拆解就会明白的
#link=`expr "$ls" : '.*-> \(.*\)$'` 模拟后： expr 'lrwxrwxrwx 1 root root 19 3月  17 10:12 ./bbb.sh -> /root/shell/test.sh' : '.*-> \(.*\)$'
#很明确的发现是用expr来提取/root/shell/test.sh的内容
#获取这个脚本的目录
PRGDIR=`dirname "$PRG"`
EXECUTABLE=catalina.sh
# Check that target executable exists
if [ ! -x "$PRGDIR"/"$EXECUTABLE" ]; then
  echo "Cannot find $PRGDIR/$EXECUTABLE"
    #判断脚本catalina.sh是否存在并有可执行权限，没有执行权限就退出
  echo "The file is absent or does not have execute permission"
  echo "This file is needed to run this program"
  exit 1
fi
exec "$PRGDIR"/"$EXECUTABLE" stop "$@"
#exec命令在执行时会把当前的shell process关闭，然后换到后面的命令继续执行。
#exec命令可以很好的进行脚本之间过渡，并且结束掉前一个脚本这样不会对后面执行的脚本造成干扰。
#exec 命令：常用来替代当前 shell 并重新启动一个 shell，换句话说，并没有启动子 shell。使用这一命令时任何现
#有环境都将会被清除。exec 在对文件描述符进行操作的时候，也只有在这时，exec 不会覆盖你当前的 shell 环境。