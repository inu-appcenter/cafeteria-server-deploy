#!/usr/bin/env bash

docker service logs cafeteria_app-api -f -n 50
