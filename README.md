# uuplugin docker 版本

UU 加速提供了 OpenWrt 版本的插件，见 https://uu.163.com/router/direction.html。
该项目基于 OpenWrt 的 openwrtorg/rootfs 版本构完成了开启 UU 需要的配置，同时移除了一些无关服务，如 DHCP、SSH、Web luci。
你可以使用该镜像完成旁路由模式下 UU 加速服务快速部署。（加入保持加速器最新版本功能）

因为不同的 OpenWrt 版本对路由规则配置不同（或者别的什么），导致检测不到游戏主机连入。主要表现为主机在 UU app 中出现后立即消失。
~~使用该 docker 镜像应当可以有效解决该问题。~~

使用该docker镜像可以部分解决由路由引起的UU检测不到主机的问题，但仍有NS在app闪现的情况，猜测为uu插件本身对主机的判断还存在bug，请耐心等待更新。

## 环境准备

### 打开 IP 混杂模式

> 因为我没有多网口设备，如何在多网口设备下为容器提供独立 IP 你需要自行查询 Docker 相关文档。

如果你的物理设备为单网口，需要开启 IP 混杂模式，为容器提供独立 IP。

如下命令为开启方式：

```
ip link set eth0 promisc on
```

`eth0` 网卡根据实际情况选择，你可以通过 `ip addr` 判断该输入什么。

### 创建桥接网络 macvlan （可选）

命令示例如下，`subnet`、`gateway` 和 `parent` 应当根据实际情况选择：

```
docker network create -d macvlan \
--subnet=10.0.0.0/24 \
--gateway=10.0.0.1 \
-o parent=eth0 \
bridge-host
```
**推荐使用docker-compse直接添加网络。**

## 启动容器

容器可配置参数如下，一般情况只需要配置 `UU_LAN_IPADDR` 和 `UU_LAN_GATEWAY`。

```
ENV UU_LAN_IPADDR=
ENV UU_LAN_GATEWAY=
ENV UU_LAN_NETMASK="255.255.255.0"
ENV UU_LAN_DNS="10.0.0.1"
```

启动命令示例如下：

```
docker run -d --name uuplugin \
--network bridge-host \
--privileged \
-e UU_LAN_IPADDR=10.0.0.125 \
-e UU_LAN_GATEWAY=10.0.0.1 \
dianqk/uuplugin
```

- `UU_LAN_IPADDR` 为该容器使用的 IP，也是游戏主机的网关
- `UU_LAN_GATEWAY` 为该容器的上级网关

推荐使用docker-compse启动，请根据情况修改yml文件。
```
docker-compose up -d
```

## 绑定 UU 服务

UU 主机加速 app 会检测手机网关进行通信判断是否安装的 UU 插件，所以你需要**将手机网关和 DNS 指向刚刚创建的容器使用的 IP**。
打开 app 点击安装路由器插件绑定即可。
绑定完毕后，手机即可以改回原来的设定。

## 为游戏主机加速

将需要加速的游戏主机的网关和 DNS 设置为容器的 IP 后，打开 app 即可看到设备出现，点击加速即可。

