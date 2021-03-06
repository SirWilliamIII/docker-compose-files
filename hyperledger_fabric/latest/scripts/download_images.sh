#!/usr/bin/env bash

# Define those global variables
if [ -f ./variables.sh ]; then
 source ./variables.sh
elif [ -f scripts/variables.sh ]; then
 source scripts/variables.sh
else
	echo_r "Cannot find the variables.sh files, pls check"
	exit 1
fi

pull_image() {
	IMG=$1
	if [ -z "$(docker images -q ${IMG} 2> /dev/null)" ]; then  # not exist
		docker pull ${IMG}
	else
		echo "${IMG} already exist locally"
	fi
}

echo "Downloading images from DockerHub... need a while"

# TODO: we may need some checking on pulling result?
echo "===Pulling fabric images from yeasy repo... with tag = ${FABRIC_IMG_TAG}"
for IMG in base peer orderer ca; do
	HLF_IMG=yeasy/hyperledger-fabric-${IMG}:$FABRIC_IMG_TAG
	pull_image $HLF_IMG
done
docker pull yeasy/hyperledger-fabric:$FABRIC_IMG_TAG \
&& docker pull docker pull yeasy/blockchain-explorer:0.1.0-preview  # TODO: wait for official images


echo "===Pulling base images from fabric repo... with tag = ${BASE_IMG_TAG}"
for IMG in baseimage baseos couchdb kafka zookeeper; do
	HLF_IMG=hyperledger/fabric-${IMG}:$ARCH-$BASE_IMG_TAG
	pull_image $HLF_IMG
done

# Only useful for debugging
# docker pull yeasy/hyperledger-fabric

echo "===Pulling fabric images from official repo... with tag = ${FABRIC_IMG_TAG}"
for IMG in peer tools orderer ca ccenv; do
	HLF_IMG=hyperledger/fabric-zookeeper:$ARCH-$BASE_IMG_TAG
	pull_image $HLF_IMG
done
docker pull hyperledger/fabric-ccenv:x86_64-1.1.0-alpha # no latest tag for ccenv
docker tag hyperledger/fabric-ccenv:x86_64-1.1.0-alpha hyperledger/fabric-ccenv:$ARCH-$PROJECT_VERSION

echo "Image pulling done, now can startup the network using docker-compose..."

exit 0
