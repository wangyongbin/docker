### nfs 服务 
    
    1,服务器地址
        172.16.0.79
        username:ceph
        password:123456
    
    2,安装
        apt-get install nfs-kernel-server
        
    3,配置共享目录
        suod mkdir -p /coss
        sudo vim /etc/exports
            /coss/ *(async,insecure,no_root_squash,no_subtree_check,rw) #与nfs服务客户端共享的目录，这个路径必须和你前面设置的文件的路径一致！
            
            *：允许所有的网段访问，也可以使用具体的IP
            rw：挂接此目录的客户端对该共享目录具有读写权限
            async：资料同步写入内存和硬盘
            no_root_squash：root用户具有对根目录的完全管理访问权限。
            no_subtree_check：不检查父目录的权限。
    
    4,映射端口，重启nfs服务
        sudo service rpcbind restart restart
        sudo service restartnfs-kernel-server restart
    
    5,测试
        showmount -e #显示共享目录
        mount -t nfs 172.16.0.79:/coss /nfsdir
        
### docker data volume 

    1,安装nfs客户端 
        sudo apt-get install nfs-common
        
    2,在docker宿主机上创建nfs类型的数据券
        docker volume create --driver local \
        	--opt type=nfs \
        	--opt o=addr=172.16.0.79,rw \
        	--opt device=:/coss \
        	--name coss-volume
        
    3,测试
        docker run -d --rm --name test -v coss-volume:/coss busybox sleep 10000 #创建容器应用数据券
        docker exec -it test sh
            # ls /coss
        
    
        
