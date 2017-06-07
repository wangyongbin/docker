#如果还没有 docker group 就添加一个：
sudo groupadd docker

#将用户加入该 group 内。然后退出并重新登录就生效啦。
sudo gpasswd -a ${USER} docker

#重启 docker 服务
sudo service docker restart

#切换当前会话到新 group 或者重启 X 会话
newgrp - docker
#OR
#pkill X

#注意，最后一步是必须的，否则因为 groups 命令获取到的是缓存的组信息，刚添加的组信息未能生效，所以 docker images 执行时同样有错。
