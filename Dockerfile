FROM python:3.7.3-alpine

COPY ./root/ /

ARG BRANCH="topic/mongodb"
ENV VCB_BRANCH=${BRANCH}
ENV DISCORD_BOT_TOKEN=
ENV VCB_DB_PATH=/data/voice.db
ENV PYTHONUNBUFFERED=0
ENV ADMIN_USERS=
ENV VCB_DB_CONNECTION_STRING=


RUN \
	apk update && \
	apk add --update git curl && \
	# addgroup -S abc && adduser -S abc -G abc && \
	mkdir -p /app /data && \
	git clone --single-branch --branch ${VCB_BRANCH} https://github.com/camalot/VoiceCreateBot.git /app && \
	pip install --upgrade pip && \
	pip install -r /setup/requirements.txt && \
	# chown -R abc:abc /app && \
	# chown -R abc:abc /data && \
	apk del git && \
	rm -rf /setup && \
	rm -rf /var/cache/apk/*

VOLUME ["/data"]
WORKDIR /app

CMD ["python", "-u", "/app/voicecreate.py"]
