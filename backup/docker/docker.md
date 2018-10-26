# 安装docker 注意的事项

### 支持的存储驱动

ubuntu上的docker-ce支持overlay2和aufs存储驱动程序。
centos7上的docker-ce-18.03.0 之后的版本需要升级系统内核为4及更高版本。

* 对于Linux内核版本4及更高版本的新安装，overlay2 支持并首选aufs。
* 于Linux内核的版本3，aufs支持，因为该内核版本不支持overlay或 overlay2驱动程序。



### docker 国内加速源配置
需要编辑 vim /etc/docker/daemon.json文件，添加如下：

```aidl

{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}

```
* https://registry.docker-cn.com
* https://docker.mirrors.ustc.edu.cn
 

### 把当前用户添加到docker组

把用户添加到docker组，然后注销会话重新登录即可。

```
sudo usermod -aG docker $USER

sudo gpasswd -a ${USER} docker

newgrp - docker
```

### ubuntu16.04 下 docker 加载daemon.json失败

使用以下命令编辑 docker.service文件.

    sudo vim /lib/systemd/system/docker.service

修改以下行，替换您自己的值，然后保存文件。

```aidl

[Service]
#ExecStart=/usr/bin/dockerd -H fd://
ExecStart=/usr/bin/dockerd 

```

重新加载systemctl配置

    sudo systemctl daemon-reload
    
重启docker

    sudo systemctl restart docker