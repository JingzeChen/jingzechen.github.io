---
uid: cmu-csapp-f15-module-06
type: course
document_type: module
course: cmu-csapp-f15
module_number: 6
title: 模块 06：网络编程
description: 连接 Lecture 21–22 的概念、证据与掌握路径。
excerpt: 连接 Lecture 21–22 的概念、证据与掌握路径。
content_lang: zh-CN
permalink: "/courses/cmu-csapp-f15/modules/06/"
toc: true
---

{% raw %}
> 对应课程顺序：Lecture 21 **Network Programming: Part I** -> Lecture 22 **Network Programming: Part II**。  
> 本指南只重组两讲课堂笔记中已经出现的内容；时间戳、课件页和所有边界判断均来自下列两份证据。

## 证据来源

- **L21**：[Lecture 21 NOTES.md：Network Programming: Part I](/courses/cmu-csapp-f15/lectures/021/)
- **L22**：[Lecture 22 NOTES.md：Network Programming: Part II](/courses/cmu-csapp-f15/lectures/022/)

Lecture 21 从网络、client-server role、TCP/IP、地址与名称逐步走到原始 socket 生命周期和 `getaddrinfo`。Lecture 22 先完成协议无关的 client/server helpers，再用 echo 验证 descriptor 模型，最后把同一条 connected byte stream 提升为 HTTP、Tiny Web Server 和 CGI。这个先后关系是本模块的主线。

## 1. 先修知识：先知道每一层依赖什么

### 1.1 网络层面的先修

1. **host 与 NIC**：主机通过 network adapter/NIC 接入网络；对主机而言，NIC 是 I/O device。（L21 00:03:49-00:05:15；课件 p.3）
2. **LAN 与 internet**：hub 广播，bridge/switch 学习端口可达性并选择性转发 frame；router 连接可能不兼容的 LAN/WAN，形成小写 `internet`。大写 `Internet` 是 Global IP Internet 这个具体实例。（L21 00:05:15-00:16:06；课件 p.4-p.12）
3. **packet 与 frame**：跨 internet 的 packet 带 `PH`；每一段本地 LAN 再包一层自己的 `FH`。跨 router 时本地 frame 包装可改变，Internet packet 被继续承载。（L21 00:13:57-00:16:06；课件 p.12）
4. **IP、UDP、TCP**：IP 提供 host-to-host best-effort datagram；UDP 提供 process-to-process unreliable datagram；TCP 在 IP 上通过重传和重排向应用提供可靠、有序、双向的 process-to-process byte stream。（L21 00:16:06-00:19:46；课件 p.14）

本模块只使用课堂给出的程序员视角。路由算法、拓扑变化、不同最大 frame size 等网络内部问题被明确留给完整的 networking 课程；UDP 也只作为对照出现，没有继续展开。（L21 00:11:45-00:12:02，00:16:49-00:18:01；课件 p.13-p.14）

### 1.2 client-server 层面的先修

- client 与 server 是 **process roles**，不是两种永久固定的机器。它们可位于相同或不同 hosts，同一参与方也可在不同交互中改变角色。（L21 00:01:32-00:03:49；课件 p.2）
- 一次基本事务是：client request -> server 操作其管理的 resource -> server response -> client 处理结果。（L21 00:01:50-00:03:49）
- server 必须先建立可等待连接的端点；client 随后主动连接。连接建立后的 session 如何组织 messages，由 application protocol 决定。（L21 00:45:54-00:48:41；L22 00:04:22-00:06:43）
- client 关闭当前连接，不等于 server process 退出。server 在对应 connected descriptor 上读到 EOF，关闭该会话后可以回到 `accept`。（L21 01:02:22-01:04:13；L22 00:05:49-00:06:43）

### 1.3 socket 与系统知识的先修

1. **Unix I/O**：理解 file descriptor、`read`、`write`、`close` 和 EOF。socket 在应用层就是可读写的 descriptor；统一的是接口，不是 NIC 与磁盘的底层实现。（L21 00:04:19-00:05:15，00:41:59-00:43:11）
2. **process 与 kernel**：应用调用 sockets API；kernel 实现 TCP/IP、按端口和 connection 信息分派数据，并管理 socket 状态。（L21 00:19:46-00:20:39，00:40:47-00:41:28）
3. **C structures、pointers 与 casts**：socket API 使用 generic `sockaddr`、family-specific structures 和 pointer casts；这是早期 C 接口留下的形态。（L21 00:24:15-00:25:21，00:43:11-00:45:54）
4. **linked list 与资源释放**：`getaddrinfo` 返回 null-terminated `addrinfo` list，调用者遍历后必须 `freeaddrinfo`。（L21 01:04:13-01:13:15）
5. **RIO**：echo 和后续 server 代码依赖 reliable buffered line I/O 与 reliable writes。（L22 00:40:03-00:46:36；课件 p.25-p.27）
6. **进程控制与 VM**：Tiny 的动态路径依赖 `fork`、`execve`、`wait`、`dup2`；静态路径依赖 `mmap`。（L22 01:02:12-01:03:10，01:07:16-01:14:08；课件 p.40、p.50）

