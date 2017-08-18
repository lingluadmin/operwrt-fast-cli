if [ $# -lt 1 ]; then
    echo "Usage: sh $0 [ ar71xx | bcm53xx | brcm47xx | ramips_24kec ]"
    exit
fi
arch=$1
cp /tmp/opkg.conf /etc/opkg.conf
opkg update
opkg install /tmp/ChinaDNS_1.3.2-3_$arch.ipk --force-overwrite
opkg install /tmp/shadowsocks-libev-spec_2.4.7-1_$arch.ipk --force-overwrite

opkg install /tmp/luci-app-chinadns_1.4.0-1_all.ipk --force-overwrite    
opkg install /tmp/luci-app-shadowsocks-spec_1.4.0-1_all.ipk --force-overwrite
opkg install /tmp/simple-obfs_0.0.2-1_ar71xx.ipk --force-overwrite
opkg install iptables-mod-tproxy --force-overwrite
