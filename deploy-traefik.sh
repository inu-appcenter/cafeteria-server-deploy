#!/usr/bin/env bash

export EMAIL=potados99@gmail.com
export DOMAIN_MAIN=inu-cafeteria.app
export DOMAIN_SANS=api.inu-cafeteria.app,console-api.inu-cafeteria.app,traefik.inu-cafeteria.app

export USERNAME=potados
export HASHED_PASSWORD='$apr1$KK74D9PH$kmK1OiOdQlVXUF7SKLfkU.'

docker stack deploy -c compose/traefik.yml traefik
