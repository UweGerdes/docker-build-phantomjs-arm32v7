#
# Dockerfile for building phantomsjs on Raspberry Pi 3
#

FROM uwegerdes/baseimage

MAINTAINER Uwe Gerdes <entwicklung@uwegerdes.de>

ARG UID=1000
ARG GID=1000

ENV USER_NAME phantomjs
ENV USER_DIR /home/${USER_NAME}
ENV SOURCE /home/src
ENV PHANTOM_JS_VERSION 2.1.1

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	apt-get install -y \
		autoconf \
		automake \
		bison \
		build-essential \
		flex \
		gcc \
		gperf \
		libfontconfig1-dev \
		libfreetype6 \
		libicu-dev \
		libjpeg-dev \
		libpng-dev \
		libsqlite3-dev \
		libssl-dev \
		libx11-dev \
		libxext-dev \
		make \
		python \
		ruby && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	mkdir -p ${USER_DIR} && \
	groupadd --gid ${GID} ${USER_NAME} && \
	useradd --uid ${UID} --gid ${GID} --home-dir ${USER_DIR} --shell /bin/bash ${USER_NAME} && \
	adduser ${USER_NAME} sudo && \
	echo "${USER_NAME}:${USER_NAME}" | chpasswd && \
	chown -R ${USER_NAME}:${USER_NAME} /home

WORKDIR "${USER_DIR}"

USER ${USER_NAME}

RUN mkdir -p ${SOURCE} && \
	cd ${SOURCE} && \
	git clone git://github.com/ariya/phantomjs.git && \
	cd ./phantomjs/ && \
	git checkout ${PHANTOM_JS_VERSION} && \
	git submodule init && \
	echo "Please wait some minutes for each submodule update" && \
	git submodule update

VOLUME [ "${USER_DIR}" ]

CMD [ "build.sh" ]

