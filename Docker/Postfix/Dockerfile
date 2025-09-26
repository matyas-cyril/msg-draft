FROM debian:12.12-slim

LABEL autor="matyas-cyril"

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y man-db htop db-util locate gettext-base systemctl

RUN apt-get install -y --no-install-recommends iproute2 netcat-traditional telnet rlwrap \
     inetutils-ping dnsutils swaks rlwrap vim vim-common sasl2-bin rsyslog rsyslog-doc

# Installation de Postfix
RUN echo "postfix postfix/main_mailer_type string 'No configuration'" | debconf-set-selections && \
    apt-get install -y --no-install-recommends postfix postfix-cdb postfix-doc postfix-pcre postfix-lmdb \
     postfix-mysql postfix-pgsql postfix-ldap postfix-sqlite

RUN apt-get autoremove -y

RUN /usr/sbin/usermod -aG mail postfix
RUN /usr/bin/gpasswd -a postfix sasl

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*

COPY --chown=root:root rsyslog.conf /etc/rsyslog.conf

RUN echo 'while [ 1 ]; do sleep 1 ;done;' > /loop_inf.sh && chmod +x /loop_inf.sh

CMD systemctl restart rsyslog.service && \
    /loop_inf.sh
