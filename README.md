# Webera nfs Image

Repository used to maintain container image with nfs server. The image
Entrypoint manage SIGTERM signal correctly to graceful stop the container.
To use this image:

    docker run --rm -d -p 2049:2049 -p 20048:20048 webera/nfs

[See on Docker HUB.](https://hub.docker.com/r/webera/nfs)
