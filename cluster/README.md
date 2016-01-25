# Mesos in one command

This is docker compose config basically stolen from [bobrik/mesos-compose]
(https://github.com/bobrik/mesos-compose).

It builds images from source download from git and host networking to enable
interactions with tasks over real network. It also enables docker containerizer.

No state is persisted between runs so feel free to start over if you
screwed cluster state or something.

## Versions

* Mesos 0.26.0
* Marathon 0.14.0
* Chronos 2.4.0 (optional)

## known issue
mesos 从0.26.0开始对linux launcher使用systemd，而在docker容器上不支持systemd, 所以工作会不正常。

目前，我们是通过"--launcher=posix"绕过这个问题。

## Usage

Run your cluster:

```
docker-compose up -d
```

That's it, use the following URLs:

* http://$DOCKER_IP:5050/ for Mesos master UI
* http://$DOCKER_IP:8080/ for Marathon UI
* http://$DOCKER_IP:8888/ for Chronos UI

To kill your cluster and wipe all state to start fresh:

```
docker-compose stop
docker-compose rm -f -v
```

## Mesos slave IP address

Mesos tasks have `HOST` env variable passed by mesos. The value by default
is the output of `hostname -s` command. In many environments local hostname
resolves to 127.0.0.1. This leads to mesos tasks listening on `127.0.0.1`.

To fix this issue, open `docker-compose.yml`, find `SLAVE_IP_GOES_HERE` and
replace it with the IP address you want your tasks to listen on.

## Optional services

In `docker-compose.yml` you can uncomment additional containers.

### Second mesos-slave

Uncomment `slave-two` section to get access to the second mesos-slave. Port
ranges of two mesos-slaves are separated so it shouldn't be an issue.

Note that both slaves share same memory so you might see OOM if you allocate
and use more memory than your docker host has.

### Chronos

Uncomment `chronos` section to get access to Chronos framework.
