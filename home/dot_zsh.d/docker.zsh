alias dc="docker-compose"

function docker-ip(){
  container_name_or_id="$1"
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_name_or_id
}

# Credit: https://stackoverflow.com/questions/46166293/how-to-measure-docker-build-steps-duration/52192327#52192327
# $ cat /etc/docker/daemon.json
# {
#   "experimental": true
# }
export DOCKER_BUILDKIT=1
