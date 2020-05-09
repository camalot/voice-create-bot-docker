#!/usr/bin/env bash
set -e;

base_dir=$(dirname "$0");
# shellcheck source=/dev/null
source "${base_dir}/../.deploy/shared.sh";

get_opts() {
	while getopts ":n:v:o:f" opt; do
	  case $opt in
			n) export opt_project_name="$OPTARG";
			;;
			v) export opt_version="$OPTARG";
			;;
			o) export opt_docker_org="$OPTARG";
			;;
			f) export opt_force="--no-cache ";
			;;
			\?) echo "Invalid option -$OPTARG" >&2;
			exit 1;
			;;
		esac;
	done;

	return 0;
};

get_opts "$@";

BUILD_PROJECT="${opt_project_name:-"${APPVEYOR_PROJECT_NAME}"}";
BUILD_VERSION="${opt_version:-"${APPVEYOR_BUILD_VERSION:-"1.0.0-snapshot"}"}";
BUILD_ORG="${opt_docker_org:-"${DOCKER_HUB_USERNAME}"}";
WORKDIR="${WORKSPACE:-"${pwd}"}";

[[ -z "${BUILD_PROJECT// }" ]] && __error "Environment variable 'APPVEYOR_PROJECT_NAME' missing or empty.";
[[ -z "${BUILD_VERSION// }" ]] && __error "Environment variable 'APPVEYOR_BUILD_VERSION' missing or empty.";
[[ -z "${BUILD_ORG// }" ]] && __error "Environment variable 'DOCKER_HUB_USERNAME' missing or empty.";

tag="${BUILD_ORG}/${BUILD_PROJECT}";
tag_name_latest="${tag}:latest";
tag_name_ver="${tag}:${BUILD_VERSION}";

# Docker Push
docker login --username "${DOCKER_HUB_USERNAME}" --password-stdin <<< "${DOCKER_HUB_PASSWORD}";
# Only push "non-snapshots" to docker hub
[[ ! $BUILD_VERSION =~ -snapshot$ ]] && \
	docker push "${tag_name_latest}" && \
	docker push "${tag_name_ver}";

docker logout

unset BUILD_PROJECT;
unset BUILD_VERSION;
unset BUILD_ORG;
