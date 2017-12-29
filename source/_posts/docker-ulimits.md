---
title: docker container占用空间过大，overlay超负荷
date: 2017/12/29 21:33:10
tags: 
- docker
- ulimits
- coredump
categories:
- 技术
comments: true
---


前两天有客户抱怨说production磁盘占用过高，每台200G硬盘被占了大概160G左右，一开始以为是log日志过多，后来查了下log大概也就不到20G, 用 

``` shell
sudo du -h --max-depth=1 
```

查了下是/var目录占用最多，占了130G左右，接着查下去发现是/var/lib/docker占用过大，主要是overlay下面。

知道了是docker占用过高又去排查docker的images，使用

``` shell
docker image prune
```

删掉不用的images后还是占用很高，又调用
``` shell
docker ps -s
```

总算发现是现在运行的docker container占用巨高，exec进去container发现有很多core.xxxx的文件, 这些就是coredump文件，当程序出错的时候会将程序的内存、寄存器状态、指针等状态保存到core文件中，具体coredump的解释可以参考这篇文章[详解coredump](http://blog.csdn.net/tenfyguo/article/details/8159176/)

找到问题之后删掉core文件，container占用立刻清楚，但是程序一旦出错又会继续生成core文件，在container里直接改ulimits并没有用，必须改启动设置，使用命令行的话是
```
docker run --ulimits core=xxx
``` 

xxx = unlimited的时候就会无限制的产生core文件，这里因为我们不需要core文件，所以直接设置成0即可。因为用了docker-compose.yml来启动docker，设置如下

``` yml
  version: '3'
  services:
    name:
      image: xxx
      volumes:
        - /var/log:/var/log
      ports:
        - "8000:8000"
      ulimits:
        core: 0
```
至此，总算找到了占用space的症结所在，解决了问题