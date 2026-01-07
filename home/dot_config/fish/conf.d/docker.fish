# Check if we're using podman instead of docker
if command -v podman > /dev/null 2>&1; and not command -v docker > /dev/null 2>&1
    # Create docker alias
    alias docker='podman'

    # Set Docker socket environment variable
    set -gx DOCKER_HOST "unix://$HOME/.local/share/containers/podman/machine/podman.sock"

    # If podman-compose exists, alias docker-compose
    if command -v podman-compose > /dev/null 2>&1
        alias docker-compose='podman-compose'
    end
end
