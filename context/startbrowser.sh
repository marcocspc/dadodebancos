#!/bin/bash -xe

/usr/bin/dpkg -D10 -i /src/warsaw.deb
systemctl enable --now warsaw

cp /root/.Xauthority /home/user/.Xauthority
chown user:user /home/user/.Xauthority

if [[ -z "${DEBUG}" ]]; then
	runuser -l user -c "XAUTHORITY=/home/user/.Xauthority DISPLAY=:0 /usr/bin/chromium-browser --disable-dev-shm-usage --start-maximized"
fi
