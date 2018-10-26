# superset


superset是一个开源的数据探查与可视化平台，怎么说呢，我们只需要安装它，配置他的一些文件，就可以连接数据库，进行图表展示，总之一句话，它的功能很强大：

* superset 特征
* superset 功能介绍
* superset 使用docker运行superset

## superset 特征

* 丰富的数据可视化集
* 易于使用的界面，用于探索和可视化数据
* 创建和共享仪表板
* 与主要身份验证提供程序集成的企业级身份验证（通过Flask AppBuilder进行数据库，OpenID，LDAP，OAuth和REMOTE_USER）
* 一种可扩展的，高粒度的安全/权限模型，允许谁可以访问各个功能和数据集的复杂规则
* 一个简单的语义层，允许用户通过定义哪些字段应显示在哪个下拉列表以及哪些聚合和功能度量标准可供用户使用来控制数据源在UI中的显示方式
* 通过SQLAlchemy与大多数讲SQL的RDBMS集成
* 与Druid.io深度整合

## superset 功能介绍

1. 我们可以通过连接数据库，去对数据库中的单个表进行配置，展示出柱状图，折线图，饼图，气泡图，词汇云，数字，环状层次图，有向图，蛇形图，地图，平行坐标，热力图，箱线图，树状图，热力图，水平图等图，官网上是不可以操作多个表的，不过我们可以操作视图，也就是说在数据库建好视图，也可以在superset中给表新增一列进行展示。

2. 配置好了我们想要的图表之后我们可以把它添加到仪盘表进行展示，还可以去配置缓存，来加速仪盘表的查询，不必要没次都去查询数据库。
 
3. 我们可以查看进行查询表的sql，也可以把查询导出为json，csv文件。它有自己的sql编辑器，我们可以在里面来编写sql。



## 使用docker运行superset

superset docker 镜像 https://hub.docker.com/r/amancevice/superset/

### 数据库依赖

默认情况下，superset是把元数据保存到sqlite中的，所以使用数据库postgres 保存superset元数据，并用数据卷持久化数据，名称为vol_superset_postgres

```aidl

docker volume create vol_superset_postgres

docker run -d --restart=always --name dev_superset_postgres \
-p 5432:5432 \
-e POSTGRES_DB=superset \
-e POSTGRES_PASSWORD=superset \
-e POSTGRES_USER=superset \
-v vol_superset_postgres:/var/lib/postgresql/data \
postgres:10

```

### 缓存

superset使用Flask-Cache来缓存数据。在superset_config.py中，可以通过CACHE_CONFIG参数配置缓存所使用的后端。
Flask-Cache支持多种缓存后端，比如Redis、Memcached、SimpleCache（in-memory）、local filesystem。以redis为例：

```aidl

docker volume create vol_superset_redis 

docker run -d --restart=always --name dev_superset_redis \
-p 6379:6379 \
-v vol_superset_redis:/data \
redis:3.2


```


### 容器

在启动superset容器之前需要配置superset_config.py文件，把superset需要的数据库和缓存添加上。参考 github 上的[superset_config.py](https://github.com/apache/incubator-superset/blob/master/contrib/docker/superset_config.py)。

superset_config.py 配置文件如下:

```aidl

# -*- coding: utf-8 -*-
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

import os


def get_env_variable(var_name, default=None):
    """Get the environment variable or raise exception."""
    try:
        return os.environ[var_name]
    except KeyError:
        if default is not None:
            return default
        else:
            error_msg = 'The environment variable {} was missing, abort...'\
                        .format(var_name)
            raise EnvironmentError(error_msg)


POSTGRES_USER = get_env_variable('POSTGRES_USER')
POSTGRES_PASSWORD = get_env_variable('POSTGRES_PASSWORD')
POSTGRES_HOST = get_env_variable('POSTGRES_HOST')
POSTGRES_PORT = get_env_variable('POSTGRES_PORT')
POSTGRES_DB = get_env_variable('POSTGRES_DB')


# The SQLAlchemy connection string.
SQLALCHEMY_DATABASE_URI = 'postgresql://%s:%s@%s:%s/%s' % (POSTGRES_USER,
                                                           POSTGRES_PASSWORD,
                                                           POSTGRES_HOST,
                                                           POSTGRES_PORT,
                                                           POSTGRES_DB)


REDIS_HOST = get_env_variable('REDIS_HOST')
REDIS_PORT = get_env_variable('REDIS_PORT')


class CeleryConfig(object):
    BROKER_URL = 'redis://%s:%s/0' % (REDIS_HOST, REDIS_PORT)
    CELERY_IMPORTS = ('superset.sql_lab', )
    CELERY_RESULT_BACKEND = 'redis://%s:%s/1' % (REDIS_HOST, REDIS_PORT)
    CELERY_ANNOTATIONS = {'tasks.add': {'rate_limit': '10/s'}}
    CELERY_TASK_PROTOCOL = 1


CELERY_CONFIG = CeleryConfig


```

启动容器

```aidl

docker run -d --restart=always --name dev_superset \
-p 8088:8088 \
-e POSTGRES_DB=superset \
-e POSTGRES_USER=superset \
-e POSTGRES_PASSWORD=superset \
-e POSTGRES_HOST=192.168.1.171 \
-e POSTGRES_PORT=5432 \
-e REDIS_HOST=192.168.1.171 \
-e REDIS_PORT=6379 \
-v ${HOME}/work/docker/mnt/superset/superset_config.py:/etc/superset/superset_config.py \
amancevice/superset:0.26.3

```


### 数据库初始化

启动Superset服务器后，使用superset-init辅助脚本使用admin用户和Superset表初始化数据库：

```
docker exec -it dev_superset superset-init
```


### 配置数据源

略




### 参考

* [http://blog.timd.cn/superset/](http://blog.timd.cn/superset/)

### 截图

![image](http://172.16.1.61/wangyongbin/docker/raw/master/superset/images/bank_dash.png)
