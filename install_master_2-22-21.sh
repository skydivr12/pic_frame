#!/bin/bash
SCRIPT="${0##*/}" #basename of this script
DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )" #directory path of this script
NOW=$(date +"%D_%T")
BIN_DIR="$HOME/pic_frame/bin"
BAK_DIR="$HOME/pic_frame/backups"
SYS_DIR="$HOME/pic_frame/systemd"
SRC_DIR="$HOME/pic_frame/src"
sysdir="/etc/systemd/system"
LOG_DIR="$HOME/pic_frame/logs"
LOG1="$LOG_DIR/download_log.txt"
LOG2="$LOG_DIR/update_log.txt"
MODEL=$(cat /proc/device-tree/model | awk -F"Pi " 'NR==1{split($2,a," ");print a[1]}')
IP_FILE="/etc/dhcpcd.conf"
IP_FILE_BACKUP="$HOME/pic_frame/backups/dhcpcd.conf.backup"
IP_FILE_EDIT="$HOME/dhcpcd.conf"
SMB_CONF=/etc/samba/smb.conf
SMB_CONF_BACKUP=$BAK_DIR/smb.conf.backup
SMB_EDIT=$HOME/smb.conf
FRAME_CONFIG="$HOME/pi3d_demos/PictureFrame2020config.py"
FRAME_CONFIG_BACKUP="$BAK_DIR/PictureFrame2020config.py.backup"
FRAME_PY="$HOME/pi3d_demos/PictureFrame2020.py"
FRAME_PY_BACKUP="$BAK_DIR/PictureFrame2020.py.backup"
AUTOSTART_FILE="/etc/xdg/lxsession/LXDE-pi/autostart"
AUTOSTART_FILE_BACKUP="$BAK_DIR/autostart.backup"
PICTUREFRAME_AUTOSTART="$BAK_DIR/autostart.pictureframe"

# Creating a continuation prompt as a function.
continue_prompt() {
read -p ' If you understand and are ready to continue, hit enter. ' nothing &&
unset nothing
clear
}