## 2. Part I：从 Internet 抽象走到 socket

### 2.1 从应用 bytes 到可读写的 TCP stream

```text
application bytes
  -> Internet packet [PH | payload]
  -> current-LAN frame [FH | PH | payload]
  -> IP best-effort datagrams
  -> TCP segmentation / retransmission / reordering
  -> reliable full-duplex byte stream
  -> application read/write on a socket descriptor
```

课堂先保留 packet 网络的不可靠现实，再由 TCP 把 packet boundary、丢失和乱序隐藏在应用接口之下。因此，“socket 像文件”只表示应用可以读写一个 descriptor；它不表示网络底层真的等同于 disk I/O。（L21 00:13:57-00:20:39，00:42:18-00:43:11；课件 p.12、p.14-p.15）

### 2.2 从 host 身份到 connection 身份

一个 IPv4 address 只定位 host；同一 host 还能同时运行 SSH、FTP、mail、Web 等 services，所以必须用 16-bit port 再定位 host 内的 process endpoint。（L21 00:37:03-00:39:39）

```text
socket address = IP address : port

connection identity =
  (client IP : client ephemeral port,
   server IP : server service port)
```

- server 通常使用约定的 well-known service port。
- client 通常由 kernel 临时分配 ephemeral port，只在该 connection 期间使用。
- 同一 server service port 可以同时对应不同 connections；区别来自完整的两端 socket addresses，并在 server process 中表现为不同 connected descriptors。（L21 00:39:00-00:41:59，01:01:20-01:02:22；课件 p.16）

### 2.3 字节序、地址、名称解析与 socket 接口依赖图

```text
人类输入
  host string: domain name / dotted-decimal IPv4 / IPv6 text
  service string: service name / numeric port
        |
        v
DNS multi-mapping（名称查询时） + presentation conversion
        |
        v
getaddrinfo(host, service, hints, &listp)
        |
        v
addrinfo candidate list -> ... -> NULL
  | ai_family / ai_socktype / ai_protocol
  |          -> socket(...)
  |
  | ai_addr / ai_addrlen
  |          -> connect(...) 或 bind(...)
  |
  + ai_next -> 下一个候选
        |
        +-> getnameinfo(socket address, ...)
              -> host/service text 或 numeric presentation
```

这张图依赖以下边界，不能把它们压成同一种“地址转换”：

| 层次 | 课堂对象 | 解决的问题 |
|---|---|---|
| 地址本体 | IPv4 32-bit value；IPv6 128-bit value | host 的协议地址 |
| 网络表示 | big-endian network byte order | 多种 host byte order 之间的统一传输表示 |
| 人类表示 | IPv4 四段 `0-255` dotted decimal；IPv6 课堂演示为冒号分隔十六进制 | 把二进制地址写成文本 |
| 人类命名 | hierarchical domain name | 不要求用户记数字地址 |
| 名称解析 | DNS multi-mapping | name 可到零个、一个或多个 addresses；address 也可到多个 names |
| process endpoint | 16-bit port | 区分同一 host 上的 service/process |
| socket address | IP address + port | 表示一个 connection endpoint |
| C 通用接口 | `sockaddr` / `sockaddr_in` / `sockaddr_storage` | 让同一函数族接收不同 address family |
| 现代转换接口 | `getaddrinfo` / `getnameinfo` | 在 strings、候选地址结构与 socket calls 之间搭桥 |

证据要点：

- IPv4 的 dotted decimal 是 presentation form，不是地址本体；port 和 IPv4 address 放入 `sockaddr_in` 时使用 network byte order。（L21 00:20:39-00:27:51，00:43:11-00:45:54；L22 00:07:55-00:10:04；课件 22 p.4）
- DNS 不是单值函数：一名可多址、多名可一址、结果可变化，合法名称也可能没有 host address。程序不能假设一次查询结果的集合或顺序永久不变。（L21 00:29:40-00:36:00）
- `getaddrinfo` 返回候选 list，正是为了容纳这种多重性和 IPv4/IPv6 统一处理；程序应逐项尝试，而不是只信第一项。（L21 01:04:13-01:10:47；L22 00:09:52-00:20:25）
- `getnameinfo` 走反方向，但 DNS 多重映射意味着它不是数学双射。`NI_NUMERICHOST` 可要求 numeric text，而不是反查 domain name。（L21 01:10:47-01:16:20；课件 21 p.39-p.42）
- `localhost` 固定指当前 machine 的 loopback address `127.0.0.1`，适合单机同时测试 client/server；它不验证外部路由或跨机网络。（L21 01:15:01-01:15:43；课件 p.42）

### 2.4 原始 socket 生命周期

```text
Server                                      Client
getaddrinfo                                 getaddrinfo
socket                                      socket
bind
listen
accept  <------ connection request -------- connect
  |                                             |
  +-> connected descriptor               client descriptor
  |<------------ application I/O ------------->|
  |<------------------ EOF ----------------- close
close connected descriptor
loop back to accept
```

调用的状态含义如下：

