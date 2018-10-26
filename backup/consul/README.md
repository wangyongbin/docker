## Consul 服务注册中心搭建过程

--第一步：下载consul-agent.sh脚本
<pre>
    /consul/consul-agent.sh
</pre>
--第二步：请确保以下几个镜像的存在（由于网络问题，请手动下载）
<pre>
    1、sudo docker pull consul:latest
    2、sudo docker pull gliderlabs/registrator
</pre>

--第三步：运行命令
<pre>
    示例一：如果第一次搭建consul集群，请运行
        
        sudo sh consul-agent.sh 本机IP 节点名称 master
        
    示例二：consul 代理为服务端 server
        
        sudo sh consul-agent.sh 本机IP 节点名称 server 集群主IP地址
        
    示例二：consul 代理为客户端 client
        
        sudo sh consul-agent.sh 本机IP 节点名称 client 集群主IP地址
        
</pre>
