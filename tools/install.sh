#!/bin/bash

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

if [[ $(command -v docker) ]]; then
  DOCKER_VERSION=$(docker -v | cut -d',' -f 1 | cut -d' ' -f 3)
  vercomp $DOCKER_VERSION "1.1.0"
  if [[ $? == 2 ]]; then
    echo "You must have version 1.1.0 of the docker client installed, currently installed: $DOCKER_VERSION"
    exit 1
  fi
fi

if [[ $(command -v ruby) ]]; then
  IS_JRUBY=$(ruby -v | cut -d' ' -f1)
  if [[ $IS_JRUBY == "jruby" ]]; then
    echo "Spurious should be run on standard MRI ruby (Specifically the server needs to as it uses fork but you can install the CLI tool under jruby"
    exit 1
  else
    RUBY_VERSION=$(ruby -v | cut -d' ' -f2 | cut -d'p' -f1)
    vercomp $RUBY_VERSION "1.9"
    if [[ $? == 2 ]]; then
      echo "You must have version 1.9 or greater of ruby installed, currently installed: $(ruby -v)"
      exit 1
    fi
  fi
fi

echo '[install] Starting install of docker and docker-machine using brew'
brew install docker docker-machine
echo '[install] Initializing docker-machine'
docker-machine create development
echo '[install] Installing spurious'
gem install spurious
echo '[install] Starting spurious server'
DOCKER_HOST=tcp://$(docker-machine ip development 2>/dev/null):2376 spurious-server start
echo '[install] Initializing spurious'
spurious init
echo '[install] Starting spurious'
spurious start
echo '\n----------------------'
echo 'Installation complete'
echo '\nPlease add the following export to your ~/.bashrc or ~/.zshrc:'
echo "\nexport DOCKER_HOST=tcp://$(docker-machine ip development 2>/dev/null):2376"
