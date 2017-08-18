#!/bin/bash

NC='\033[0m'      # Normal Color
RED='\033[0;31m'  # Error Color
CYAN='\033[0;36m' # Info Color

function run_cmd() {
    t=`date`
    echo "$t: $1"
    eval $1
}

function ensure_dir() {
    if [ ! -d $1 ]; then
        run_cmd "mkdir -p $1"
    fi
}

function stop_container() {
    container_name=$1
    cmd="docker ps -a -f name='^/$container_name$' | grep '$container_name' | awk '{print \$1}' | xargs -I {} docker rm -f --volumes {}"
    run_cmd "$cmd"
}

docker_domain=docker-registry.sunfund.com

function push_image() {
    local image_name=$1
    url=$docker_domain/$image_name
    run_cmd "docker tag $image_name $url"
    run_cmd "docker push $url"
}

function pull_image() {
    local image_name=$1
    url=$docker_domain/$image_name
    run_cmd "docker pull $url"
    run_cmd "docker tag $url $image_name"
}

function render_local_config() {
    local config_key=$1
    local template_file=$2
    local config_file=$3
    local out=$4

    local config_type=yaml
    cmd="curl -F 'template_file=@$template_file' -F 'config_file=@$config_file' -F 'config_key=$config_key' -F 'config_type=$config_type'"
    cmd="$cmd http://config.dev.jiudouyu.com.cn/render-config > $out"
    run_cmd "$cmd"
}

function render_server_config {
    local config_key=$1
    local template_file=$2
    local config_file_name=$3

    local out=$4
    cmd="curl -F 'template_file=@$template_file' -F 'config_key=$config_key' -F 'config_file_name=$config_file_name'"
    cmd="$cmd http://config.dev.jiudouyu.com.cn/render-config > $out"
    run_cmd "$cmd"
}

function list_contains() {
    local var="$1"
    local str="$2"
    local val

    eval "val=\" \${$var} \""
    [ "${val%% $str *}" != "$val" ]
}
