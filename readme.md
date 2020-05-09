

[![Build status](https://ci.appveyor.com/api/projects/status/4i8e8r17to5rbi7l?svg=true)](https://ci.appveyor.com/project/camalot/voice-create-bot-docker)


# Deploy to Azure

- Download and install Azure CLI
- Run `az login`
- Create file `.env` that contains the following environment variables:
	- `AZ_LOCATION`
	- `AZ_RESOURCE_GROUP`
	- `DISCORD_BOT_TOKEN`
	- `VCB_DB_PATH`