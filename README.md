# docker-redis

## start a redis instance
```
$ docker run --name some-redis -d dockerzm/redis:3.2.9
```
## connect to it from an application
```
$ docker run --name some-app --link some-redis:redis -d application-that-uses-redis
```
## ... or via redis-cli
```
$ docker run -it --link some-redis:redis --rm redis redis-cli -h redis -p 6379
```
## use your own redis.conf 
You can create your own Dockerfile that adds a redis.conf from the context into /data/, like so.
```
FROM redis
COPY redis.conf /usr/local/etc/redis/redis.conf
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
```
Alternatively, you can specify something along the same lines with `docker run` options.
```
docker run -d --name redis -v /docker/redis/redis.conf:/data/redis.conf dockerzm/redis:3.2.9
```
**NOTE:必须先将本地`redis.conf`文件中`daemonize yes`注释掉或改为no!**
> 因为`daemonize yes` 表示redis-server进程在后台运行， 执行完`redis-server redis.conf`就完了， 这时的shell是没任何东西在运行的，所以docker以为你运行完毕， 所以容器就退出了

