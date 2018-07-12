#!/bin/bash
clear

STRING1="Make sure you double check before hitting enter! Only one shot at these!"
STRING2="If you found this helpful, please donate to NORT Donation: "
STRING3="nKHHz5J1xQ1RdKbYau5heo2v2ziqxn1chy"
STRING4="Updating system and installing required packages."
STRING5="Switching to Aptitude"
STRING6="Some optional installs"
STRING7="Starting your masternode"
STRING8="Now, you need to finally start your masternode in the following order:"
STRING9="Go to your windows wallet and from the Control wallet debug console please enter"
STRING10="startmasternode alias false <mymnalias>"
STRING11="where <mymnalias> is the name of your masternode alias (without brackets)"
STRING12="once completed please return to VPS and press the space bar"
STRING13=""
STRING14="Please Wait a minimum of 5 minutes before proceeding, the node wallet must be synced"

echo $STRING1

read -e -p "Server IP Address : " ip
read -e -p "Masternode Private Key (e.g. 7edfjLCUzGczZi3JQw8GHp434R9kNY33eFyMGeKRymkB56G4324h # THE KEY YOU GENERATED EARLIER) : " key
read -e -p "Install Fail2ban? [Y/n] : " install_fail2ban
read -e -p "Install UFW and configure ports? [Y/n] : " UFW

clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10

# update package and upgrade Ubuntu
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y autoremove
sudo apt-get install wget nano htop -y
sudo apt-get install build-essential && sudo apt-get install libtool autotools-dev autoconf automake \
  && sudo apt-get install libssl-dev && sudo apt-get install libboost-all-dev \
  && sudo apt install software-properties-common && sudo add-apt-repository ppa:bitcoin/bitcoin \
  && sudo apt update && sudo apt-get install libdb4.8-dev && sudo apt-get install libdb4.8++-dev \
  && sudo apt-get install libminiupnpc-dev && sudo apt-get install libqt4-dev libprotobuf-dev protobuf-compiler \
  && sudo apt-get install libqrencode-dev && sudo apt-get install -y git && sudo apt-get install pkg-config
sudo apt-get -y install libzmq3-dev
clear
echo $STRING5
sudo apt-get -y install aptitude

#Generating Random Passwords
password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
password2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo $STRING6
if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
  cd ~
  sudo aptitude -y install fail2ban
  sudo service fail2ban restart
fi
if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
  sudo apt-get install ufw
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh
  sudo ufw allow 60151/tcp
  sudo ufw enable -y
fi

#Install Northern Daemon
wget https://github.com/Northerncryptodev/Northern/releases/download/v2.0.1/northern-2.0.1.x86_64-linux-gnu-daemon-nogui.tar.gz
sudo tar -xzvf northern-2.0.1.x86_64-linux-gnu-daemon-nogui.tar.gz
sudo rm northern-2.0.1.x86_64-linux-gnu-daemon-nogui.tar.gz
sudo cp ~/northern-2.0.1/northernd /usr/bin
sudo cp ~/northern-2.0.1/northern-cli /usr/bin
northernd -daemon
clear

#Setting up coin
clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10

#Create northern.conf
echo '
rpcuser='$password'
rpcpassword='$password2'
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=256
externalip='$ip'
bind='$ip':60151
masternodeaddr='$ip'
masternodeprivkey='$key'
masternode=1
' | sudo -E tee ~/.northern/northern.conf >/dev/null 2>&1
sudo chmod 0600 ~/.northern/northern.conf

#Starting coin
(
  crontab -l 2>/dev/null
  echo '@reboot sleep 30 && northernd -daemon -shrinkdebugfile'
) | crontab
(
  crontab -l 2>/dev/null
  echo '@reboot sleep 60 && northern-cli startmasternode local false'
) | crontab
northernd -daemon

clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10
echo $STRING7
echo $STRING13
echo $STRING8
echo $STRING13
echo $STRING9
echo $STRING13
echo $STRING10
echo $STRING13
echo $STRING11
echo $STRING13
echo $STRING12
echo $STRING14
sleep 5m

read -p "Press any key to continue... " -n1 -s
northern-cli startmasternode local false
northern-cli masternode status