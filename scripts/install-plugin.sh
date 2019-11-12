#!/bin/bash

set -e

# run krew install process

cd "$(mktemp -d)" &&
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/{{= version }}/krew.{tar.gz,yaml}" &&
tar zxvf krew.tar.gz &&
./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" install \
--manifest=krew.yaml --archive=krew.tar.gz

# add ${KREW_ROOT:-$HOME/.krew}/bin to PATH in bashrc/zshrc
# but only if it does not already exist in bashrc/zshrc

EXPORT_PATH_STRING='export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"'

if [ "$SHELL" == "/bin/bash" ]
then
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
        echo "default shell is /bin/bash but ~/.bashrc not found"
        echo "please add '$EXPORT_PATH_STRING' to your login script"
    fi
else
    if [ "$SHELL" == "/bin/zsh" ]
    then
        if [ -e ~/.zshrc ]
        then
            if grep -Fxq "$EXPORT_PATH_STRING" ~/.zshrc
            then
                echo "krew found in zshrc, not adding again"
            else
                echo "$EXPORT_PATH_STRING not found in zshrc, adding now"
                echo "" >> ~/.zshrc
                echo "# krew path" >> ~/.zshrc
                echo "$EXPORT_PATH_STRING" >> ~/.zshrc
                echo "you will need to rerun your zshrc with `. ~/.zshrc` or add krew to your path with '$EXPORT_PATH_STRING' before krew can be used"
            fi
        else
            echo "default shell is /bin/zsh but ~/.zshrc not found"
            echo "please add '$EXPORT_PATH_STRING' to your login script"
        fi
    else
        echo "default shell '$SHELL' was not recognized, please add '$EXPORT_PATH_STRING' to your login script"
    fi
fi

# install requested krew plugin
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
kubectl-krew install {{= plugin }}
