FROM fedora:41

ARG TERM=xterm
ARG USER_GID=1000
ARG USER_UID=1000

ENV LANG=C.UTF-8
ENV TERM=${TERM}

COPY fedora/build.sh fedora/make-rpm.sh /tmp/
RUN /tmp/build.sh ${USER_UID} ${USER_GID}

USER docker
VOLUME /host
WORKDIR /host
