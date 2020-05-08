FROM python:3.7-alpine

COPY ./root/ /

ARG BRANCH="develop"
ARG BUILD_VERSION="1.0.0-snapshot"
ENV VCB_BRANCH=${BRANCH}
ENV DISCORD_BOT_TOKEN=
ENV VCB_DB_PATH=/data/voice.db
ENV PYTHONUNBUFFERED=0
ENV ADMIN_USERS=
ENV VCB_DB_CONNECTION_STRING=
ENV APP_VERSION=${BUILD_VERSION}


RUN \
	apk update && \
	apk add --update git curl build-base && \
	mkdir -p /app /data && \
	git clone --single-branch --branch ${VCB_BRANCH} https://github.com/camalot/VoiceCreateBot.git /app && \
	pip install --upgrade pip && \
	pip install -r /app/setup/requirements.txt && \
	sed -i "s/APP_VERSION = \"1.0.0-snapshot\"/APP_VERSION = \"${APP_VERSION}\"/g" "/app/cogs/voice.py" && \
	sed -i "s/\"version\": \"1.0.0-snapshot\"/\"version\": \"${APP_VERSION}\"/g" "/app/app.manifest" && \
	apk del git build-base && \
	rm -rf /app/setup && \
	rm -rf /var/cache/apk/*

VOLUME ["/data"]
WORKDIR /app

CMD ["python", "-u", "/app/main.py"]
