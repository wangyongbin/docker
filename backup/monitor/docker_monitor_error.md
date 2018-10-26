## docker 错误

1. err="Opening storage failed open DB in /prometheus/: open /prometheus/673409682: permission denied",报这个错误的解决办法是在prometheus.yaml中加上

    securityContext:
        runAsUser: 0

2. Error response from daemon: removal of container c198efcc875b is already in progress

    Failed to remove network wumhbjnk290uzt7yqvjei4aei: Error response from daemon: network monitor_monitoring id wumhbjnk290uzt7yqvjei4aei has active endpointsFailed to remove some resources from stack: monitor

3. rm: 无法删除"c198efcc875b36a8d95684371329840e979bb584f1f1c830ee177862f6f71440/shm": 设备或资源忙
   
   1.查找挂载的目录 
   cat /proc/mounts |grep "docker"
   
   /dev/mapper/centos-root /var/lib/docker/containers xfs rw,seclabel,relatime,attr2,inode64,no 
   quota 0 0
   
   2.卸载 
   umount /var/lib/docker/containers

4.    