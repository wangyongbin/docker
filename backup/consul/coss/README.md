## 1，coss 集群搭建过程

### 第一步：下载 `coss-agent.sh` 脚本

    /coss/coss-agent.sh

### 第二步：请确保以下几个镜像的存在（由于网络问题，请手动下载）

    1、sudo docker pull consul:latest <br>
    2、sudo docker pull gliderlabs/registrator <br>
    3、sudo docker pull swarm:latest <br>

### 第三步：运行命令

* 示例一：如果第一次搭建 coss 集群,coss 代理为角色引导 `role=bootstrap`，请运行

    sudo sh coss-agent.sh 本机IP 节点名称 bootstrap
        
* 示例二：coss 代理角色为管理 `role=manager`

    sudo sh coss-agent.sh 本机IP 节点名称 manager 集群引导IP地址
        
* 示例二：coss 代理角色为工作 `role=worker`

    sudo sh coss-agent.sh 本机IP 节点名称 worker 集群引导IP地址


## 2，如何使用coss集群

### 1、操作 coss 集群中代理角色为 `role=bootstrap，manager`的代理，如:

    docker -H ip:3375 image | docker -H ip:3375 ps
        
### 2、注：docker相关命令请查看官网

* Docker: https://docs.docker.com/reference/


