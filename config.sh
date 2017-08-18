#!/bin/bash

set -e

prj_path=$(cd $(dirname $0); pwd -P)
SCRIPTFILE=`basename $0`

source $prj_path/base.sh

app=fastsrv

nginx_image=nginx:1.11
app_image=liaohuqiu/fastsrv

nginx_container=g-nginx
app_container=fastsrv

docker_path='/data0/docker'

app_strorage_dir="/opt/data/$app"
nginx_config_gen_dir="$app_strorage_dir/nginx-gen-config"

function build() {
    run_cmd "docker build -t $app_image $prj_path/fastsrv"
}

function _run_app_container() {
    local cmd=$1
    local host_ip=$(ip addr show | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | awk '{print $1}' | head  -1)
    args="$args --restart always"
    run_cmd "docker run $args -d --name $app_container $app_image bash -c '$cmd'"
}

function _send_cmd_to_app() {
    local cmd=$1
    run_cmd "docker exec -it $app_container bash -c '$cmd'"
}

function _send_cmd_to_ngix() {
    local cmd=$1
    run_cmd "docker exec -it $nginx_container bash -c '$cmd'"
}

function to_app() {
    local cmd='bash'
    _send_cmd_to_app "$cmd"
}

function run_app() {
    local cmd='python manage.py runserver 0.0.0.0:8000'
    _run_app_container "$cmd"
}

function stop_app() {
    stop_container $app_container
}

function stop() {
    stop_app
    stop_nginx
}

function restart() {
    stop
    run
}

function build_config() {
    local cmd="python build-conf.py"
    _send_cmd_to_app "$cmd"
}

function run() {
    run_app
    build_config
    run_nginx
}

function stop() {
    stop_nginx
    stop_app
}

function run_nginx() {

    local nginx_data_dir=$prj_path/nginx-data
    local nginx_log_path=$app_strorage_dir/logs/nginx
    local args="--restart=always -p 80:80 -p 443:443"

    # nginx config
    args="$args -v $nginx_data_dir/conf/nginx.conf:/etc/nginx/nginx.conf"

    # for the other sites
    args="$args -v $nginx_data_dir/conf/extra/:/etc/nginx/extra"

    # nginx certificate
    args="$args -v $nginx_data_dir/ssl-cert/:/etc/nginx/ssl-cert"

    # logs
    args="$args -v $nginx_log_path:/var/log/nginx"

    # generated nginx docker sites config
    args="$args -v $nginx_config_gen_dir:/etc/nginx/docker-sites"

    args="$args --link $app_container"

    args="$args -v $docker_path:$docker_path"

    run_cmd "docker run -d $args --name $nginx_container $nginx_image"
}

function to_nginx() {
    local cmd='bash'
    _send_cmd_to_ngix $cmd
}

function reload() {
    
    build_config

    cmd='nginx -s reload'
    run_cmd "docker exec -it $nginx_container $cmd"
}

function stop_nginx() {
    stop_container $nginx_container
}

function help() {
        cat <<-EOF
    
    Usage: manager.sh [options]

            Valid options are:

            build

            run                     build config then start nginx
            reload                  build config then reload nginx
            restart

            stop

            stop_nginx
            to_nginx
            
            run_app                 
            to_app                  go into app container
            stop_app                
            build_config            build config in app container then copy the result into auto-gen:w
            
            -h                      show this help message and exit

EOF
}

action=${1:-help}
ALL_COMMANDS="build run reload restart run_app to_app stop stop_app stop_nginx build_config to_nginx"
list_contains ALL_COMMANDS "$action" || action=help
$action "$@"
