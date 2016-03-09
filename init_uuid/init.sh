#!/bin/sh

cd /etc/init.d
sudo cp /home/vagrant/scripts/update_uuid.sh .
sudo chmod +x update_uuid.sh
sudo chown root:root update_uuid.sh
sudo update-rc.d update_uuid.sh defaults 99
