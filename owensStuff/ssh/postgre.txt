#!/usr/bin/env bash
# Set the PostgreSQL configuration file path
PG_CONFIG="/etc/postgresql/12/main/postgresql.conf"

# Set the PostgreSQL authentication configuration file path
PG_HBA_CONFIG="/etc/postgresql/12/main/pg_hba.conf"

# Set the PostgreSQL access control configuration file path
PG_IDENT_CONFIG="/etc/postgresql/12/main/pg_ident.conf"

# Stop PostgreSQL service
systemctl stop postgresql

# Backup the original PostgreSQL configuration files
cp $PG_CONFIG $PG_CONFIG.bak
cp $PG_HBA_CONFIG $PG_HBA_CONFIG.bak
cp $PG_IDENT_CONFIG $PG_IDENT_CONFIG.bak

# Set strong password authentication for PostgreSQL
sed -i "s/#password_encryption =.*$/password_encryption = scram-sha-256/" $PG_CONFIG

# Configure PostgreSQL to listen on localhost only
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" $PG_CONFIG

# Configure PostgreSQL to allow only local connections
echo "host    all    all    127.0.0.1/32    md5" | tee -a $PG_HBA_CONFIG

# Disable remote connections
echo "host    all    all    0.0.0.0/0    reject" | tee -a $PG_HBA_CONFIG

# Prevent non-localhost user connections
echo "hostssl    all    all    0.0.0.0/0    reject" | tee -a $PG_HBA_CONFIG

# Configure PostgreSQL to log connections and disconnections
sed -i "s/#log_connections = off/log_connections = on/" $PG_CONFIG
sed -i "s/#log_disconnections = off/log_disconnections = on/" $PG_CONFIG

# Configure PostgreSQL to log failed attempts
sed -i "s/#log_line_prefix = ''/log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,client=%h '/" $PG_CONFIG

# Configure PostgreSQL to log all statements
sed -i "s/#log_statement = 'none'/log_statement = 'all'/" $PG_CONFIG

# Enable SSL encryption for PostgreSQL
sed -i "s/ssl = off/ssl = on/" $PG_CONFIG

# Generate and configure SSL certificates
openssl req -new -text -passout pass:password -subj "/CN=localhost" -out server.req
openssl rsa -in privkey.pem -passin pass:password -out server.key
openssl req -x509 -in server.req -text -key server.key -out server.crt
chmod 0600 server.key
mv server.key /etc/ssl/private/
mv server.crt /etc/ssl/certs/

# Configure PostgreSQL to use SSL certificates
echo "ssl_cert_file = '/etc/ssl/certs/server.crt'" | tee -a $PG_CONFIG
echo "ssl_key_file = '/etc/ssl/private/server.key'" | tee -a $PG_CONFIG

# Configure PostgreSQL to enforce SSL connections
echo "hostssl    all    all    0.0.0.0/0    cert" | tee -a $PG_HBA_CONFIG

# Configure PostgreSQL to use ident authentication for local connections
echo "local    all    all    peer" | tee -a $PG_HBA_CONFIG

# Enable connection pooling for improved performance
echo "max_connections = 100" | tee -a $PG_CONFIG
echo "shared_buffers = 256MB" | tee -a $PG_CONFIG

# Start PostgreSQL service
systemctl start postgresql

# Display PostgreSQL status
systemctl status postgres

