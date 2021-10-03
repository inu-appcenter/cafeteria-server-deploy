#!/usr/bin/env bash

docker stack deploy -c compose/app-api.yml app-api
