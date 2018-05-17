log "[INFO] Add user sa."
useradd sa -d /home/sa -m -s /bin/bash

log "[INFO] Setting password fro new user sa."
passwd sa

log "[INFO] Grant sudoers to new user sa."
echo 'sa    ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