1. `socket`：创建本地 socket state，返回整数 descriptor；此时尚未联系远端。（L21 00:50:06-00:53:20；L22 00:23:41-00:25:29）
2. `bind`：请求 kernel 将 server descriptor 与本机 address/service port 关联。（L21 00:53:20-00:55:14；L22 00:32:48-00:34:35）
3. `listen`：把默认的 active socket 转成 listening socket；它不能替代 `bind`。（L21 00:55:14-00:56:23；L22 00:34:09-00:35:28）
4. `accept`：通常阻塞等待 request；成功后保留 `listenfd`，另行返回只服务当前 client 的 `connfd`。（L21 00:56:23-00:57:46；L22 00:42:49-00:43:46）
5. `connect`：client 用 server socket address 发起连接；它才是实际联系远端的步骤。（L21 00:57:46-01:00:03；L22 00:21:03-00:25:38）
6. connected session：双方按 application protocol 对 connected descriptors 做 I/O。client close 后，server read 得到 EOF。（L21 01:02:22-01:03:12）

当前两讲使用的是 iterative server：一个 `connfd` 完成后才回到 `accept`。`listenfd`/`connfd` 的分离为以后并发处理提供结构前提，但本模块不能把后续 multithreading 当作这两讲已经实现的能力。（L21 01:03:12-01:04:13；L22 00:43:20-00:43:46）

## 3. Part II：把接口组织成可恢复的 client/server 模式

这里的“稳健”只指课堂代码已经展示的候选重试、失败清理、资源释放和 RIO 模式，不表示 production-grade robustness。Tiny 随后还被老师明确评价为顺序、功能裁剪且错误处理薄弱的教学 server。（L22 00:57:33-00:58:23；课件 p.38）

### 3.1 `open_clientfd`：逐候选连接并清理失败项

```text
zero hints
set SOCK_STREAM
set the classroom flags AI_NUMERICSERV and AI_ADDRCONFIG
getaddrinfo(hostname, port, hints) -> listp

for each candidate p:
    clientfd = socket(p.ai_family, p.ai_socktype, p.ai_protocol)
    if socket failed:
        continue

    if connect(clientfd, p.ai_addr, p.ai_addrlen) succeeded:
        break

    close(clientfd)

freeaddrinfo(listp)
if no candidate succeeded:
    return failure
return connected clientfd
```

关键不变量：

- `socket` 失败时没有可连接 descriptor，直接尝试下一候选。
- `connect` 失败时，本轮 descriptor 已创建，必须先关闭再尝试下一候选。
- 成功时保留 connected `clientfd`；无论成功与否都释放 `addrinfo` list。
- address family、socket type、protocol、address pointer 和 length 均取自当前 `addrinfo`，因此控制流不写死 IPv4。（L22 00:20:29-00:26:31；课件 p.19-p.20）

### 3.2 `open_listenfd`：逐候选绑定，再转换为监听状态

```text
zero hints
set SOCK_STREAM
set the classroom flags including AI_PASSIVE
use a numeric port string; host argument is NULL
getaddrinfo(NULL, port, hints) -> listp

for each candidate p:
    listenfd = socket(p.ai_family, p.ai_socktype, p.ai_protocol)
    if socket failed:
        continue

    set SO_REUSEADDR
    if bind(listenfd, p.ai_addr, p.ai_addrlen) succeeded:
        break

    close(listenfd)

freeaddrinfo(listp)
if no candidate bound:
    return failure
if listen(listenfd, LISTENQ) failed:
    close(listenfd)
    return failure
return listenfd
```

关键不变量：

- `NULL` host 与 `AI_PASSIVE` 用于本地被动 server 的课堂模式；port 仍作为 string 交给 `getaddrinfo`。（L22 00:28:35-00:29:59；课件 p.22）
- port 可能已被占用，进程也可能无权使用某些 port；`bind` 失败时关闭本轮 descriptor 并继续。（L22 00:32:48-00:33:56；课件 p.23）
- `SO_REUSEADDR` 在课件中用于消除某些 server 重启后的 `Address already in use` 问题。（L22 00:31:55-00:32:48；课件 p.23）
- `bind` 成功只表示取得本地 address/port；`listen` 成功后才得到 listening socket。（L22 00:34:09-00:35:44；课件 p.10、p.24）
- 老师当场明确说自己不记得 `AI_ADDRCONFIG` 的精确定义；本模块只保留它在课堂 helper 中出现，不补入课外语义。（L22 00:30:56-00:31:36）

### 3.3 echo client：一轮写请求，一轮读响应

```text
clientfd = Open_clientfd(host, port)
Rio_readinitb(&rio, clientfd)

while Fgets(buf, ..., stdin) is not EOF:
    Rio_writen(clientfd, buf, strlen(buf))
    Rio_readlineb(&rio, buf, ...)
    Fputs(buf, stdout)

Close(clientfd)
```

这个 client 的 application protocol 很简单：从标准输入取一行 -> 写连接 -> 从同一连接读回一行 -> 显示。它不是“连续写很多行后再统一读”；每轮严格形成一次 request/response。（L22 00:40:03-00:42:17；课件 p.25）

