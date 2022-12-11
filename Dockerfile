FROM ubuntu:18.04

ARG UID_ARG=1000
ARG GID_ARG=1000
ARG TZ="America/Fortaleza"

ENV DEBIAN_FRONTEND=noninteractive
ENV USER_UID=$UID_ARG
ENV USER_GID=$GID_ARG
ENV USERNAME=user

#
# Mininum packages for installing
#
RUN ln -sf /bin/true /usr/bin/chfn && apt-get update && \
    apt-get install -y --no-install-recommends \
# It is strange but warsaw dependends on systemd-sysv with pam and nss
    systemd-sysv \
    libpam-systemd \
    libnss-systemd \
# libcurl and certificates are also for warsaw.
    libcurl3-nss \
    ca-certificates \
# This dependency is also for warsaw. This is the strangest thing
    libgtk2.0-0 \
    chromium-browser \
    lxterminal

#
# Below the dependencies on warsaw deb package.
#
RUN apt-get install -y --no-install-recommends \
    libdbus-1-3 \
    procps \
    zenity \
    python3 \
    x11-apps

#
# Debug
#
#RUN apt-get install -y --no-install-recommends \
#    xauth \
#    vim

# We are going to install warsaw from CEF. It works for BB.
# sha256sum of the latest test deb package: sha256sum warsaw_setup64.deb
# 54601df0711ede3a0c8b72f8b408b20309fa41874af0aa465499358ba8c04cc5
ADD https://cloud.gastecnologia.com.br/cef/warsaw/install/GBPCEFwr64.deb /src/warsaw.deb
#ADD https://cloud.gastecnologia.com.br/bb/downloads/ws/warsaw_setup64.deb /src/warsaw.deb

RUN groupadd -g ${USER_GID} ${USERNAME} && \
    useradd -u ${USER_UID} -g ${USER_GID} -ms /bin/bash user && \
    mkdir -p /home/${USERNAME}/Downloads && \
    mkdir -p /home/${USERNAME}/.config/chromium/Default && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

#Instalar selenium IDE
COPY context/install_chrome_selenium_extension.sh /bin/install_chrome_selenium_extension.sh
RUN chmod +x /bin/install_chrome_selenium_extension.sh
RUN /bin/install_chrome_selenium_extension.sh
RUN rm /bin/install_chrome_selenium_extension.sh

COPY context/chromium.service /etc/systemd/system/
COPY context/startbrowser.sh /usr/local/bin/

RUN mkdir -p /var/run/dbus && \
	systemctl enable chromium && \
	systemctl disable systemd-resolved && \
    systemctl disable systemd-tmpfiles-setup.service

STOPSIGNAL SIGRTMIN+3

ENTRYPOINT [ "/sbin/init" ]
