FROM webera/base

COPY entrypoint.sh /usr/local/bin/

RUN set -x \
 && apt-get update \
 && apt-get install -y --no-install-recommends nfs-kernel-server \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /exports \
 && chown 33:33 /exports \
 && chmod 755 /usr/local/bin/entrypoint.sh 

VOLUME /exports

EXPOSE 2049/tcp
EXPOSE 20048/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "/exports"]
