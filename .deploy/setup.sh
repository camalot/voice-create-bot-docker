#!/usr/bin/env bash

set -e;

INSTANCE_NAME="voice-create-bot-docker";

sudo mkdir -p /mnt/data/${INSTANCE_NAME}/data;

sudo chown $USER:$USER /mnt/data/${INSTANCE_NAME};