### 3.4 echo server：固定 `listenfd`，逐会话创建 `connfd`

```text
listenfd = Open_listenfd(port)

while true:
    clientlen = sizeof(sockaddr_storage)
    connfd = Accept(listenfd, &clientaddr, &clientlen)
    Getnameinfo(clientaddr, clientlen, client_hostname, client_port)
    echo(connfd)
    Close(connfd)
```

```text
echo(connfd):
    Rio_readinitb(&rio, connfd)
    while (n = Rio_readlineb(&rio, buf, ...)) != 0:
        report n
        Rio_writen(connfd, buf, n)
```

完整因果链是：

```text
client stdin
  -> clientfd
  -> server connfd
  -> server reads n bytes
  -> server writes the same n bytes
  -> clientfd
  -> client stdout

client Ctrl-D / close
  -> server Rio_readlineb returns 0 (EOF)
  -> echo returns
  -> server closes only connfd
  -> server loops to accept on the same listenfd
```

演示中 server port 为 `15213`，client 获得临时来源 port；重新连接时 client port 可以改变。第二个 client 在 server 正处理第一个 client 时不能被同时服务，这验证了 iterative 限制，但 transcript 没有精确判定它阻塞在连接建立、排队还是等待应用响应。（L22 00:35:44-00:39:42，00:39:42-00:46:36；课件 p.25-p.29）

`telnet <host> <port>` 在课堂中被用作发送 ASCII 的手工测试 client。老师明确说它不应再用于不安全的实际远程登录；这里的用途只是探测 echo、Web 等文本协议。（L22 00:46:41-00:48:11；课件 p.28-p.29）

## 4. 从 echo 到 Web：课堂实际推进顺序

### 4.1 HTTP 位于 TCP stream 之上

浏览器是 client，Web server 是 server。二者先建立 TCP connection，再按 HTTP 交换 request、response 和 Web content。因此 HTTP 没有替代 socket/TCP；它为 connected stream 上的 bytes 赋予应用层结构和含义。（L22 00:48:11-00:49:15；课件 p.30）

```text
IP datagrams
  -> TCP reliable stream
  -> socket descriptors
  -> HTTP request / response syntax
  -> typed Web content
```

### 4.2 Web content、MIME、静态与动态

课件把 Web content 定义为：**一串 bytes 加一个 associated MIME type**。课堂列出的例子包括 `text/html`、`text/plain`、`image/gif`、`image/png`、`image/jpeg`。（L22 00:49:40-00:50:43；课件 p.31）

- **静态内容**：已存在于文件，请求到来后读取并原样返回；请求标识 content file。
- **动态内容**：server 代表 client 运行程序，针对请求现场生成；请求标识 executable program file。
- 两者在线路上最终都是带类型的 byte content。老师同时提醒，现代 client-side JavaScript 让 Web 更复杂；本讲刻意使用较早、较简单的 server-generated model。（L22 00:50:43-00:51:55；课件 p.32）

### 4.3 URL/URI，以及课堂真正讲到的 proxy 边界

以 `http://www.cmu.edu:80/index.html` 为课堂结构例子：

- client 使用 scheme、host、可选 port，决定连接谁以及使用什么 protocol；
- origin server 使用 path suffix（如 `/index.html`）定位自己的 object；开头 `/` 指站点内容根，不等于任意 OS 根目录；
- URL 是 URI 的一种；课堂说明 origin server 的 request line 通常只带 URL suffix，而 **proxy 可能接收完整 URL**。（L22 00:51:55-00:53:22，00:58:40-00:59:17；课件 p.33-p.34）

这就是本讲时间线中实际出现的 proxy 内容。课件 p.54 标明 “Additional slides”，p.55-p.63 中虽有更多 proxy 等材料，但 transcript 在此之前已经结束；它们不能被重排成老师本讲实际讲授的 progression。（L22 “证据与课件审计”；课件 p.54）

### 4.4 HTTP transaction 的线序

Request：

```text
<method> <uri> <version>\r\n
<request-header>\r\n
...
\r\n
```

Response：

```text
<version> <status-code> <status-message>\r\n
<response-header>\r\n
...
\r\n
<optional body bytes>
```

课堂聚焦 `GET`。HTTP/1.1 的现场请求还发送 `Host`，因为同一 physical Internet host 可托管多个 virtual sites。response 中，`Content-Type` 说明 body 的 MIME type，`Content-Length` 说明 **body** 长度，空行把 headers 与 body 分开。（L22 00:52:48-00:57:25；课件 p.34-p.35）

老师用 telnet 手工发送请求并看到 `200 OK`、479-byte `text/html` body。课件 p.36-p.37 的另一次 transaction 先出现 `301 Moved Permanently`，再对另一 path 得到 `200 OK`。两者只能用来比较协议结构，不能把现场与课件的 path、status、length 或 framing 拼成同一次请求。（L22 00:54:02-00:57:33；课件 p.36-p.37）

### 4.5 Tiny 静态路径：先 headers，再 body

