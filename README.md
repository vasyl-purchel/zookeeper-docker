# Zookeeper

[![Join the chat][1]][2]

This is an image for [apache zookeeper][3] based on [ubuntu:trusty docker image][4]

## Supported tags and respective Dockerfile links:

 * 3.4.7, latest ([Dockerfile][5])

## Usage

The container has default environment variables that shouldn't be touched:

| Environment Variable | Description | Value |
| -------------------- | ----------- | ----- |
| ```ZOOKEEPER_HOME``` | home directory where zookeeper is installed | ```/opt/zookeeper/``` |
| ```ZOOKEEPER_CONFIG_FILE``` | configuration file for zookeeper | ```/opt/zookeeper/conf/zoo.cfg``` |

To run container in **standalone** mode just don't set ```ZK_ID``` environment variable:

```bash
docker run -d -ti --publish 2181:2181 --name zookeeper vasylpurchel/zookeeper
```

Or it can be used in replicated mode:

```bash
docker run -d -ti -e ZK_CLIENT_PORT="2181" -e ZK_SERVERS="172.17.42.1:2888:3888 172.17.42.1:2889:3889 172.17.42.1:2890:3890" -e ZK_ID=1 --publish 2181:2181 --publish 2888:2888 --publish 3888:3888 --name zookeeper-node-1 vasylpurchel/zookeeper
...
```

To configure zookeeper instance you can use environment variables that starts with a same name as zookeeper configuration entries with ```ZK_``` prefix, uppercase and words splitted by ```_```

Few examples:

| Environment Variable | Zookeeper Property |
| -------------------- | ------------------ |
| ```ZK_DATA_DIR``` | ```dataDir``` |
| ```ZK_TICK_TIME``` | ```tickTime``` |
| ```ZK_INIT_LIMIT``` | ```initLimit``` |

By default only ```ZK_DATA_DIR``` is set to ```/tmp/zookeeper``` and in zoo.cfg file default values are:

| Zookeeper Property | Default value |
| ------------------ | ------------- |
| ```tickTime``` | ```2000``` |
| ```clientPort``` | ```2181``` |
| ```dataDir``` | ```/tmp/zookeeper``` |

To save data you need to mount volume to ```ZK_DATA_DIR```:

```bash
docker run -d -ti -v /data/zookeeper:/tmp/zookeeper --publish 2181:2181 --name zookeeper vasylpurchel/zookeeper
```

docker-entry-point.sh is generating configuration for container and runs any parameters after,
so you can use this image to run other zookeeper related tasks and not only starting server in foreground(default one)

## Notes

Make sure you are in zookeeper folder and that ip address in **docker-compose.yml** file is correct (mine is 127.17.0.1 while default is 127.17.42.1):

```bash
ifconfig | grep "docker0" -C 2 | grep "inet addr"
```

build image:

```bash
docker build -t vasylpurchel/zookeeper .
```

run 3 nodes from docker-compose:

```bash
docker-compose up
```

check that it works just run:

```bash
for i in {2181..2183}; do echo mntr | nc 172.17.42.1 $i | grep zk_followers ; done
```

## TODO

 * Add badges for image size, layers, docker starts and pulls, circleCI and maybe something else

 * `--net=host` is used to tell docker containers to use host network, so this instances will be able to comunicate between themselves, need to be changed to overlay network so we can have multi-host network that will be using it

[1]: https://badges.gitter.im/Join%20Chat.svg
[2]: https://gitter.im/vasyl-purchel/zookeeper
[3]: https://zookeeper.apache.org/
[4]: https://hub.docker.com/_/ubuntu/
[5]: dockerfile
