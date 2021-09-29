#! /bin/bash

help() {
    echo "Create docker images for all tags present in .tags file."
    echo 
    echo "Usage $0 <repository_name>"
    echo "repository_name: The repository name you intend to push the tags to."
}

if [ -z "$1" ]; then
    help
    exit 1
fi

REPOSITORY=$1
CREATED_TAGS=()

case `uname -m` in 
    "x86_64"*)
        SUPPORTED_ARCHITECTURE="amd64"
        ;;
esac

function create_tag() {
    DIRECTORY=$1
    ARCHITECTURE=$2
    TAGS=$3
    BASE_IMAGE=$4
    if [[ "$ARCHITECTURE" =~ .*"$SUPPORTED_ARCHITECTURE".* ]]; then
        for TAG in ${TAGS//,/ }; do
          if [ -z "${BASE_IMAGE}" ]; then
              docker build $DIRECTORY -t $REPOSITORY:$TAG
          else
              docker build $DIRECTORY --build-arg BASE_IMAGE=${BASE_IMAGE} -t $REPOSITORY:$TAG
          fi
            CREATED_TAGS+=("$REPOSITORY:$TAG")
        done

    fi
}

while read -r line; do
    PARAM=$(echo $line | cut -d':' -f1)
    case $PARAM in 
        "Tags"*)
            TAGS=$(echo $line | cut -d':' -f2)
            ;;
        "Architecture"*)
            ARCHITECTURE=$(echo $line | cut -d':' -f2)
            ;;
        "Directory"*)
            DIRECTORY=$(echo $line | cut -d':' -f2)
            ;;
        "BaseImage"*)
            BASE_IMAGE=$(echo $line | sed 's/BaseImage\: //g')
            echo Found BaseImage is $BASE_IMAGE
            ;;
        ""*)
        create_tag "$DIRECTORY" "$ARCHITECTURE" "$(echo $TAGS | sed -e 's/ //g')" "${BASE_IMAGE:-""}"
    esac
done < .tags

(IFS=$'\n'; echo "${CREATED_TAGS[*]}")
