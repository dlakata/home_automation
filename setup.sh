# https://omcar.medium.com/raspberry-pi-ssh-freezing-solution-2b503a6af3b0
sudo echo 'IPQoS cs0 cs0' >> /etc/ssh/sshd_config

sudo apt update
sudo apt upgrade

sudo apt install python-pip python-dev python-setuptools python-virtualenv git libyaml-dev build-essential

# Boot only into console to save RAM
sudo raspi-config

# Python
# Similar to https://hometechhacker.com/upgrading-your-home-assistant-core-python-virtual-environment/
cd
python --version
wget https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tar.xz
tar -xzf Python-3.10.9
cd Python-3.10.9
sudo apt install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev
./configure --enable-optimizations--with-ensurepip=install
sudo make altinstall
cd /usr/bin
ls -l *python*
python --version
sudo rm python3
sudo ln -s /usr/local/bin/python3.10 python3
python --version

# OctoPrint
# Similar to https://esmer-games.github.io/12-12-2018-octoprint-nginx-motion/
cd
mkdir OctoPrint && cd OctoPrint
python3 -m venv .
source bin/activate
pip install pip --upgrade
pip install https://get.octoprint.org/latest
sudo usermod -a -G tty $USER
sudo usermod -a -G dialout $USER
wget https://github.com/foosel/OctoPrint/raw/master/scripts/octoprint.init
sudo mv octoprint.init /etc/init.d/octoprint
wget https://github.com/foosel/OctoPrint/raw/master/scripts/octoprint.default
sudo mv octoprint.default /etc/default/octoprint
sudo chmod +x /etc/init.d/octoprint
sudo vim /etc/default/octoprint
sudo update-rc.d octoprint defaults
sudo systemctl enable octoprint
sudo systemctl start octoprint

# Mosquitto
# Similar to https://randomnerdtutorials.com/how-to-install-mosquitto-broker-on-raspberry-pi/
cd
sudo apt install -y mosquitto mosquitto-clients
sudo systemctl enable mosquitto.service
sudo echo 'listener 1883' >> /etc/mosquitto/mosquitto.conf
sudo echo 'allow_anonymous true' >> /etc/mosquitto/mosquitto.conf
sudo systemctl restart mosquitto

# MariaDB
# Similar to https://kevinfronczak.com/blog/mysql-with-homeassistant (but replacing with mariadb where appropriate)
cd
sudo apt install mariadb-server mariadb-client libmariadb-dev libmariadb-dev-compat libmariadb-dev
sudo mysql -u root -p

mysql> CREATE DATABASE hass_db;
mysql> CREATE USER 'hassuser'@'localhost' IDENTIFIED BY '<YOURPASSWORD>';
mysql> GRANT ALL PRIVILEGES ON hass_db.* TO 'hassuser'@'localhost';
mysql> FLUSH PRIVILEGES;
mysql> quit

sudo service enable mariadb

# Home assistant
# Similar to https://www.home-assistant.io/installation/linux#install-home-assistant-core
# and https://community.home-assistant.io/t/autostart-using-systemd/199497
cd
sudo apt install -y python3 python3-dev python3-venv python3-pip bluez libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf build-essential libopenjp2-7 libtiff5 libturbojpeg0-dev tzdata
sudo useradd -rm homeassistant
sudo mkdir /srv/homeassistant
sudo chown homeassistant:homeassistant /srv/homeassistant
sudo -u homeassistant -H -s
cd /srv/homeassistant
python3 -m venv .
source bin/activate
python3 -m pip install wheel
pip3 install homeassistant

sudo cp homeassistant/home-assistant@homeassistant.service /etc/systemd/system/
sudo cp homeassistantconfiguration.yaml /home/homeassistant/.homeassistant/
sudo cp homeassistantsecrets.yaml /home/homeassistant/.homeassistant/

# Nginx
# Similar to https://community.home-assistant.io/t/reverse-proxy-using-nginx/196954/81
sudo apt install nginx
sudo rm /etc/nginx/sites-enabled/default
sudo cp homeassistant.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/homeassistant.conf /etc/nginx/sites-enabled/
sudo systemctl enable nginx
sudo systemctl start nginx