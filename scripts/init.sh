#!/bin/bash

# Set the username and public key
USERNAME="ElkTop"
read -r PUBKEY < ../credentials/id_rsa.pem.pub

# Add the user to the system with no password for root access
useradd -m -s /bin/bash $USERNAME 
usermod -aG wheel $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME

# Create the .ssh directory and authorized_keys file
mkdir -p /home/$USERNAME/.ssh
touch /home/$USERNAME/.ssh/authorized_keys

# Add the public key to the authorized_keys file
echo $PUBKEY >> /home/$USERNAME/.ssh/authorized_keys

# Set the correct permissions on the .ssh directory and authorized_keys file
chmod 700 /home/$USERNAME/.ssh
chmod 600 /home/$USERNAME/.ssh/authorized_keys

# Set the ownership of the .ssh directory and authorized_keys file to the new user
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config 
systemctl restart sshd.service