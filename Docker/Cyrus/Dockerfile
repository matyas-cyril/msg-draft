FROM debian:12.12-slim

LABEL autor="matyas-cyril"

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y man-db htop db-util locate gettext-base systemctl

RUN apt-get install -y --no-install-recommends iproute2 netcat-traditional telnet rlwrap \
     inetutils-ping dnsutils swaks tree rlwrap vim vim-common sasl2-bin rsyslog rsyslog-doc

# Installation de Postfix
RUN echo "postfix postfix/main_mailer_type string 'No configuration'" | debconf-set-selections && \
    apt-get install -y --no-install-recommends postfix postfix-cdb postfix-doc postfix-pcre postfix-lmdb \
     postfix-mysql postfix-pgsql postfix-ldap sasl2-bin postfix-sqlite

# Installation de Cyrus
RUN echo "cyrus-common cyrus-common/removespools boolean true" | debconf-set-selections && \
    apt-get install -y --no-install-recommends cyrus-admin cyrus-clients cyrus-doc \
     cyrus-murder cyrus-pop3d cyrus-imapd cyrus-common cyrus-caldav

RUN apt-get autoremove -y

RUN echo "\nif [[ -f /usr/bin/rlwrap && -f /usr/bin/cyradm ]]; then\n\
    alias cyradm='/usr/bin/rlwrap /usr/bin/cyradm'\nfi" >> /etc/bash.bashrc && \
    ln -s /usr/lib/cyrus/bin/imapd /usr/lib/cyrus/bin/proxyd && \
    ln -s /usr/lib/cyrus/bin/lmtpd /usr/lib/cyrus/bin/lmtpproxyd && \
    ln -s /usr/lib/cyrus/bin/pop3d /usr/lib/cyrus/bin/pop3proxyd

RUN /usr/sbin/usermod -aG mail postfix
RUN /usr/bin/gpasswd -a postfix sasl

RUN touch /var/lib/cyrus/tls_sessions.db && chown cyrus:mail /var/lib/cyrus/tls_sessions.db && \
    echo "lmtp               24/tcp                       # Local Mail Transfer Protocol" >> /etc/services && \
    echo "mupdate          3905/tcp                       # Murder Cyrus" >> /etc/services

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*

COPY --chown=root:root rsyslog.conf /etc/rsyslog.conf

RUN echo 'while [ 1 ]; do sleep 1 ;done;' > /loop_inf.sh && chmod +x /loop_inf.sh

CMD systemctl restart rsyslog.service && \
    /loop_inf.sh
