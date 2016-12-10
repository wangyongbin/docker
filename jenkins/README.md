### 获取 dockerjenkins.sh 脚本

wget https://raw.githubusercontent.com/jamtur01/dockerbook-code/master/code/5/jenkins/dockerjenkins.shc

### 授权
chmod 0755 dockerjenkins.sh

### 创建 Docker-Jenkins 镜像
sudo docker build -t="wyb20161209/dockerjenkins:1.0" .

## 运行镜像
sudo docker run -d -p 8080:8080 --name jenkins --privileged wyb20161209/dockerjenkins:1.0
