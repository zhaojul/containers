#!/bin/bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

registry="docker.io"
repository="zhaojli/nginx"
tag=`cat ${dir}/version`

BUILD () {
docker build --pull --no-cache \
    -f ${dir}/Dockerfile \
    -t ${registry}/${repository}:${tag} \
    -t ${registry}/${repository}:${tag}-alpine \
    -t ${registry}/${repository}:latest \
    ${dir}
}

TEST () {
docker rm -f image-test
docker run --name image-test -tid ${registry}/${repository}:${tag}
docker exec -i image-test /bin/sh -c "curl http://127.0.0.1"
if [ $? -eq 0 ]; then
    echo "image run check success.";
else
    echo "image run check faild.";
    exit 1;
fi
docker rm -f image-test
}


PUSH () {
docker push ${registry}/${repository}:${tag}
docker push ${registry}/${repository}:${tag}-alpine
docker push ${registry}/${repository}:latest
}


HELP () {
cat << USAGE
usage:
    --build : Build images
    --push : Push images
    --test : Test images
USAGE
exit 0
}


case "${1}" in
--build)
        BUILD
        ;;
--push)
        PUSH
        ;;
--test)
        TEST
        ;;
*)
        HELP;
        ;;
esac

