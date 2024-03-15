set -euxo pipefail

# Well, well, well.
# We want a zero down-time `docker compose up -d` command (for a specific service).
# This is a mock script to demonstrate how to achieve that.

SERVICE="web"

# Lets mimic a spec change by rebuilding the target service
docker compose build "$SERVICE"

# We query the existing containers for the service that will be used after
existing_containers=$(docker compose ps "$SERVICE" --format "{{.Name}}")
echo "Existing containers: $existing_containers"

# First step is to scale the up without deleting the previous one
docker compose up -d --no-recreate --scale "$SERVICE=2"

# We wait for the containers to be healthy
# See the healthcheck configuration in the Dockerfile file
while true; do
  healthy_containers=$(docker compose ps "$SERVICE" --format "{{.Health}}" | sort | uniq)
  if [[ "$healthy_containers" == "healthy" ]]; then
    break
  fi
  echo "Not all containers are healthy yet. Waiting..."
  sleep 5
done

# Now that all are up, let kill the old ones
for container in $existing_containers; do
  docker stop "$container"
  # we directly remove the container as it could otherwise be re-used when scaling the service up again.
  docker container rm "$container"
done

# We ensure the rest of the compose file is updated too
exec docker compose up -d