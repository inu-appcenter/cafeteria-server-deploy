#!/bin/bash

# Download and launch new instance.
# We use two instances: A:20201 and B:20202.

script_home="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
env_file_name='exports.sh'
config_prefix='cafeteria_'
remote_source='https://github.com/inu-appcenter/cafeteria-server.git'

if [ $# -lt 1 ]; then
	echo 'Deploy direcotry not specified!'
	exit 1
fi

deploy_dir=$1

function get_instance_info() {
	active_instance_port=$(cat /etc/nginx/conf.d/$config_prefix*.conf | grep -o '127.0.0.1:[0-9]*' | sed 's/127\.0\.0\.1://g')

	if [ "$active_instance_port" = "20201" ]; then
		active_instance='instanceA'
		target_instance='instanceB'
		target_port='20202'
	elif [ "$active_instance_port" = "20202" ]; then
		active_instance='instanceB'
		target_instance='instanceA'
		target_port='20201'
	else
		target_instance='instanceA'
		target_port='20201'
	fi
	
	echo "active: [$active_instance], target: [$target_instance]"

	echo "got instance info"
}

function set_env() {
	source $deploy_dir/exports.sh
}

function create_instance_dirs() {
	mkdir -p $deploy_dir/instanceA
	mkdir -p $deploy_dir/instanceB

	echo "instance directories created"
}

function kill_target_instance() {
	fuser -n tcp -k $target_port

	echo "killed all processes listening on $target_port"
}

function download_new_source() {
	rm -rf $deploy_dir/$target_instance || exit 1

	echo "purged target instance directory: $target_instance"

	git clone $remote_source $deploy_dir/$target_instance > /dev/null || exit 1

	echo "clone source into target instance directory: $target_instance"
}

function start_target_instance() {
	cd $deploy_dir/$target_instance

	npm install > /dev/null || exit 1
	
	echo "dependencies installed"

	nohup npm start -- --port=$target_port --log-dir=../logs > /dev/null || exit 1 &

	cd $script_home

	echo "waiting for process"
	while [ -z "$(lsof -i tcp:$target_port | grep LISTEN | awk '{print $2}')" ]; do
		echo -n "."
		sleep 0.5
	done
	echo "application started!"
}

function activate_target_instance() {
	sudo rm -f /etc/nginx/conf.d/$config_prefix*.conf || exit 1
	sudo cp $script_home/conf.d/$config_prefix$target_instance.conf /etc/nginx/conf.d/ || exit 1

	echo "replaced nginx config file"
}

function show_result() {
	active_instance_port=$(cat /etc/nginx/conf.d/$config_prefix*.conf | grep -o '127.0.0.1:[0-9]*' | sed 's/127\.0\.0\.1://g')
	if [ "$active_instance_port" != "$target_port" ]; then
		echo "nginx setting failed"
		exit 1
	fi

	active_pid=$(lsof -i tcp:$target_port | grep LISTEN | awk '{print $2}')
	if [ -z "$active_pid" ]; then
		echo "no process listening on $target_port"
		exit 1
	fi

	cd $deploy_dir/$target_instance
	rev_count=$(git rev-list HEAD --count)
	cd $script_home

	echo ""
	echo "################################ Deploy succeeded ################################"
	echo ""
	echo "Now active: [$target_instance] listening on [$target_port] running at [$active_pid]"
	echo "Git revision count: [$rev_count]"
}

get_instance_info
set_env

create_instance_dirs
kill_target_instance
download_new_source
start_target_instance

activate_target_instance
show_result
