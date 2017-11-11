# nginx_lu学习笔记
### 1.概述
    nginx是高性能、支持并发的高性能web服务请，以模块的形式提供各种服务。
    nginx的修改西需要用C开发，成本高，因此有了nginx_lua模块
    ngx_lua将lua解释器集成到nginx，采用lua脚本实现业务逻辑，可以降低成本。
### 2. nginx的特性

- 单一master-多worker
- 每个阶段都会注册handler，同时每一个配置指令只会注册在某个特定的阶段运行。
- 子请求（nginx内部的级联请求）
    “子请求”方式的通信是在同一个虚拟主机内部进行的，所以 Nginx 核心在实现“子请求”的时候，就只调用了若干个 C 函数，完全不涉及任何网络或者 UNIX 套接字（socket）通信。我们由此可以看出“子请求”的执行效率是极高的。
- 协程（contuine）
    协程类似一种多线程，与多线程的区别有：
    1. 协程并非os线程，所以创建、切换开销比线程相对要小。
    2. 协程与线程一样有自己的栈、局部变量等，但是协程的栈是在用户进程空间模拟的，所以创建、切换开销很小。
    3. 多线程程序是多个线程并发执行，也就是说在一瞬间有多个控制流在执行。而协程强调的是一种多个协程间协作的关系，只有当一个协程主动放弃执行权，另一个协程才能获得执行权，所以在某一瞬间，多个协程间只有一个在运行。
    4. 由于多个协程时只有一个在运行，所以对于临界区的访问不需要加锁，而多线程的情况则必须加锁。
    5. 多线程程序由于有多个控制流，所以程序的行为不可控，而多个协程的执行是由开发者定义的所以是可控的。
    Nginx的每个Worker进程都是在epoll或kqueue这样的事件模型之上，封装成协程，每个请求都有一个协程进行处理。这正好与Lua内建协程的模型是一致的，所以即使ngx_lua需要执行Lua，相对C有一定的开销，但依然能保证高并发能力。
### 3.nginx_lua
- 原理
    ngx_lua将Lua嵌入Nginx，可以让Nginx执行Lua脚本，并且高并发、非阻塞的处理各种请求。Lua内建协程，这样就可以很好的将异步回调转换成顺序调用的形式。ngx_lua在Lua中进行的IO操作都会委托给Nginx的事件模型，从而实现非阻塞调用。开发者可以采用串行的方式编写程序，ngx_lua会自动的在进行阻塞的IO操作时中断，保存上下文；然后将IO操作委托给Nginx事件处理机制，在IO操作完成后，ngx_lua会恢复上下文，程序继续执行，这些操作都是对用户程序透明的。 每个NginxWorker进程持有一个Lua解释器或者LuaJIT实例，被这个Worker处理的所有请求共享这个实例。每个请求的Context会被Lua轻量级的协程分割，从而保证各个请求是独立的。 ngx_lua采用“one-coroutine-per-request”的处理模型，对于每个用户请求，ngx_lua会唤醒一个协程用于执行用户代码处理请求，当请求处理完成这个协程会被销毁。每个协程都有一个独立的全局环境（变量空间），继承于全局共享的、只读的“comman data”。所以，被用户代码注入全局空间的任何变量都不会影响其他请求的处理，并且这些变量在请求处理完成后会被释放，这样就保证所有的用户代码都运行在一个“sandbox”（沙箱），这个沙箱与请求具有相同的生命周期。 得益于Lua协程的支持，ngx_lua在处理10000个并发请求时只需要很少的内存。根据测试，ngx_lua处理每个请求只需要2KB的内存，如果使用LuaJIT则会更少。所以ngx_lua非常适合用于实现可扩展的、高并发的服务。
- 典型应用
    官网上列出:
    · Mashup’ing and processing outputs of various nginx upstream outputs(proxy, drizzle, postgres, redis, memcached, and etc) in Lua, · doing arbitrarily complex access control and security checks in Luabefore requests actually reach the upstream backends, · manipulating response headers in an arbitrary way (by Lua) · fetching backend information from external storage backends (likeredis, memcached, mysql, postgresql) and use that information to choose whichupstream backend to access on-the-fly, · coding up arbitrarily complex web applications in a content handlerusing synchronous but still non-blocking access to the database backends andother storage, · doing very complex URL dispatch in Lua at rewrite phase, · using Lua to implement advanced caching mechanism for nginxsubrequests and arbitrary locations.
- 用法
    ngx_lua模块提供了配置指令和Nginx API。
    配置指令：在Nginx中使用，和set指令和pass_proxy指令使用方法一样，每个指令都有使用的context。
    Nginx API：用于在Lua脚本中访问Nginx变量，调用Nginx提供的函数。
- 注意点
    1. Nginx提供了强大的编程模型，location相当于函数，子请求相当于函数调用，并且location还可以向自己发送子请求，这样构成一个递归的模型，所以采用这种模型实现复杂的业务逻辑。
    2. Nginx的IO操作必须是非阻塞的，如果Nginx在那阻着，则会大大降低Nginx的性能。所以在Lua中必须通过ngx.location.capture发出子请求将这些IO操作委托给Nginx的事件模型。
    3. 在需要使用tcp连接时，尽量使用连接池。这样可以消除大量的建立、释放连接的开销。
### 4. lua应用
    实际上就是使用c语言将uri进行拦截，根据不同的uri定位到不同的nginx的upstream文件。

