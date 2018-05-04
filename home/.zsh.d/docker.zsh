alias dc="docker-compose"

function docker-ip(){
  container_name_or_id="$1"
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_name_or_id
}
