#!/bin/bash -xe

/usr/bin/dpkg -D10 -i /src/warsaw.deb
systemctl enable --now warsaw

cp /root/.Xauthority /home/user/.Xauthority
chown user:user /home/user/.Xauthority

# Como o systemd limpa todas as
# variaveis de ambiente para seus servicos,
# estas linhas sao necessarias para
# recuperar as variaveis passadas
# no docker run.
echo "#!/bin/bash" >> /env.sh
cat /proc/1/environ | tr '\0' '\n' >> /env.sh
chmod +x /env.sh
source /env.sh

if [[ "$DEBUG" == "1" ]]; then
	runuser -l user -c "XAUTHORITY=/home/user/.Xauthority DISPLAY=$DISPLAY /usr/bin/chromium-browser --disable-dev-shm-usage --start-maximized"
fi

kill -SIGRTMIN+3 1

