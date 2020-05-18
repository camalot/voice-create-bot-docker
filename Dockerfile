FROM python:3.8-alpine

ARG BRANCH="develop"
ARG BUILD_VERSION="1.0.0-snapshot"
ARG PROJECT_NAME=

ENV VCB_BRANCH=${BRANCH}
ENV DISCORD_BOT_TOKEN=
ENV VCB_DB_PATH=/data/voice.db
ENV PYTHONUNBUFFERED=0
ENV ADMIN_USERS=
ENV VCB_DB_CONNECTION_STRING=
ENV APP_VERSION=${BUILD_VERSION}

LABEL VERSION="${BUILD_VERSION}"
LABEL BRANCH="${BRANCH}"
LABEL PROJECT_NAME="${PROJECT_NAME}"

RUN \
	apk update && \
	apk add --update git curl build-base && \
	mkdir -p /app /data && \
	git clone --single-branch --branch ${VCB_BRANCH} https://github.com/camalot/VoiceCreateBot.git /app && \
	pip install --upgrade pip && \
	pip install -r /app/setup/requirements.txt && \
	sed -i "s/APP_VERSION = \"1.0.0-snapshot\"/APP_VERSION = \"${APP_VERSION}\"/g" "/app/bot/cogs/settings.py" && \
	sed -i "s/\"version\": \"1.0.0-snapshot\"/\"version\": \"${APP_VERSION}\"/g" "/app/app.manifest" && \
	apk del git build-base && \
	rm -rf /app/setup && \
	rm -rf /var/cache/apk/*

VOLUME ["/data"]
WORKDIR /app

CMD ["python", "-u", "/app/main.py"]
