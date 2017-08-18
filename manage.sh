#!/bin/bash

set -e
set -o errexit

prj_path=$(cd $(dirname $0); pwd -P)
SCRIPTFILE=`basename $0`

function run_cmd() {
    t=`date`
    echo "$t: $1"
    eval $1
}

function list_contains() {
    local var="$1"
    local str="$2"
    local val

    eval "val=\" \${$var} \""
    [ "${val%% $str *}" != "$val" ]
}

function _check_config() {
    if [ ! -f "$config_file" ]; then
        echo "Can not find config file: $config_file"
        exit 1
    fi
}

function _read_config() {
    local name=$1
    echo $(cat $config_file | grep $name | awk -F'=' '{print $2}')
}

function _load_config() {
    if [ "$action" == 'build' ]; then
        router_ip='192.168.1.1'
    else
        router_ip=$(_read_config 'router_ip')
    fi
    mode=$(_read_config 'mode')
    router_password=$(_read_config 'router_password')
    router_arch=$(_read_config 'router_arch')
    remote="root@$router_ip"
}

function _run_cmd_remote() {
    local cmd=$1
    run_cmd "ssh $remote '$cmd'"
}

function to() {
    run_cmd "ssh $remote"
}

function set_auth() {
    ssh_keys_file=$prj_path/data/authorized_keys
    run_cmd "expect tools/update-password.expect $router_password $ssh_keys_file"
    sleep 5
}

function download_chinadns() {
	wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > data/chinadns_chnroute.txt
}

function upload_chinadns() {
    run_cmd "scp -q $prj_path/data/chinadns_chnroute.txt $remote:/etc/"
}

function update_chinadns() {
    download_chinadns
    upload_chinadns
}

function install_pkg() {
	local arch=$router_arch
    run_cmd "scp -q $prj_path/files-upload-to-temp-arch/*$arch* $remote:/tmp"
    run_cmd "scp -q $prj_path/files-upload-to-temp/* $remote:/tmp"
    _run_cmd_remote "sh /tmp/install.sh $arch"
    upload_chinadns
}

function upload_system_files() {
    echo 'upload_system_files'
    run_cmd "cp $config_file openwrt/etc/config/fast"
    if [ -f 'data/shadowsocks' ]; then
        run_cmd "cp data/shadowsocks openwrt/etc/config/"
    fi
    run_cmd "scp -q -r openwrt/* $remote:/"
}

function reboot() {
    local cmd='reboot'
    _run_cmd_remote "$cmd"
}

function update_remote_config() {
    echo 'update_remote_config'
    local cmd="fast-cli update_config $mode"
    _run_cmd_remote "$cmd"
}

function build() {
    set_auth
	remove_host
    if [ "$mode" == 'router' ]; then
        install_pkg
    fi
    upload_system_files
    update_remote_config
    reboot
}

function update() {
	remove_host
    upload_system_files
    update_remote_config
    reboot
}

function remove_host() {
	run_cmd "sed -i.bak '/$router_ip/d' ~/.ssh/known_hosts"
    run_cmd "expect tools/ssh-key-yes.expect '$router_ip'"
}

function help() {
	cat <<-EOF
    
    Usage: manage.sh command config-file-path

        build                   刷完系统或者重置之后，根据配置自动设置路由器，并重启
        update

        set_auth                设置路由器的密码，加 authorized_keys 到路由器中
        install_pkg             安装各种包
        upload_system_files     上传管理程序
        update_remote_config    更新路由器配置

        update_chinadns         更新大陆 IP 段信息

        remove_host             从 known_hosts 中移除路由器 IP

        reboot
        to

        -h                      show this help message and exit

EOF
}


action=${1:-help}
if [ ! $# -eq 2 ]; then
    help
    exit 1
fi

config_file=$2
_check_config
_load_config

ALL_COMMANDS="build update set_auth install_pkg upload_system_files update_remote_config update_chinadns remove_host reboot to"
list_contains ALL_COMMANDS "$action" || action=help
$action "$@"
