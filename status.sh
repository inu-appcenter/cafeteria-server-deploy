#!/bin/bash

function show_nginx_config() {
	config_prefix='cafeteria_'
	active_instance_port=$(cat /etc/nginx/conf.d/$config_prefix*.conf | grep -o '127.0.0.1:[0-9]*' | sed 's/127\.0\.0\.1://g')
	
        if [ "$active_instance_port" = "20201" ]; then
		echo "Active:	[instanceA:20201] running at: [$(lsof -i tcp:20201 | grep LISTEN | awk '{print $2}')]"
		echo "Idle:	[instanceB:20202] running at: [$(lsof -i tcp:20202 | grep LISTEN | awk '{print $2}')]"
        elif [ "$active_instance_port" = "20202" ]; then
		echo "Active:	[instanceB:20202] running at: [$(lsof -i tcp:20202 | grep LISTEN | awk '{print $2}')]"
		echo "Idle:	[instanceA:20201] running at: [$(lsof -i tcp:20201 | grep LISTEN | awk '{print $2}')]"
	else
		echo "No active setting"
	fi
}

show_nginx_config
