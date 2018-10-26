

# rancher 

Rancher 是一个开源的企业级全栈化容器部署及管理平台.

## rancher 特性

* 平台部署方便。
* 平台扩展方便。
* 服务部署方便。
* 自带账户权限。


## rancher 部署

* 部署 server

 server 对系统基本没有要求。

```aidl

# 数据库数据内置。缺点是如果容器损坏了，数据就不可恢复
docker run -d -p 18080:8080 --name rancher --restart=unless-stopped rancher/server:stable

# **推荐**数据库数据外置。即使容器坏了，数据还在，重新再建一个容器即可
docker run -d -p 18080:8080 --name rancher --restart=unless-stopped -v <host_vol>:/var/lib/mysql rancher/server:stable

```

* 部署 agent
    
agent 的启动命令可以在界面上自动生成，唯一需要填写的是 agent 所在主机的 ip 地址。

![image](http://172.16.1.61/wangyongbin/docker/raw/master/rancher/images/hostadd.png)