sudo chmod +x $HOME/pic_frame/bin/*
sudo chmod +x $HOME/pic_frame/src/*
sudo chmod +644 $HOME/pic_frame/systemd/*
sudo ln -sf $HOME/pic_frame/bin/* /usr/local/bin/
sudo cp $HOME/pic_frame/systemd/* /etc/systemd/system/
mkdir -p $LOG_DIR

# Introduction text.
echo ' Welcome. I am about to install all the software necessary to' &&
echo ' run your new digital picture frame. There are a few things that' &&
echo ' you will need to do. I will guide you through the entire setup' &&
echo ' process. It is very important to follow all instructions implicitly.' &&
continue_prompt



# Instructions to enable the proper GL driver.
echo ' A window will open, use arrow keys to select option 6 Advanced options' &&
echo ' and press enter. Then select A2 GL Driver and hit enter.' &&
if [ "$MODEL" -le 3 ]; then
  echo ' Select G1 Legacy driver and hit enter. Hit enter again to confirm.'
else
  echo ' Select G2 GL (Fake KMS) and hit enter. Hit enter again to confirm.'
fi
echo ' Finally use the tab key to select finish and press enter.' &&
continue_prompt

# Opens raspi-config utility.
sudo raspi-config && clear &&


# Updates system packages.
echo ' I will first check for updates and install them.' &&
echo ' This should only take a moment.' && sleep 2 && clear &&
sudo apt update && sudo apt upgrade -y && clear &&


# Instructions for user interaction needed for samba installation.
echo ' In a moment a window will open. make sure "No" is selected' &&
echo ' and hit enter. The rest of the installation will not require' &&
echo ' your input. When the systems reboots, open a terminal and' &&
echo ' type setup_master to finish configuring the system.' &&
continue_prompt


# Installs samba.
sudo apt install samba samba-common-bin smbclient cifs-utils -y &&


# Edits samba config file with necessary changes to make visible on windows networks.
if [ -f "$SMB_CONF_BACKUP" ]; then
  echo " Samba has already been setup correctly. Skipping."
else
  sed -n '1,169p;170q' $SMB_CONF > $SMB_EDIT &&
  echo '[pi]' >> $SMB_EDIT &&
  echo 'comment = Pi' >> $SMB_EDIT &&
  echo "path = $HOME" >> $SMB_EDIT &&
  echo 'browseable = yes' >> $SMB_EDIT &&
  echo 'read only = no' >> $SMB_EDIT &&
  echo 'guest ok = no' >> $SMB_EDIT &&
  echo 'create mask = 0700' >> $SMB_EDIT &&
  echo 'directory mask = 0700' >> $SMB_EDIT &&
  sed -n '194,237p;238q' $SMB_CONF >> $SMB_EDIT &&
  sudo mv $SMB_CONF $SMB_CONF_BACKUP &&
  sudo mv $SMB_EDIT $SMB_CONF &&
  sudo chown root:root $SMB_CONF &&
  sudo /etc/init.d/smbd restart
fi
clear && echo " Samba installed successfully. Continuing" && sleep 2 &&


# Installs Web Service Discovery Daemon. Software that will allow the
# pictureframe to be visible on windows network computers. Installs
# software to make linux machine visible to windows network.
if [ -f "$sysdir/wsdd.service" ]; then
  echo " WSDD has already been installed. Skipping"
else
  cd /tmp && sudo wget https://github.com/christgau/wsdd/archive/master.zip &&
  unzip master.zip &&
  sudo mv wsdd-master/src/wsdd.py wsdd-master/src/wsdd &&
  sudo cp wsdd-master/src/wsdd /usr/bin &&
  sudo cp wsdd-master/etc/systemd/wsdd.service $sysdir &&
  sudo sed -i "s/User=nobody/;User=nobody/" $sysdir/wsdd.service &&
  sudo sed -i "s/Group=nobody/;Group=nobody/" $sysdir/wsdd.service &&
  sudo rm master.zip && cd &&
  sudo systemctl daemon-reload &&
  sudo systemctl start wsdd &&
  sudo systemctl enable wsdd
fi

# Installs slideshow software.
if [ -d "$HOME/pi3d_demos" ]; then
  echo " Pi3D has already been installed and setup. Skipping."
else
  sudo pip3 install pi3d &&
  wget https://github.com/pi3d/pi3d_demos/archive/master.zip && unzip master.zip && rm master.zip &&
  mv pi3d_demos-master pi3d_demos &&
  sudo cp $FRAME_CONFIG $FRAME_CONFIG_BACKUP &&
  sudo cp $FRAME_PY $FRAME_PY_BACKUP &&
  sed -i "155s/'.png'/'.tiff','.dng','.png'/" $FRAME_PY
fi

# Installs other necessary software.
sudo apt install -y mosquitto mosquitto-clients -y &&
sudo pip3 install paho-mqtt &&
sudo apt install php php-common gcc -y &&
sudo apt install imagemagick -y &&
sudo apt install rename &&
# Installs software that allows us to sync from cloud services.
sudo apt install rclone -y &&

if [ "$MODEL" -le 3 ]; then
  sudo raspi-config nonint do_memory_split 256
else
  sudo raspi-config nonint do_memory_split 128
fi

sudo raspi-config nonint do_ssh 0 &&
sudo mkdir -p /root/.config/rclone &&
sudo mkdir -p $HOME/.frame_updates &&
touch $LOG1 &&
touch $LOG2 &&
sudo chmod +766 $LOG1 &&
sudo chmod +766 $LOG2 &&


if [ -f "$IP_FILE_BACKUP" ]; then
  echo " dhcpcd.conf.backup already exists. Skipping."
else
  sudo cp $IP_FILE $IP_FILE_BACKUP &&
  echo " Backing up dhcpd.conf"
fi

# Creates file to disable screen blanking.
if [ -f "$PICTUREFRAME_AUTOSTART" ]; then
  echo " $PICTUREFRAME_AUTOSTART already exists. Skipping"
else
  sudo cp $AUTOSTART_FILE $AUTOSTART_FILE_BACKUP &&
  sudo chown pi:pi $AUTOSTART_FILE &&
  sudo sed -i 's/@xscreensaver -no-splash/@xset s off/' $AUTOSTART_FILE &&
  echo '@xset -dpms' >> $AUTOSTART_FILE &&
  echo '@xset s noblank' >> $AUTOSTART_FILE &&
  sudo chown root:root $AUTOSTART_FILE &&
  sudo cp $AUTOSTART_FILE $PICTUREFRAME_AUTOSTART &&
  sudo cp $AUTOSTART_FILE_BACKUP $AUTOSTART_FILE
fi
clear && echo " All necessary software has now been installed successfully." &&
sleep 10 &&
#sed -i '32,160s/^./#&/' $0 &&
echo "Done"
