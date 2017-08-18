### 配置

1. data/manage.config

    ```
    password=hello
    arch=ar71xx
    ip=192.168.1.1
    ```

    * password 路由器密码 / root 登录密码
    * arch = [ ar71xx | bcm53xx | brcm47xx | ramips_24kec ]
    * ip 刷完系统之后是 192.168.1.1，之后根据实际情况设置

1. data/authorized_keys

    这里存放所有可以登录路由器的终端的公钥

1. data/fast

    ```
    config fast_config common
        # ap / router
        option mode 'ap'
        option timezone 'HKT-8'

    config fast_config router
        option hostname 'OpenWrt-Leo'

        option channel_2g '1'
        option channel_5g '36'
        option disable_2g '1'
        option disable_5g '0'

        option lan_ip '192.168.98.1'
        option lan_mask '255.255.255.0'
        option wifi_ssid_2g 'OpenWrt-Leo'
        option wifi_ssid_5g 'OpenWrt-Leo-5G'
        option wifi_password 'ificouldtellyou'

    config fast_config ap

        option hostname 'OpenWrt-36'

        option channel_2g '1'
        option channel_5g '36'
        option disable_2g '1'
        option disable_5g '0'

        option lan_ip '172.16.1.100'
        option lan_mask '255.255.253.0'
        option wifi_ssid_2g 'shine-2.4g'
        option wifi_ssid_5g 'shine-5g'
        option wifi_password 'ificouldtellyou'
    ```

1. data/shadowsocks

    ```
    config global
        option global_server 'nil'
    
    # 加入你的 Shadowsocks 帐号
    config servers 1
        option local_port '1080'
        option timeout '60'
        option alias '{ }'
        option server '{ IP 地址 }'
        option server_port '{ 端口 }'
        option password '{ 密码 }'
        option encrypt_method '{ 加密方式 }'
    
    # 这是另外一个
    config servers 2
        option local_port '1080'
        option timeout '60'
        option alias 'server2'
        option server '8.8.8.8'
        option server_port '8181'
        option password '123456'
        option encrypt_method 'aes-128-cfb'
    
    # 如果你不知道以下配置的作用，请不要修改
    config udp_forward
        option tunnel_enable '0'
        option tunnel_port '5300'
        option tunnel_forward '8.8.4.4:53'
    
    config access_control
        option lan_ac_mode '0'
        option wan_bp_list '/etc/chinadns_chnroute.txt'
    ```

### 使用

1.  sh manage.sh

	```
	build-it              刷完系统或者重置之后，根据配置自动设置路由器，并重启

	set-auth              设置路由器的密码，加 authorized_keys 到路由器中
	install-pkg           安装各种包
	upload-system-files   上传管理程序
	update-remote-config  更新路由器配置

	set-as-ap             设置为 AP 模式
	set-as-router         设置为路由器模式

	update-chinadns       更新大陆 IP 段信息

	reboot

	-h                      show this help message and exit
	```
