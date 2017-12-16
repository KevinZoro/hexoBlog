---
title: nginx 代理 websocket
date: 2017/12/16 14:20:15
tags: 
- websocket
- nginx
categories:
- 技术
comments: true
---
最近使用socket.io来建立client和server的socket通讯服务，遇到了一个小问题,在develop环境一切正常，但是上了staging之后socket通讯失败，握手失败返回400 error,经过一番google，发现staging上用了nginx代理，之前都是tcp服务，上了socket的话需要多加一些参数

加之前配置如下:
```
  location @backend {
    proxy_set_header  X-Real-IP         $remote_addr;
    proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header  Host              $http_host;

    proxy_redirect off;
    proxy_max_temp_file_size 0;

    proxy_cache one;
    proxy_cache_key sfs$request_uri$scheme;

    client_max_body_size 10M;

    proxy_pass http://backend;
  }
```
加上最开始的参数，主要是这两句
```
proxy_set_header  Upgrade     $http_upgrade;
proxy_set_header  Connection  "upgrade";
```
```
  location @backend {
    proxy_http_version 1.1;
    proxy_set_header  Upgrade           $http_upgrade;
    proxy_set_header  Connection        "upgrade";
    proxy_set_header  X-Real-IP         $remote_addr;
    proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header  Host              $http_host;

    proxy_redirect off;
    proxy_max_temp_file_size 0;

    proxy_cache one;
    proxy_cache_key sfs$request_uri$scheme;

    client_max_body_size 10M;

    proxy_pass http://backend;
  }
```

有兴趣的可以去看官网的blog [nginx](https://www.nginx.com/blog/websocket-nginx/)

参考资料：

1.[socket.io Issue讨论](https://github.com/socketio/socket.io/issues/1942)

2.[官网blog](https://www.nginx.com/blog/websocket-nginx/)