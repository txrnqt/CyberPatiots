#!/usr/bin/env bash

# Install and configure sshd using the provided configuration file
instconf $RC/sshd_config /etc/ssh/sshd_config

# Create a backup directory and move any existing sshd configuration files
mkdir -p $BACKUP/sshd
mv /etc/ssh/sshd_config.d/*.conf $BACKUP/sshd

# Set ownership and permissions for sshd configuration files
chown -R root:root /etc/ssh
chmod 755 /etc/ssh

# Set permissions for sshd configuration files
chmod 644 /etc/ssh/*

# Restart sshd service
systemctl restart sshd || perror "Could not restart sshd"
psuccess "Configured sshd"

# Remove short moduli from moduli file if it exists
if [[ -f /etc/ssh/moduli ]]; then
    pinfo "Removing short moduli"
    backup /etc/ssh/moduli
    sudo awk '$5 >= 3071' /etc/ssh/moduli | sudo tee /etc/ssh/moduli.tmp
    sudo mv /etc/ssh/moduli.tmp /etc/ssh/moduli
fi
