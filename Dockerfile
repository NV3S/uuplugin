FROM openwrtorg/rootfs:x86_64

LABEL maintainer="Blindlight <blindlight1986@gmail.com>"

ENV UU_LAN_IPADDR=
ENV UU_LAN_GATEWAY=
ENV UU_LAN_NETMASK="255.255.255.0"
ENV UU_LAN_DNS="223.5.5.5"

USER root

RUN mkdir /var/lock
RUN opkg update
RUN opkg install libustream-mbedtls ca-certificates kmod-tun curl

ADD uu_prepare /etc/init.d/uu_prepare
RUN /etc/init.d/uu_prepare enable
# 关闭 ipv6 dhcp
RUN /etc/init.d/odhcpd disable
# 关闭防火墙规则
RUN /etc/init.d/firewall disable
# 禁止访问 Web
RUN /etc/init.d/uhttpd disable
# 禁止 SSH 登录
RUN /etc/init.d/dropbear disable

CMD ["/sbin/init"]
