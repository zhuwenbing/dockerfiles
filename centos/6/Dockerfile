FROM centos:6.10

MAINTAINER KissIce Chu <i@kissice.cc>

ADD root.tgz /
COPY CentOS-Base.repo epel.repo /etc/yum.repos.d/

RUN set -ex; \
    yum clean all; \
    yum makecache fast; \
    yum update -y; \
    yum install -y --setopt=protected_multilib=false \
        ld-linux.so.2 \
        libstdc++.so.5 \
        libz.so.1 \
        libgcc_s.so.1 \
        libxml2.so.2 \
        libpcre.so.0 \
        glibc.i686 \
        psmisc \
        xulrunner.i686 \
        xorg-x11-fonts-ISO8859-2-75dpi.noarch \
        wqy-zenhei-fonts.noarch \
    ; \
    cd /tmp/; \
    curl -SL https://raw.githubusercontent.com/zhuwenbing/jdk-installers/master/6/jdk-6u45-linux-amd64.rpm -o jdk-6u45-linux-amd64.rpm; \
    yum localinstall -y jdk-6u45-linux-amd64.rpm; \
    yum clean all; \
    rm -rf /tmp/*;

ENV LANG=en_US.UTF-8 \
    JAVA_HOME=/usr/java/default \
    JRE_HOME=$JAVA_HOME/jre \
    CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH \
    PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH

VOLUME /root
WORKDIR /root