Tiny 是 239 行、可向真实浏览器提供静态与动态内容的 sequential teaching server。它先解析 `<method> <uri> <version>`，只支持 GET，再根据 URI 进入静态或动态分支。（L22 00:57:33-00:59:38；课件 p.38-p.39）

静态分支的实际发送顺序：

```text
filename + filesize
  -> get_filetype(filename)
  -> build response line and headers
       HTTP/1.0 200 OK
       Server: Tiny Web Server
       Connection: close
       Content-length: filesize
       Content-type: filetype
       blank line
  -> Rio_writen(fd, header bytes)
  -> Open(filename)
  -> Mmap file as srcp
  -> close source file descriptor
  -> Rio_writen(fd, srcp, filesize)
  -> Munmap
```

`mmap` 只把文件内容映射进进程地址空间；真正发送 body 的仍是 `Rio_writen(fd, srcp, filesize)`。因为 headers 已单独发送，而 body 恰是完整文件，所以静态响应的 `Content-length = filesize`，不包括 response line 或 headers。（L22 00:59:38-01:03:48；课件 p.40）

### 4.6 Tiny 动态路径：URL -> CGI child -> socket

课堂用 `/cgi-bin/adder?...` 和 `env.pl` 展示经典 CGI：

```text
client URL
  /cgi-bin/program?arg1&arg2
        |
        v
Tiny parses program path and cgiargs
        |
        v
server writes the generic response beginning
        |
        v
Fork
  parent: Wait for child
  child:
    setenv("QUERY_STRING", cgiargs, 1)
    Dup2(client connected fd, STDOUT_FILENO)
    Execve(program, ..., environ)
        |
        v
CGI program:
  getenv("QUERY_STRING")
  parse fields around '&'
  generate content
  printf Content-length and Content-type
  print blank line and HTML body
  fflush(stdout)
        |
        v
redirected stdout -> connected socket -> client
```

这里有三条必须分清的数据流：

1. **参数流**：URL 中 `?` 后的字符串 -> server 的 `cgiargs` -> child process environment 中的 `QUERY_STRING` -> CGI 的 `getenv`。（L22 01:08:45-01:10:46；课件 p.47、p.49）
2. **descriptor 流**：`dup2` 让 child 的 stdout 指向 client connected descriptor；`execve` 后 CGI 的普通 `printf` 仍把 bytes 写进连接。（L22 01:11:24-01:14:08；课件 p.50-p.51）
3. **response ownership**：server 先生成通用 status/server 信息；只有 CGI program 知道最终 content，因而由它生成 `Content-length`、`Content-type` 和 body。（L22 01:13:17-01:16:18；课件 p.51-p.52）

课堂课件示例参数 `15213&18213` 与现场演示的 `17&13` 是两次不同运行，不能合并数值。老师也明确评价每个 request 都 fork 一个 process 很慢；CGI 的价值在于用已有 process、environment、descriptor 和 socket 机制构造出简单而有用的动态 Web，而不是效率高。（L22 01:14:08-01:17:44；课件 p.45、p.52）

## 5. 错误处理与证据边界

### 5.1 运行时失败与清理

| 位置 | 课堂处理 | 不能误判为 |
|---|---|---|
| `getaddrinfo` 返回错误 | 用 `gai_strerror` 解释；结果 list 用完后 `freeaddrinfo` | 忽略错误或逐节点自行 `free` |
| client `socket` 失败 | 尝试下一 candidate | 已经向 server 发包 |
| client `connect` 失败 | 关闭本轮 `clientfd`，尝试下一 candidate | 复用失败 descriptor 继续连 |
| server `socket`/`bind` 失败 | 关闭已创建的本轮 descriptor，尝试下一 candidate | `bind` 失败后仍可直接 `listen` |
| server `listen` 失败 | 关闭 `listenfd` 并返回失败 | `bind` 成功就已经开始监听 |
| `accept` 无 client | 典型情况下阻塞等待 | 立即返回一个业务 descriptor |
| connected read 返回 0 | 当前 connection 的 EOF；关闭 `connfd`，iterative server 回到 `accept` | server process 必须退出 |
| Tiny 遇到 malformed request | 教学实现可能被破坏 | production-grade parser |

（L21 01:02:22-01:13:15；L22 00:12:12-00:12:45，00:20:29-00:35:44，00:42:49-00:46:36，00:57:33-00:58:23）

### 5.2 representation 与 API 边界

- 不要把 4-byte IPv4 address 的大小硬编码成 `bind`/`connect` 的 address structure length；使用 candidate 的 `ai_addrlen`。L21 00:53:53 左右的 “four” 存在 transcript 歧义。（L21 00:53:20-00:54:34，00:59:35-00:59:50）
- `AF_INET` 是 IPv4，不是 IPv6；`SOCK_STREAM` 表示本例所需的 stream/TCP 语义。L21 `hostinfo.c` 的 transcript 曾把它误成 IPv6，课件 p.40 明确写 `AF_INET /* IPv4 only */`。
- `sockaddr_in` 里的 port 和 IPv4 address 使用 network byte order；使用 `getaddrinfo` 是让库代办转换，不是让 network byte order 消失。（L21 00:44:26-00:45:54；L22 00:08:57-00:10:04）
- DNS 返回结果可随时间、地点和查询变化。老师关于 cache/顺序的现场猜测随即遇到变化结果，不能提升为 API sorting guarantee。（L21 01:13:15-01:14:57）
- `getnameinfo` 是转换方向上的 inverse，不保证恢复唯一原始 domain name。（L21 01:10:47-01:11:14；课件 p.39）

