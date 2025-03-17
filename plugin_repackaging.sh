#!/bin/bash
# author: Junjie.M

MARKETPLACE_API_URL=https://marketplace.dify.ai
PIP_MIRROR_URL=https://mirrors.aliyun.com/pypi/simple

market(){
  if [[ -z "$2" || -z "$3" || -z "$4" ]]; then
        echo ""
        echo "Usage: "$0" market [plugin author] [plugin name] [plugin version]"
        echo "Example:"
        echo "	"$0" market junjiem mcp_sse 0.0.1"
        echo "	"$0" market langgenius agent 0.0.9"
        echo ""
        exit 2
  fi
  echo "From the Dify Marketplace downloading ..."
	PLUGIN_AUTHOR=$2
  PLUGIN_NAME=$3
  PLUGIN_VERSION=$4
  PLUGIN_ALL_NAME=${PLUGIN_AUTHOR}-${PLUGIN_NAME}_${PLUGIN_VERSION}
  PLUGIN_PACKAGE_NAME=${PLUGIN_ALL_NAME}.difypkg
	PLUGIN_DOWNLOAD_URL=${MARKETPLACE_API_URL}/api/v1/plugins/${PLUGIN_AUTHOR}/${PLUGIN_NAME}/${PLUGIN_VERSION}/download
	repackage ${PLUGIN_ALL_NAME} ${PLUGIN_PACKAGE_NAME} ${PLUGIN_DOWNLOAD_URL}
}

github(){
  if [[ -z "$2" || -z "$3" || -z "$4" ]]; then
        echo ""
        echo "Usage: "$0" github [Github repo] [Release title] [Assets name (include .difypkg suffix)]"
        echo "Example:"
        echo "	"$0" github https://github.com/junjiem/dify-plugin-tools-dbquery v0.0.2 db_query.difypkg"
        echo "	"$0" github https://github.com/junjiem/dify-plugin-agent-mcp_sse 0.0.1 agent-mcp_see.difypkg"
        echo ""
        exit 3
  fi
  echo "From the Github downloading ..."
  GITHUB_REPO=$2
  RELEASE_TITLE=$3
  ASSETS_NAME=$4
  PLUGIN_NAME="${ASSETS_NAME%.difypkg}"
  PLUGIN_ALL_NAME=${PLUGIN_NAME}-${RELEASE_TITLE}
  PLUGIN_PACKAGE_NAME=${PLUGIN_ALL_NAME}.difypkg
  PLUGIN_DOWNLOAD_URL=${GITHUB_REPO}/releases/download/${RELEASE_TITLE}/${ASSETS_NAME}
  repackage ${PLUGIN_ALL_NAME} ${PLUGIN_PACKAGE_NAME} ${PLUGIN_DOWNLOAD_URL}
}

repackage(){
  local PLUGIN_ALL_NAME=$1
  local PLUGIN_PACKAGE_NAME=$2
  local PLUGIN_DOWNLOAD_URL=$3
	echo "Download ${PLUGIN_PACKAGE_NAME} ..."
	curl -L -o ./${PLUGIN_PACKAGE_NAME} ${PLUGIN_DOWNLOAD_URL}
	if [[ $? -ne 0 ]]; then
		echo "Download failed, please check the plugin author, name and version."
		exit 1
	fi
	echo "Download success, unziping ..."
	install_unzip
	unzip -o ./${PLUGIN_PACKAGE_NAME} -d ./${PLUGIN_ALL_NAME}
	echo "Unzip success, repackaging ..."
	cd ./${PLUGIN_ALL_NAME}
	pip download -r requirements.txt -d ./wheels --index-url ${PIP_MIRROR_URL}
	sed -i '1i\--no-index --find-links=./wheels/' requirements.txt
	sed -i '/^wheels\//d' .difyignore
	cd ..
	chmod 755 ./dify-plugin-linux-amd64-5g
	./dify-plugin-linux-amd64-5g plugin package ./${PLUGIN_ALL_NAME} -o ${PLUGIN_ALL_NAME}-offline.difypkg
}

install_unzip(){
	rpms=(`rpm -q unzip`)
	if [ ${#rpms[@]} -ne 1 ]; then
		echo "Installing unzip ..."
		yum -y install unzip
		if [ $? -ne 0 ]; then
			echo "Install unzip failed."
			exit 11
		fi
	fi
}

case "$1" in
	'market')
	market $@
	;;
	'github')
	github $@
	;;
	*)

echo "usage: $0 {market|github}"
exit 1
esac
exit 0
