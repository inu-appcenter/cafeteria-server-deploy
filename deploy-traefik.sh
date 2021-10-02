#!/usr/bin/env bash

export EMAIL=potados99@gmail.com
export DOMAIN_MAIN=potados.com
export DOMAIN_SANS=api.potados.com,console-api.potados.com

export USERNAME=potados
export HASHED_PASSWORD=$apr1$KK74D9PH$kmK1OiOdQlVXUF7SKLfkU.

docker stack deploy -c compose/traefik.yml traefik
