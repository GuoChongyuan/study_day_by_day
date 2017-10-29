#!/bin/sh
#因为setclasspath.sh脚本是被catalina.sh调用，所以可以继承catalina.sh中的变量申明
if [ -z "$JAVA_HOME" -a -z "$JRE_HOME" ]; then
#判断用户有没有提前做$JAVA_HOME和$JRE_HOME全局变量声明，如果都没进行申明
  # Bugzilla 37284 (reviewed).
  if $darwin; then
  #要理解这个判断，先看下startup.sh和shutdown.sh就会明白
  #这个是win仿真unix不用管下面两个语句
    if [ -d "/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home" ]; then
      export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home"
    fi
  else
  #其他环境没有申明，那么系统自己想办法找这两个变量的路径
    JAVA_PATH=`which java 2>/dev/null`
#此语句可以把java命令位置找出来
    if [ "x$JAVA_PATH" != "x" ]; then
#如果能找出java路径，则可以定位到java命令的路径，经过作者验证不是java的装路径
#所以通过此处就可以看出，老鸟们为什么都要自己指定这两个变量了
      JAVA_PATH=`dirname $JAVA_PATH 2>/dev/null`
      JRE_HOME=`dirname $JAVA_PATH 2>/dev/null`
    fi
    if [ "x$JRE_HOME" = "x" ]; then
#如果找不到java路径，那么就看有没有/usr/bin/java这个执行文件，有的话就它了，没有就算了
      # XXX: Should we try other locations?
      if [ -x /usr/bin/java ]; then
        JRE_HOME=/usr
      fi
    fi
  fi

  if [ -z "$JAVA_HOME" -a -z "$JRE_HOME" ]; then
  #再验证一边，有没有这两个变量，没有不好意思，我不执行了，退出
  #这个exit 1 不但是结束setclasspath.sh，会彻底退出catalina.sh脚本的
  #对于在脚本中引用脚本的童鞋们，就需要注意了，小心使用exit。
    echo "Neither the JAVA_HOME nor the JRE_HOME environment variable is defined"
    echo "At least one of these environment variable is needed to run this program"
    exit 1
  fi
fi
if [ -z "$JAVA_HOME" -a "$1" = "debug" ]; then
  echo "JAVA_HOME should point to a JDK in order to run in debug mode."
  exit 1
fi
if [ -z "$JRE_HOME" ]; then
  JRE_HOME="$JAVA_HOME"
fi
# If we're running under jdb, we need a full jdk.
if [ "$1" = "debug" ] ; then
  if [ "$os400" = "true" ]; then
    if [ ! -x "$JAVA_HOME"/bin/java -o ! -x "$JAVA_HOME"/bin/javac ]; then
      echo "The JAVA_HOME environment variable is not defined correctly"
      echo "This environment variable is needed to run this program"
      echo "NB: JAVA_HOME should point to a JDK not a JRE"
      exit 1
    fi
  else
    if [ ! -x "$JAVA_HOME"/bin/java -o ! -x "$JAVA_HOME"/bin/jdb -o ! -x "$JAVA_HOME"/bin/javac ]; then
      echo "The JAVA_HOME environment variable is not defined correctly"
      echo "This environment variable is needed to run this program"
      echo "NB: JAVA_HOME should point to a JDK not a JRE"
      exit 1
    fi
  fi
fi
#上段的代码都是在确认$JAVA_HOME和$JRE_HOME变量的申明情况及后续的解决过程
if [ -z "$BASEDIR" ]; then
#对"$BASEDIR变量的检查，木有的话就退出
  echo "The BASEDIR environment variable is not defined"
  echo "This environment variable is needed to run this program"
  exit 1
fi
if [ ! -x "$BASEDIR"/bin/setclasspath.sh ]; then
#确认"$BASEDIR"/bin/setclasspath.sh有木有，木有还是退出
  if $os400; then
    # -x will Only work on the os400 if the files are:
    # 1. owned by the user
    # 2. owned by the PRIMARY group of the user
    # this will not work if the user belongs in secondary groups
    eval
  else
    echo "The BASEDIR environment variable is not defined correctly"
    echo "This environment variable is needed to run this program"
    exit 1
  fi
fi
# Don't override the endorsed dir if the user has set it previously
#这个是确认JAVA_ENDORSED_DIRS的位置
if [ -z "$JAVA_ENDORSED_DIRS" ]; then
  # Set the default -Djava.endorsed.dirs argument
  JAVA_ENDORSED_DIRS="$BASEDIR"/endorsed
fi
# OSX hack to CLASSPATH
JIKESPATH=
if [ `uname -s` = "Darwin" ]; then
  OSXHACK="/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Classes"
  if [ -d "$OSXHACK" ]; then
    for i in "$OSXHACK"/*.jar; do
      JIKESPATH="$JIKESPATH":"$i"
    done
  fi
fi
# Set standard commands for invoking Java.
#这句是响当当的重要，确定了$_RUNJAVA的值
_RUNJAVA="$JRE_HOME"/bin/java
if [ "$os400" != "true" ]; then
  _RUNJDB="$JAVA_HOME"/bin/jdb
fi