FROM alpine:3.11

MAINTAINER KissIce Chu <i@kissice.cc>

RUN set -eux; \
    apk update; \
    apk add --no-cache \
        bash \
        bind-tools \
        ca-certificates \
        curl \
        tzdata \
        wget \
    ; \
    rm -rf /var/cache/apk/*; \
    rm -rf /tmp/*; \
    sed -i 's/ash/bash/g' /etc/passwd; \
    touch /root/.bashrc; \
    echo -e "export HISTTIMEFORMAT='%d/%m/%y %T '\nexport PS1='\u@\h:\W \\$ '\nalias ll='ls -alF'\nalias ls='ls --color=auto'" >/root/.bashrc