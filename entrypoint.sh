#!/bin/sh -l

export

echo "====================="
echo "= Running OPA Tests ="
echo "====================="

if [ ! -z "$INPUT_PULL_IMAGE" ]; then
    # Registry credentials will be stored here
    AUTH_FILE_DIR="$HOME/.docker"
    mkdir -p $AUTH_FILE_DIR
    AUTH_FILE="$AUTH_FILE_DIR/config.json"

    # Registry credentials content JSON structure
    JSON_FMT='{"auths": {"%s": {"auth": "%s"}}}'

    # Strip image:tag
    REGISTRY=${INPUT_PULL_IMAGE%/*}

    if [ ! -z "$REGISTRY_USER" -a ! -z "$REGISTRY_PWD" ]; then
        printf "$JSON_FMT" "$REGISTRY" "$(echo "$REGISTRY_USER:$REGISTRY_PWD" | base64 -w 0)" > $AUTH_FILE
    fi

    conftest pull $INPUT_PULL_IMAGE -p $INPUT_POLICY
fi

if [ "$INPUT_HELM" == "true" ]; then
    helm conftest -p $INPUT_POLICY -o $INPUT_OUTPUT --namespace $INPUT_NAMESPACE $INPUT_PATH
else
    conftest test -p $INPUT_POLICY -o $INPUT_OUTPUT --namespace $INPUT_NAMESPACE $INPUT_PATH
fi
