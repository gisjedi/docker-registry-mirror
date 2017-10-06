#!/bin/sh

CONFIG_FILE=/etc/docker/registry/config.yml
echo "proxy:" >> $CONFIG_FILE
echo "  remoteurl: $REGISTRY_URL" >> $CONFIG_FILE
if [[ ! -z "$REGISTRY_USERNAME" && ! -z "$REGISTRY_PASSWORD" ]]
then
	echo "  username: $REGISTRY_USERNAME" >> $CONFIG_FILE
	echo "  password: $REGISTRY_PASSWORD" >> $CONFIG_FILE
fi

exec /entrypoint.sh "$@"
