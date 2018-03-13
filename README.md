# Ubuntu VPS setup (17.0)

Here are some base guidelines I follow when setting up a new VPS manually without configuration management. These steps if anything make the system more secure overall and provide a good starting point from which you can setup the services/software’s required for the purpose of the VPS.

Once you do that the rest of the process is split into three sections:

1. Create a non-root user
2. Secure server (UFW, Fail2ban)
3. Install docker
4. Intall docker-compose

## Setup VPS user account
```bash
ssh root@your.vps.ip.address

# add sudo package if not included
apt-get install sudo

adduser deployer
adduser deployer sudo
adduser deployer adm
exit
```

## Copy client public SSH key
```bash
ssh-copy-id deployer@your.vps.ip.address
```
Notes: The public key (after authentication) will be added to the remote user’s ~/.ssh/authorized_keys file. As long as the client has the private key tied to the public key just registered, it can be used to log into the VPS.

## Update and install system pacakges
```bash
ssh deployer@your.vps.ip.address
sudo apt-get update && sudo apt-get upgrade -y
```

## Default SSH port and root access
This step removes the assumption any port scanning makes on what port number the SSH service is running on. The default is `22` so these processes will check for that first and foremost. Changing this number to an ephemeral port can help to reduce the number of attempted malicious login attempts that are made.

```bash
sudo vim /etc/ssh/sshd_config
```
Change the Port `22` entry to any number between `1025` and `65536` respectively. Change the `PermitRootLogin yes` entry to `PermitRootLogin without-password` instead, This as mentioned before means only users with public SSH keys registered in the root authorised keys file can log in as root itself.

For example:
```bash
Port 3267
...
PermitRootLogin without-password
```

Restart SSH so the changes take effect
```bash
sudo service ssh restart
```
For the curious, you can list all current SSH connections to your server with the command netstat. You'll sometimes be surprised with what's trying to access your server.
```bash
netstat -algrep ssh
```

Notes: When accessing the VPS via SSH in the future, you must now append the correct port number to the command e.g.
```bash
ssh deployer@your.vps.ip.address -p 3267
```

## Setup Dotfile (TODO)

## Install software package
```bash
sudo apt-get install git build-essential curl htop tmux -y
```

### Install and run UFW
UFW stands for “Uncomplicated Firewall” and is more concise easier to understand alternative to older firewall implementations like iptables.

```bash
sudo apt-get install ufw
```
Make the default overall action for any incoming traffic to be blocked and denied.
```bash
sudo ufw default deny incoming
```
Then make the default overall action for outgoing traffic to be permissible and allowed.
```bash
sudo ufw default allow outgoing
```

To continue here, open the SSH port number you chose earlier on by replacing the number 3267 with your own number, in the following command.
```bash
sudo ufw allow 3267/tcp
sudo ufw enable
```