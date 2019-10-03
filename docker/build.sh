#!/bin/bash -e

VERSION=$1
if [[ -z ${VERSION} ]]
then
	echo "Usage: $0 domjudge-version"
	echo "	For example: $0 5.3.0"
	exit 1
fi

URL=https://www.domjudge.org/releases/domjudge-${VERSION}.tar.gz
FILE=domjudge.tar.gz

echo "[..] Downloading DOMJudge version ${VERSION}..."

if ! curl -f -s -o ${FILE} ${URL}
then
	echo "[!!] DOMjudge version ${VERSION} file not found on https://www.domjudge.org/releases"
	exit 1
fi

echo "[ok] DOMjudge version ${VERSION} downloaded as domjudge.tar.gz"; echo

echo "[..] Building Docker image for domserver using intermediate build image..."
docker build -t registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/domserver:${VERSION} -f domserver/Dockerfile .
echo "[ok] Done building Docker image for domserver"

echo "[..] Building Docker image for judgehost using intermediate build image..."
docker build -t registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/judgehost:${VERSION}-build -f judgehost/Dockerfile.build .
docker rm -f domjudge-judgehost-${VERSION}-build > /dev/null 2>&1 || true
docker run -it --name domjudge-judgehost-${VERSION}-build --privileged registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/judgehost:${VERSION}-build
docker cp domjudge-judgehost-${VERSION}-build:/chroot.tar.gz .
docker cp domjudge-judgehost-${VERSION}-build:/judgehost.tar.gz .
docker rm -f domjudge-judgehost-${VERSION}-build
docker rmi registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/judgehost:${VERSION}-build
docker build -t registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/judgehost:${VERSION} -f judgehost/Dockerfile .
echo "[ok] Done building Docker image for judgehost"

echo "[..] Building Docker image for judgehost chroot..."
docker build -t registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/default-judgehost-chroot:${VERSION} -f judgehost/Dockerfile.chroot .
echo "[ok] Done building Docker image for judgehost chroot"

echo "All done. Image registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/domserver:${VERSION} and registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/judgehost:${VERSION} created"
echo "If you are a DOMjudge maintainer with access to the domjudge organization on Docker Hub, you can now run the following command to push them to Docker Hub:"
echo "$ docker push registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/domserver:${VERSION} && docker push registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/judgehost:${VERSION} && docker push registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/default-judgehost-chroot:${VERSION}"
echo "If this is the latest release, also run the following command:"
echo "$ docker tag registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/domserver:${VERSION} registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/domserver:latest && \
docker tag registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/judgehost:${VERSION} registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/judgehost:latest && \
docker tag registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/default-judgehost-chroot:${VERSION} registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/default-judgehost-chroot:latest && \
docker push registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/domserver:latest && docker push registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/judgehost:latest && docker push registry.dajo.dev/error418/hbo-i_apc/domjudge-packaging/default-judgehost-chroot:latest"
