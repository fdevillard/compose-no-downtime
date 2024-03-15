# compose-no-downtime

This is a simple example of how to deploy a service with no downtime using Docker Compose. We assume
that the service doesn't use an host resource that can't be used by two containers at the same time (like a host port).

The environment is composed of a:
- `web` service that runs a simple web server that returns its current version,
- `client` that sends requests to the `web` service and checks prints the version (this could also be a reverse proxy).

When running:
```
docker compose build
docker compose up -d

# Bump the version in `main.py` (let say from 0.1.0 to 0.1.1)
edit main.py

# Run the zero-downtime update
./update.sh
```

The expected behavior is that the `client`'s output should be (close to, as it isn't deterministic):
```
{"version":"0.1.0"}
{"version":"0.1.0"}
...
{"version":"0.1.0"}
# The update started
{"version":"0.1.0"}
{"version":"0.1.1"}
{"version":"0.1.1"}
{"version":"0.1.1"}
{"version":"0.1.0"}
{"version":"0.1.0"}
{"version":"0.1.1"}
{"version":"0.1.0"}
{"version":"0.1.0"}
{"version":"0.1.1"}
# The old container has been removed
{"version":"0.1.1"}
{"version":"0.1.1"}
{"version":"0.1.1"}
{"version":"0.1.1"}
{"version":"0.1.1"}
{"version":"0.1.1"}
```

In other words:
- the old version is running,
- the two versions are running at the same time for a brief period,
- the old version is removed.
