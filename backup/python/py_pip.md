# python pip 国内源




使用方法很简单，直接 -i 加 url 即可！如下：


    pip install web.py -i http://mirrors.aliyun.com/pypi/simple/
    
    pip3 install esrally -i https://mirrors.aliyun.com/pypi/simple/


### pip国内的一些镜像

* 阿里云 https://mirrors.aliyun.com/pypi/simple/ 
* 中国科技大学 https://pypi.mirrors.ustc.edu.cn/simple/ 
* 豆瓣(douban) http://pypi.douban.com/simple/ 
* 清华大学 https://pypi.tuna.tsinghua.edu.cn/simple/ 
* 中国科学技术大学 http://pypi.mirrors.ustc.edu.cn/simple/

修改源方法：

临时使用： 

可以在使用pip的时候在后面加上-i参数，指定pip源 

    pip install scrapy -i https://mirrors.aliyun.com/pypi/simple/

永久修改：
 
linux: 
修改 ~/.pip/pip.conf (没有就创建一个)， 内容如下：

```aidl
[global]
index-url=https://mirrors.aliyun.com/pypi/simple/ 
trusted-host=mirrors.aliyun.com
```

windows: 
直接在user目录中创建一个pip目录，如：C:\Users\xx\pip，新建文件pip.ini，内容如下

```aidl

[global]
index-url=https://mirrors.aliyun.com/pypi/simple/ 

```



### 参考

* [更换pip源到国内镜像](https://blog.csdn.net/chenghuikai/article/details/55258957)
* [pip使用国内源](https://www.cnblogs.com/sunnydou/p/5801760.html)
