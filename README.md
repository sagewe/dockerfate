# FATE on Docker

使用docker快速部署 FATE 的单机实验环境

# 快速开始

启动服务

``` sh
docker run -d --name dockerfate sagewei0/dockerfate 
```

执行命令

``` sh
docker exec dockerfate <flow | pipeline | fate_test>
```