### 5.3 server 与 protocol 边界

- 本讲 echo 和 Tiny 都是 iterative/sequential；`listenfd` 与 `connfd` 的分离不等于已经实现并发。（L22 00:39:42-00:46:36，00:57:33-00:58:23）
- `listen` 的 backlog 是 outstanding requests queue 的提示。老师只讨论过小可能拒绝 client、过大可能增加 DoS 暴露，没有给出本讲的“最佳值”。（L22 00:34:49-00:35:28；课件 p.10）
- `localhost` 测试隔离了部署和外部网络变量，但不能证明跨机路径正确。（L21 01:15:01-01:15:43）
- 2015 年课堂称 HTTP/1.1 为 current version，这是历史语境，不是本模块对当前 Web 的版本判断。（L22 00:49:15-00:49:40）
- Tiny 只支持经过裁剪的 GET 路径，错误处理弱；其 `/cgi-bin` 字符串判定甚至可能误判文件名。这是教学代码，不是生产建议。（L22 00:57:33-00:59:38；课件 p.38-p.39）
- MIME 的 transcript 口述与课件定义存在差异。本模块采用课件 p.31 的可核对定义“byte sequence + associated MIME type”，不扩写损坏口述。
- proxy 在实际课堂时间线中只用于解释 request URI 可能是完整 URL；p.54-p.63 的 additional slides 未被 transcript 展开，不能据它们增加 proxy cache、header 或其他教学步骤。
- CGI 每请求创建 process 的设计被老师明确评价为低效；本讲只解释其机制和历史设计价值。（L22 01:16:18-01:17:44；课件 p.45）

## 6. 常见误解

1. **client/server 是机器类型。** 错；它们是 process roles，可同机运行。
2. **socket 是 IP address。** 错；单端 socket address 是 `IP:port`，完整 connection 由两端共同标识。
3. **一个 domain 永远只有一个固定 IP。** 错；DNS 是可变的 multi-mapping，也可能返回空集合。
4. **dotted decimal 就是 IPv4 的内存本体。** 错；它是 32-bit address 的 presentation text，网络字段仍使用 big-endian order。
5. **`socket` 已经联系远端。** 错；它建立本地 state，client 到 `connect` 才发起联系。
6. **`bind` 已经开始等待 client。** 错；还要 `listen`，实际等待通常发生在 `accept`。
7. **`accept` 返回或覆盖 `listenfd`。** 错；它保留 `listenfd`，新建并返回 `connfd`。
8. **每个 client 要占用不同 server service port。** 错；课堂现场纠正为 same port, different file descriptors。
9. **client close 会让 server process 退出。** 错；当前 `connfd` 上读到 EOF，iterative server 随后回到 `accept`。
10. **`getaddrinfo` 只需取第一项。** 错；课堂 helpers 逐项尝试，并对失败项清理 descriptor。
11. **HTTP 直接替代 TCP。** 错；HTTP 在 connected TCP stream 上定义 request、response 和 content 语义。
12. **`Content-Length` 包含 headers。** 错；Tiny 的静态和 CGI 例都只计算 body。
13. **动态内容不是 bytes。** 错；它只是由程序现场生成，在线路上仍是带 MIME type 的 bytes。
14. **本例 GET 参数经 CGI argv 传入。** 错；课堂路径通过 child environment 的 `QUERY_STRING`。
15. **CGI 的 `printf` 默认写回终端。** 错；`dup2` 已把 stdout 接到 connected socket。
16. **本讲完整讲了 Web proxy。** 错；实际只讲到 origin/proxy 的 request-target 差异，更多 proxy slides 属于未讲的补充区。

## 7. 掌握清单

