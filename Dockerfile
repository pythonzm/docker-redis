FROM centos:7


ENV REDIS_VERSION 3.2.9
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-3.2.9.tar.gz
ENV REDIS_DOWNLOAD_SHA 6eaacfa983b287e440d0839ead20c2231749d5d6b78bbe0e0ffa3a890c59ff26

# for redis-sentinel see: http://redis.io/topics/sentinel
RUN set -ex; \
        \
        yum install -y \
                wget \
                iproute \
                gcc \
                make \
        ; \
        wget -O redis.tar.gz "$REDIS_DOWNLOAD_URL"; \
        mkdir -p /usr/src/redis; \
        tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1; \
        rm redis.tar.gz; \
        \
# disable Redis protected mode [1] as it is unnecessary in context of Docker
# (ports are not automatically exposed when running inside Docker, but rather explicitly by specifying -p / -P)
# [1]: https://github.com/antirez/redis/commit/edd4d555df57dc84265fdfb4ef59a4678832f6da
        grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 1$' /usr/src/redis/src/server.h; \
        sed -ri 's!^(#define CONFIG_DEFAULT_PROTECTED_MODE) 1$!\1 0!' /usr/src/redis/src/server.h; \
        grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 0$' /usr/src/redis/src/server.h; \
# for future reference, we modify this directly in the source instead of just supplying a default configuration flag because apparently "if you specify any argument to redis-server, [it assumes] you are going to specify everything"
# see also https://github.com/docker-library/redis/issues/4#issuecomment-50780840
# (more exactly, this makes sure the default behavior of "save on SIGTERM" stays functional by default)
        \
        make -C /usr/src/redis -j "$(nproc)"; \
        make -C /usr/src/redis install; \
        rm -r /usr/src/redis


RUN mkdir /data
VOLUME /data
WORKDIR /data

ENTRYPOINT ["redis-server"]

EXPOSE 6379

CMD ["/data/redis.conf"]
