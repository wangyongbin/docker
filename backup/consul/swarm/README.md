## Docker Swarm 集群搭建过程
 
--第一步：下载swarm-agent.sh脚本，打开docker服务的2375端口
<pre>
    1、/swarm/swarm-agent.sh
    2、
    sudo vim /etc/default/docker
        DOCKER_OPTS="--registry-mirror=http://a1e80ea2.m.daocloud.io -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock"
    或者：
    sudo vim /etc/docker/daemon.json
        {
	        "hosts": ["tcp://0.0.0.0:2375","unix:///var/run/docker.sock"],
	        "registry-mirrors":[ "http://a1e80ea2.m.daocloud.io" ]
        }
</pre>
--第二步：请确保以下几个镜像的存在（由于网络因素，请手动下载）
<pre>
    1、sudo docker pull swarm:latest
</pre>

--第三步：运行命令
<pre>
    示例一：Docker Swarm 集群的管理节点，请运行
        
        sudo sh swarm-agent.sh 本机IP manager consul的IP地址
        
    示例二：Docker Swarm 集群的工作节点，请运行
        
        sudo sh swarm-agent.sh 本机IP worker consul的IP地址
        
</pre>
