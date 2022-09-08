FROM harbor.sun.com/google_containers/openjdk:8-alpine

ARG NAME
ARG VERSION
ARG JAR_FILE

LABEL name=$NAME \
      version=$VERSION

# 设定时区
ENV TZ=Asia/Shanghai
RUN set -eux; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone

# 新建用户app
RUN set -eux; \
    addgroup --gid 1000 app; \
    adduser -S -u 1000 -g app -h /home/app/ -s /bin/sh -D app; \
    mkdir -p /home/app/lib /home/app/etc /home/app/jmx-ssl /home/app/logs /home/app/tmp /home/app/jmx-exporter/lib /home/app/jmx-exporter/etc; \
    chown -R app:app /home/app

# 导入启动脚本
COPY --chown=app:app docker-entrypoint.sh /home/app/docker-entrypoint.sh

# 导入JAR
COPY --chown=app:app target/${JAR_FILE} /home/app/lib/dockerfile-java-examples.jar

USER app

ENTRYPOINT ["/home/app/docker-entrypoint.sh"]

EXPOSE 8080
