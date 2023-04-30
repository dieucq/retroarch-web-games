# Run RetroArch Web Player in a container
#
# docker run --rm -it -d -p 8080:80 retroarch-web-nightly
#
FROM debian:bullseye

LABEL maintainer "Antoine Boucher <antoine.bou13@gmail.com>"

# Install required packages
RUN apt-get update && apt-get install -y \
    ca-certificates \
    unzip \
    sed \
    p7zip-full \
    coffeescript \
    xz-utils \
    nginx \
    wget \
    vim \
    parallel \
    git \
    python3 \
    python3-pip \
    lbzip2 \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV ROOT_WWW_PATH /var/www/html


RUN cd ${ROOT_WWW_PATH} \
	&& wget https://buildbot.libretro.com/nightly/emscripten/$(date -d "yesterday" '+%Y-%m-%d')_RetroArch.7z \
	&& 7z x -y $(date -d "yesterday" '+%Y-%m-%d')_RetroArch.7z \
	&& mv retroarch/* . \
	&& rmdir retroarch \
	&& sed -i '/<script src="analytics.js"><\/script>/d' ./index.html \
	&& chmod +x indexer \
	&& mkdir -p ${ROOT_WWW_PATH}/assets/cores \
	&& cd ${ROOT_WWW_PATH}/assets/frontend/bundle \
	&& ../../../indexer > .index-xhr \
	&& cd ${ROOT_WWW_PATH}/assets/cores \
	&& ../../indexer > .index-xhr \
	&& rm -rf ${ROOT_WWW_PATH}/RetroArch.7z \
	&& rm -rf ${ROOT_WWW_PATH}/assets/frontend/bundle.zip



# Set up the environment for the RetroArch Web Player
ENV ROOT_WWW_PATH /var/www/html
COPY InternetArchive.py /tmp/InternetArchive.py
RUN pip3 install requests
RUN chmod +x /tmp/InternetArchive.py && \
    python3 /tmp/InternetArchive.py

COPY index.html ${ROOT_WWW_PATH}/index.html

# https://github.com/libretro/RetroArch/tree/master/pkg/emscripten
# https://buildbot.libretro.com/nightly/

COPY index.html ${ROOT_WWW_PATH}/index.html
RUN ../../indexer > .index-xhr
WORKDIR ${ROOT_WWW_PATH}
EXPOSE 80
COPY entrypoint.sh /
CMD [ "sh", "/entrypoint.sh"]