- [ ] 能从 NIC、LAN、router、IP、TCP 一直解释到 socket descriptor，并说明每层屏蔽什么。
- [ ] 能区分 frame、packet、datagram、TCP byte stream 和 application message。
- [ ] 能说明 client/server 是 roles，并完整叙述一次 request/response session。
- [ ] 能区分 IPv4 value、network byte order、dotted-decimal presentation、domain name 和 port。
- [ ] 能解释 DNS 为什么要求 `getaddrinfo` 返回候选 linked list。
- [ ] 能从 `addrinfo` 字段指出哪些流向 `socket`，哪些流向 `connect`/`bind`。
- [ ] 能画出 server `socket -> bind -> listen -> accept` 与 client `socket -> connect`。
- [ ] 能区分 `listenfd`、`connfd`、`clientfd` 的角色和寿命。
- [ ] 能逐轮解释 `open_clientfd` 的 candidate retry 与失败清理。
- [ ] 能逐轮解释 `open_listenfd` 的 `socket`、`SO_REUSEADDR`、`bind`、`listen` 分界。
- [ ] 能追踪 echo 的 stdin -> client -> server -> client -> stdout 数据路径。
- [ ] 能解释 client close 为什么在 server 端成为 EOF，以及为什么 server 仍继续运行。
- [ ] 能把 HTTP request/response 划分为 start line、headers、blank line 和 optional body。
- [ ] 能区分 MIME type、static content、dynamic content、URL、URI 和 CGI。
- [ ] 能准确说出课堂中 proxy 只出现在哪个 request-target 对比中。
- [ ] 能按 byte 发送顺序解释 Tiny 静态 response，并说明 `Content-length = filesize`。
- [ ] 能画出 `QUERY_STRING -> fork -> setenv -> dup2 -> execve -> printf -> socket`。
- [ ] 能指出 Tiny server 与 CGI child 分别生成动态 response 的哪些部分。
- [ ] 能列出本讲未证明的内容：并发 server、production robustness、DNS 排序保证和补充 proxy slides。

## 8. 十二道累积练习（含答案）

### 练习 1：从物理网络到应用接口

按课堂顺序排列并解释：`TCP stream`、`NIC`、`socket descriptor`、`router/internet`、`LAN frame`、`IP datagram`。

**答案：** `NIC -> LAN frame -> router/internet -> IP datagram -> TCP stream -> socket descriptor`。NIC 是主机的网络 I/O device；当前 LAN 传 frame，router 连接网络；IP 提供 best-effort datagram；TCP 在其上重传、重排并给应用可靠双向 stream；应用通过 descriptor 读写。（L21 00:03:49-00:20:39）

### 练习 2：判断 client/server role

浏览器请求商品页时谁是 client、谁是 server？两者能否在同一 host？一次交互结束后，这些角色是否成为设备的永久属性？

**答案：** 发 request 的浏览器 process 是 client，管理资源并响应的 Web process 是 server；两者可位于相同或不同 hosts。角色描述一次 interaction，不是永久机器类型。（L21 00:01:32-00:03:49；课件 p.2）

### 练习 3：拆开地址表示

对 IPv4 文本 `128.2.x.y`，分别指出地址本体、presentation、network order 和域名所处层次。为什么不能把这四者叫作同一种字符串转换？

**答案：** 地址本体是 32-bit value；`128.2.x.y` 是四个 byte 的 dotted-decimal presentation；地址进入网络结构时按 big-endian network order；domain name 是另一套 hierarchical human naming，由 DNS 与地址建立多重映射。byte-order conversion、numeric presentation conversion 与 name resolution 解决不同问题。（L21 00:20:39-00:29:40）

### 练习 4：解释 DNS list

同一 domain 两次查询返回不同顺序甚至不同成员。程序应报错、排序后只取第一项，还是逐项尝试？为什么？

**答案：** 应接受 DNS multi-mapping，并按 `getaddrinfo` list 逐项尝试；一个失败再试下一个，全部失败才报告无法连接。课堂 Twitter 演示说明集合与顺序可变化，没有给排序保证。（L21 00:33:19-00:35:31，01:07:36-01:09:24）

### 练习 5：写出 connection identity

两个 clients 同时访问同一 server host 的同一 service port。server 是否必须为第二个 client 更换 service port？怎样区分两条 connections？

**答案：** 不必。server 保持同一 service port；两条 connection 由各自的 client IP/ephemeral port 与共同的 server IP/service port 组成的两端 socket pair 区分，在 server application 中由 `accept` 返回不同 connected descriptors。课堂明确纠正为 “same port, different file descriptors”。（L21 01:01:20-01:02:22）

### 练习 6：重建调用图

把 `accept`、`bind`、`connect`、`listen`、`socket` 放到正确 client/server 顺序，并指出哪个调用返回会话专用 descriptor。

**答案：** server：`socket -> bind -> listen -> accept`；client：`socket -> connect`。`accept` 在 request 到来后返回新的 `connfd`，原 `listenfd` 保留等待未来 requests。（L21 00:49:37-01:01:20；L22 00:42:49-00:43:46）

### 练习 7：追踪 client candidate 失败

`open_clientfd` 对候选 A 的 `socket` 成功但 `connect` 失败，对候选 B 连接成功。列出 descriptor 和 list 的清理顺序。

**答案：** 为 A 创建 `clientfd`；A 的 `connect` 失败后立即关闭该 descriptor；移动到 B，重新 `socket` 并 `connect`；B 成功后保留 B 的 connected descriptor并退出循环；最后释放整个 `addrinfo` list，返回 B 的 `clientfd`。（L22 00:23:18-00:26:31；课件 p.20）

### 练习 8：区分 bind、listen 与 accept

server 已成功 `bind`，但尚未 `listen`。此时它是否已能接受 client？如果 `listen` 成功，业务数据是否应该从 `listenfd` 读取？

