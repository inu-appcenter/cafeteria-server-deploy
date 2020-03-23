#!/bin/bash

# Download and launch new instance.
# We use two instances: A:20201 and B:20202.

remote_source='https://github.com/inu-appcenter/cafeteria-server.git'

function get_instance_info() {
	active_instance_port=$(cat /etc/nginx/conf.d/$config_prefix*.conf | grep -o '127.0.0.1:[0-9]*' | sed 's/127\.0\.0\.1://g')

	if [ "$active_instance_port" = "20201" ]; then
		active_instance='instanceA'
		target_instance='instanceB'
		target_port='20202'
		target_pid=$(lsof -i tcp:20202 | grep LISTEN | awk '{print $2}')
	elif [ "$active_instance_port" = "20202" ]; then
		active_instance='instanceB'
		target_instance='instanceA'
		target_port='20201'
		target_pid=$(lsof -i tcp:20201 | grep LISTEN | awk '{print $2}')
	else
		target_instance='instanceA'
		target_port='20201'
	fi
	
	echo "active: [$active_instance], target: [$target_instance:$target_port], target pid: [$target_pid]"

	echo "got instance info"
}

function move_to_deploy_dir() {
	if [ $# -lt 1 ]; then
		echo 'Deploy direcotry not specified!'
		exit 1
	fi

	deploy_dir=$1

	cd $deploy_dir

	echo "moved to deploy directory: $deploy_dir"
}

function create_instance_dirs() {
	mkdir -p instanceA
	mkdir -p instanceB

	echo "instance directories created"
}

function kill_target_instance() {
	if [ -z $target_pid ]; then
		# no target instance 
		echo "no target instance running"
	else
		kill -9 $target_pid || exit 1
		echo "killed target instance: $target_pid"
	fi
}

function download_new_source() {
	rm -rf $target_instance || exit 1

	echo "purged target instance directory: $target_instance"

	git clone $remote_source $target_instance > /dev/null || exit 1

	echo "clone source into target instance directory: $target_instance"
}

function start_target_instance() {
	cd $target_instance
	npm install > /dev/null || exit 1
	nohup npm start -- --port=$target_port --log-dir=../logs || exit 1 &
	cd ..
}

function activate_target_instance() {
	echo "yeah to $target_instance"
}

get_instance_info
move_to_deploy_dir $@ 

create_instance_dirs
kill_target_instance
download_new_source
start_target_instance

activate_target_instance

