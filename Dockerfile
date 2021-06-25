FROM gcr.io/webera/base

COPY docker-entrypoint.sh /usr/local/bin/

RUN set -x && \
    apt-get update && apt-get install -qq -y nfs-kernel-server \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /exports \
    && chown 33:33 /exports \
    && chmod +rx /usr/local/bin/docker-entrypoint.sh 

VOLUME /exports

EXPOSE 2049/tcp
EXPOSE 20048/tcp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/exports"]
