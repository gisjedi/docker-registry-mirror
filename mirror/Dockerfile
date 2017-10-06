FROM registry

COPY inject-mirror.sh /inject-mirror.sh

ENV REGISTRY_URL https://registry-1.docker.io

ENTRYPOINT ["/inject-mirror.sh"]

CMD ["/etc/docker/registry/config.yml"]
