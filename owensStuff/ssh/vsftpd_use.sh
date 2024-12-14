#!/usr/bin/env bash

# Allow FTP and FTPS connections through UFW firewall
ufw allow ftp
ufw allow ftps

# Install and configure vsftpd using the provided configuration file
instconf $RC/vsftpd.conf /etc/vsftpd.conf
psuccess "Configured vsftpd"

# Generate TLS certificate and key for vsftpd if they don't already exist
if ! [[ -f /etc/ssl/private/vsftpd.key ]]; then
    mkdir -p /etc/ssl/private
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/certs/vsftpd.crt -subj "/C=US/ST=California/L=Walnut/O=CyberPatriot/OU=High School Division/CN=FTP/emailAddress=test@example.com"
fi

# Set appropriate permissions for the TLS certificate and key
chmod 700 /etc/ssl/{private,certs}
chmod 600 /etc/ssl/private/vsftpd.key
chmod 600 /etc/ssl/certs/vsftpd.crt
psuccess "Configured vsftpd TLS"

# Restart vsftpd service
systemctl restart vsftpd && psuccess "Restarted vsftpd" || perror "Failed to restart vsftpd"
