echo '[install] Starting install of docker and boot2docker using brew'
brew install docker boot2docker
echo '[install] Initializing boot2docker'
boot2docker init
echo '[install] Starting boot2docker'
boot2docker up
echo '[install] Installing spurious'
gem install spurious
echo '[install] Starting spurious server'
DOCKER_HOST=tcp://$(boot2docker ip 2>/dev/null):2375 spurious-server start
echo '[install] Initializing spurious'
spurious init
echo '[install] Starting spurious'
spurious start
echo '\n----------------------'
echo 'Installation complete'
echo '\nPlease add the following export to you ~/.bashrc or ~/.zshrc:'
echo "\nexport DOCKER_HOST=tcp://$(boot2docker ip 2>/dev/null):2375"
