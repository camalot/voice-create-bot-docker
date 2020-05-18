#!/usr/bin/env bash
set -e;

base_dir=$(dirname "$0");
# shellcheck source=/dev/null
source "${base_dir}/../.deploy/shared.sh";

get_opts() {
	while getopts ":v:n:o" opt; do
		case $opt in
			v) export opt_version="$OPTARG";
			;;
			n) export opt_name="$OPTARG";
			;;
			o) export opt_org="$OPTARG";
			;;
			\?) echo "Invalid option -$OPTARG" >&2;
			exit 1;
			;;
		esac;
	done;

	return 0;
};

docker_tag_exists() {
    TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_HUB_USERNAME}'", "password": "'${DOCKER_HUB_PASSWORD}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
    EXISTS=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/$1/tags/?page_size=10000 | jq -r "[.results | .[] | .name == \"$2\"] | any")
    test $EXISTS = true
}

[[ -z "${DOCKER_HUB_USERNAME// }" ]] && __error "Environment variable 'DOCKER_HUB_USERNAME' missing";
[[ -z "${DOCKER_HUB_PASSWORD// }" ]] && __error "Environment variable 'DOCKER_HUB_PASSWORD' missing";

WORKDIR="${WORKSPACE:-"${pwd}"}";
get_opts "$@";

DOCKER_ORG="${opt_org:-"${DOCKER_HUB_USERNAME}"}";
TAG_VERSION="${opt_version:-"${APPVEYOR_BUILD_VERSION}"}";
INSTANCE_NAME="${opt_name:-"${APPVEYOR_PROJECT_NAME}"}";
DOCKER_IMAGE="${DOCKER_ORG}/${INSTANCE_NAME}";

[[ -z "${DOCKER_ORG// }" ]] && __error "Environment variable 'DOCKER_ORG' missing or empty.";
[[ -z "${TAG_VERSION// }" ]] && __error "Environment variable 'CI_BUILD_VERSION' missing or empty.";
[[ -z "${INSTANCE_NAME// }" ]] && __error "Environment variable 'APPVEYOR_PROJECT_NAME' missing or empty.";

sleep 5;

! docker_tag_exists "${DOCKER_IMAGE}" "${TAG_VERSION}" && __error "Tag '${DOCKER_IMAGE}/${TAG_VERSION}' was not found in Docker Hub";

exit 0;
