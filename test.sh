#!/bin/sh

############################################################
#                 此脚本为一键安装node-npm脚本                #
#                        2018-08-24                        #
#       使用方式为：./install-node.sh      #
############################################################

nodeVersion="8.11.4"
VERSIONPATTERN="[0-9]{1,2}.[0-9]{1,2}.[0-9]{1,2}"

echo -n "Please input a  node version number (Enter 8.11.4): "
read customVersion # user custom version, eg. 8.9.0

if [ ! -z $customVersion ]  # 如果输入的版本为空
then
    macthResult=$(echo $customVersion | grep -E -x $VERSIONPATTERN )
    if [ -z $macthResult ]
    then
        echo "Please input a  right version number. eg. 8.9.0 or 8.11.4"
        exit 1
    fi
    nodeVersion=$customVersion
fi

downloadAddress="https://nodejs.org/download/release/v${nodeVersion}/node-v${nodeVersion}-linux-x64.tar.gz"
downloadPath="/opt/"

nodePath="/opt/node/"
packageName="node.tar.gz"
sysPathFileForNode="/etc/profile.d/node.sh"  # system PATH file name for node.

currentUser=$(who | awk '{print $1}')


# Check if node is already installed.
checkNodeIsExist() {
    # 1.Check node folder exsit inside /opt/
    if [ -d "${nodePath}" ]
    then
        echo "Node folder inside /opt/ folder, please delete '/opt/node' or rename !"
        exit 1
    fi

    # 2.Check whether the node command exists.
    if [ ! -z $(which node) ]
    then
        echo "The node command already exists, please uninstall or rename !"
        exit 1
    fi

    # 3.Check whether the npm command exists.
    if [ ! -z $(which npm) ]
    then
        echo "The npm command already exists, please uninstall or rename !"
        exit 1
    fi

    # 4.Check whether the node config file exists.
    if [ -f "$sysPathFileForNode" ]
    then
        echo "The node config already exists, please delete '/etc/profile.d/node.sh' or rename !"
        exit 1
    fi
}

download() {
    echo "Download version is $nodeVersion"
    echo
    sudo wget -O $packageName $downloadAddress
    if [ $? -ne "0" ]
    then
        echo "The node package download faild !"
        exit 1
    fi
    sudo mv ./$packageName $downloadPath
    echo "The node v${nodeVersion} has been downloaded."
}

decompress() {
    sudo tar -zxf ${downloadPath}${packageName} -C $downloadPath
    sudo mv ${downloadPath}node-v${nodeVersion}-linux-x64 ${downloadPath}node
    sudo rm ${downloadPath}${packageName}
    if [ $? -ne "0" ]
    then
    	echo "Faild to decompressed!"
    	exit 1
    fi
    echo "The node package has been decompressed."
}

changePermission() {
    sudo chown ${currentUser}:${currentUser} ${nodePath} -R
    echo "The node folder permission has been changed."
}

# Configure system environment variables and export executable paths of node and NPM.
configSysPath() {
    local tempFile="node.sh"
    touch $tempFile
    echo 'export NODE_HOME=/opt/node' > $tempFile
    echo 'export PATH=$PATH:$NODE_HOME/bin' >> $tempFile
    echo 'export NODE_PATH=$PATH:$NODE_HOME/lib/node_modules' >> $tempFile
    sudo mv ./$tempFile $sysPathFileForNode
}

npmCompletion() {
    local temp="/home/${currentUser}/npm_completion"

    echo 'if type complete &>/dev/null; then
  _npm_completion () {
    local words cword
    if type _get_comp_words_by_ref &>/dev/null; then
      _get_comp_words_by_ref -n = -n @ -n : -w words -i cword
    else
      cword="$COMP_CWORD"
      words=("${COMP_WORDS[@]}")
    fi

    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           npm completion -- "${words[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"
    if type __ltrim_colon_completions &>/dev/null; then
      __ltrim_colon_completions "${words[cword]}"
    fi
  }
  complete -o default -F _npm_completion npm
elif type compdef &>/dev/null; then
  _npm_completion() {
    local si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                 COMP_LINE=$BUFFER \
                 COMP_POINT=0 \
                 npm completion -- "${words[@]}" \
                 2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
elif type compctl &>/dev/null; then
  _npm_completion () {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                       COMP_LINE="$line" \
                       COMP_POINT="$point" \
                       npm completion -- "${words[@]}" \
                       2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K _npm_completion npm
fi' > $temp
    sudo mv $temp /etc/bash_completion.d/
}

main() {
    echo "------------------------START-------------------------"
    # 1. check node installation
    checkNodeIsExist
    # 2. download node package
    download
    # 3. decompree node package
    decompress
    # 4. change node folder permission
    changePermission
    # 5. install npm completion
    npmCompletion
    # 6. configure node config
    configSysPath

    source $sysPathFileForNode # Enable the configuration to take effect immediately.
    echo "------------------------END-------------------------"
    echo -e "Successfully installed node and NPM.\nPlease try : node -v and npm -v"
}

main