**答案：** 不能。`bind` 只把本地 address/port 与 descriptor 关联，`listen` 才把它转为 listening socket；之后 `accept` 等待 request 并返回 `connfd`，业务 I/O 使用 `connfd`，不是 `listenfd`。（L22 00:32:48-00:35:44，00:42:49-00:43:46）

### 练习 9：完整追踪 echo 与 EOF

client 输入一行后按 Ctrl-D。按顺序写出 client、server 的 I/O 与 descriptor 变化，并说明 server 为什么还能服务下一 client。

**答案：** client 从 stdin 读一行，`Rio_writen(clientfd)`；server 在 `connfd` 上 `Rio_readlineb`，再按相同 `n` 写回；client 读响应并显示。Ctrl-D 结束 client 输入，client 关闭 `clientfd`；server 在对应 `connfd` 上读到 0/EOF，退出 `echo` 并关闭该 `connfd`，但长期 `listenfd` 未关闭，外层 loop 回到 `accept`。（L22 00:40:03-00:46:36；课件 p.25-p.27）

### 练习 10：解析 HTTP，并定位 proxy 的唯一课堂差异

给出：`GET /index.html HTTP/1.1`、`Host: www.cmu.edu`、空行。说明每部分作用；如果接收方是课堂所说的 proxy，request-target 可能怎样不同？

**答案：** 第一行由 method、URI、version 构成；`Host` 用于同一 Internet host 上的 virtual site 选择；空行结束 request headers。origin server 通常接收 URL suffix `/index.html`，proxy 可能接收完整 URL。两讲没有在实际时间线中继续讲 proxy cache 等内容。（L22 00:52:48-00:56:20，00:58:40-00:59:17；课件 p.34）

### 练习 11：推导 Tiny 静态 response 长度

一个静态文件大小为 `filesize`。Tiny 已构造若干 response headers。`Content-length` 应是 `filesize` 还是 headers 与文件之和？按发送顺序说明原因。

**答案：** 是 `filesize`。Tiny 先用 `Rio_writen` 单独发送 response line、headers 和空行；再 `mmap` 文件，并用 `Rio_writen(fd, srcp, filesize)` 发送 body。`Content-length` 描述 body，不包含先前 headers。（L22 01:00:21-01:03:48；课件 p.40）

### 练习 12：端到端推导 CGI response

请求 `/cgi-bin/adder?17&13`。从 URL 开始追踪参数、process、descriptor 与 response ownership；最后指出为什么这仍不是高效或 production-ready 的 server。

**答案：** Tiny 取 `?` 后的 `17&13` 为 `cgiargs`；fork 后 child 用 `setenv` 写成 `QUERY_STRING`，`dup2` 把 stdout 接到 client `connfd`，再 `execve` 运行 `adder`。程序用 `getenv` 读取并按 `&` 拆参数，生成 HTML；server 先写通用 status/server 信息，CGI 因知道最终 body 而写 `Content-length`、`Content-type`、空行和 body，`printf` 经重定向 stdout 进入 socket。它每 request fork process，老师明确评价为低效；Tiny 还被明确限定为顺序且错误处理薄弱的教学实现。（L22 01:09:27-01:17:44；课件 p.49-p.52）

## 9. 推荐复习顺序

1. **先搭网络抽象**：阅读 [L21 NOTES](/courses/cmu-csapp-f15/lectures/021/) 的 Section 001-002，画出 `NIC -> LAN -> router -> IP -> TCP -> descriptor`。
2. **再拆表示层**：学习 L21 Section 003-004，口头区分 IPv4 value、network order、dotted decimal、domain name、DNS result 和 port。
3. **手画 socket 生命周期**：学习 L21 Section 005-007，不看材料重画两端调用图，特别标出 `listenfd` 与 `connfd`。
4. **用 `hostinfo` 收束 Part I**：学习 L21 Section 007-008，逐字段说明 `addrinfo` 怎样供应 `socket`、`connect`、`bind`，并解释为什么必须释放 list。
5. **进入可恢复 helpers**：阅读 [L22 NOTES](/courses/cmu-csapp-f15/lectures/022/) 的第 1-4 段，手工模拟 client 的 connect failure 和 server 的 bind failure。
6. **用 echo 固化 descriptor 心智模型**：学习 L22 第 4-5 段，追踪一行 bytes 和一次 EOF；若还会混淆 `listenfd`/`connfd`，先不要进入 HTTP。
7. **把 HTTP 作为应用协议单独学习**：学习 L22 第 5-6 段，练习划分 request/response line、headers、blank line、body，并只保留课堂实际讲到的 proxy request-target 差异。
8. **先静态、后动态**：学习 L22 第 7 段的 `serve_static`，再学习第 7-8 段的 CGI；分别画 bytes path 与 process/descriptor path。
9. **最后做边界审计**：重看两份 NOTES 中的 `[需回听]` 与证据审计，确认自己没有把 DNS 顺序、并发能力、HTTP 现代版本、Tiny robustness 或 additional proxy slides 写成课堂已证明结论。
10. **闭卷完成十二题**：能够给出因果链而不只背函数名，才算完成本模块。
{% endraw %}
