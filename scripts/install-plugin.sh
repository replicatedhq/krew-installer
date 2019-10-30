#!/bin/bash

set -e

# run krew install process

cd "$(mktemp -d)" &&
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/{{= version }}/krew.{tar.gz,yaml}" &&
tar zxvf krew.tar.gz &&
./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" install \
--manifest=krew.yaml --archive=krew.tar.gz

# add ${KREW_ROOT:-$HOME/.krew}/bin to PATH in bashrc
# but only if it does not already exist in bashrc

EXPORT_PATH_STRING='export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"'

if [ -e ~/.bashrc ]
then
    if grep -Fxq "$EXPORT_PATH_STRING" ~/.bashrc
    then
        echo "krew found in bashrc, not adding again"
    else
        echo "$EXPORT_PATH_STRING not found in bashrc, adding now"
        echo "" >> ~/.bashrc
        echo "# krew path" >> ~/.bashrc
        echo "$EXPORT_PATH_STRING" >> ~/.bashrc
        echo "you will need to reload your shell with `bash -l` or add krew to your path with '$EXPORT_PATH_STRING' before krew can be used"
    fi
else
    echo "~/.bashrc not found, please add '$EXPORT_PATH_STRING' to your login script"
fi

# install requested krew plugin
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
kubectl-krew install {{= plugin }}
