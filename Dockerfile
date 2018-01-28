#
# Dockerfile for build-phantomsjs-armhf
#
# docker build -t uwegerdes/build-phantomsjs-armhf .

FROM uwegerdes/baseimage

MAINTAINER Uwe Gerdes <entwicklung@uwegerdes.de>

ARG UID=1000
ARG GID=1000
ARG PHANTOM_JS_VERSION=2.1.1

ENV USER_NAME phantomjs
ENV HOME /home/${USER_NAME}
ENV PHANTOM_JS_VERSION ${PHANTOM_JS_VERSION}

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
	mkdir -p ${HOME} && \
	groupadd --gid ${GID} ${USER_NAME} && \
	useradd --uid ${UID} --gid ${GID} --home-dir ${HOME} --shell /bin/bash ${USER_NAME} && \
	adduser ${USER_NAME} sudo && \
	echo "${USER_NAME}:${USER_NAME}" | chpasswd && \
	chown -R ${USER_NAME}:${USER_NAME} ${HOME}

WORKDIR ${HOME}

USER ${USER_NAME}

VOLUME [ "${HOME}" ]

CMD [ "${HOME}/build.sh" ]
