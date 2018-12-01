# synapse
Production-grade, alpine-sized version of matrix.org's Synapse

# User Mapping

You have the following options for mapping the host user/group to th container user/group:

1. (Recommended as you can run in `--read-only` mode) Create a host user with id 3400 so that ownership naturally maps between host and container:

`sudo useradd --no-create-home --system --shell /bin/false --uid 3400 synapse'

2. Pass in `-e UID=$(id -u)` and `-e GID=$(id -g)` as part of your `docker run` command. Upon starting the container, it will use `usermod` and `groupmod` to change the id of the container's user/group to match what you have specified. This method can't be run in `--read-only` as it involves modifying `/etc/passwd`.

# Getting started

You will need to generate a config, keys etc... Do so by adding "generate" and "your-server-name" as CMD arguments (see below)

```
docker run \
    --name synapse \
    --init \
    --rm \
    -v $PWD/config:/config \
    -v $PWD/data:/data \
    robertbeal/synapse generate example.com
```

Some of the default config paths point at root... let's clean that up:

sed -i \
    -e '/database: / s@"/homeserver.db"@"/data/homeserver.db"@' \
    -e '/log_file: / s@"/homeserver.log"@"/data/homeserver.log"@' \
    -e '/media_store_path: / s@"/media_store"@"/data/media"@' \
    -e '/uploads_path:/ s@"/uploads"@"/data/uploads"@' \
    $PWD/config/homeserver.yaml
sed -i \
    -e '/filename: / s@/homeserver.log@/data/homeserver.log@' \
    $PWD/config/example.com.log.config

# Running the server

* It is recommended to run Synapse behind a reverse proxy port 443 => 8008 (hence it is mapped to `127.0.0.1` in the run command below and not exposed to all interfaces). 
* `/config:ro` is mounted read-only for additional security

```
docker run \
    --name synapse \
    --init \
    --rm \
    --read-only
    -v /var/synapse/config:/config:ro \
    -v /var/synapse/data:/data \
    -p 8448:8448 \
    -p 127.0.0.1:8008:8008 \
    --cpus=".5" \
    --memory="1000m" \
    --pids-limit 100 \
    --security-opt="no-new-privileges:true" \
    --health-cmd="curl --fail http://localhost:8008 || exit 1" \
    --health-interval=5s \
    --health-retries=3 \
    robertbeal/synapse
```

