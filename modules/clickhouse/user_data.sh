#!/bin/bash

# Wait for the NVMe device to appear
while [ ! -e /dev/nvme1n1 ]; do
  echo "Waiting for /dev/nvme1n1 to appear"
  sleep 1
done

# Format and mount the EBS volume
mkdir -p /var/lib/clickhouse

# Check if the device is already formatted
if ! blkid /dev/nvme1n1; then
  mkfs -t ext4 /dev/nvme1n1
fi

mount /dev/nvme1n1 /var/lib/clickhouse

# Ensure the volume is remounted automatically after a reboot
echo '/dev/nvme1n1 /var/lib/clickhouse ext4 defaults,nofail 0 2' >> /etc/fstab

# Set up environment variables
# shellcheck disable=SC2154
echo "export S3_BUCKET_NAME=${s3_bucket_name}" >> /etc/environment
# shellcheck disable=SC2154
export AWS_DEFAULT_REGION=${aws_region}
# shellcheck disable=SC2154,SC2155
export CLICKHOUSE_PASSWORD=$(aws secretsmanager get-secret-value --secret-id "${clickhouse_secret_id}" --query SecretString --output text)
echo "$CLICKHOUSE_PASSWORD" > /tmp/password

# Install dependencies and Clickhouse
yum install -y yum-utils jq
yum-config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo
yum install -y clickhouse-server clickhouse-client

# Extract password from secret
PASSWORD=$(echo "$CLICKHOUSE_PASSWORD" | jq .password --raw-output | tr -d '\n')

# Escape password for sed
ESCAPED_PASSWORD=$(printf '%s\n' "$PASSWORD" | sed -e 's/[]\/$*.^[]/\\&/g')

# Configure Clickhouse user password
sed -i "s|<password></password>|<password>$ESCAPED_PASSWORD</password>|" /etc/clickhouse-server/users.xml

# Enable external access
sed -i 's|<!-- <listen_host>0\.0\.0\.0</listen_host> -->|<listen_host>0.0.0.0</listen_host>|' /etc/clickhouse-server/config.xml

# Create the storage config file
mkdir -p /etc/clickhouse-server/config.d
cat <<EOF > /etc/clickhouse-server/config.d/storage_config.xml
<clickhouse>
  <storage_configuration>
    <disks>
      <s3_disk>
        <type>s3</type>
        <endpoint>https://${s3_bucket_name}.s3.${aws_region}.amazonaws.com/tables/</endpoint>
        <metadata_path>/var/lib/clickhouse/disks/s3/</metadata_path>
      </s3_disk>
      <s3_cache>
        <type>cache</type>
        <disk>s3_disk</disk>
        <path>/var/lib/clickhouse/disks/s3_cache/</path>
        <max_size>100Gi</max_size>
      </s3_cache>
    </disks>
    <policies>
      <s3_main>
        <volumes>
          <main>
            <disk>s3_disk</disk>
          </main>
        </volumes>
      </s3_main>
    </policies>
  </storage_configuration>
</clickhouse>
EOF

chown clickhouse:clickhouse /etc/clickhouse-server/config.d/storage_config.xml

# Enable and start Clickhouse
systemctl enable clickhouse-server
systemctl start clickhouse-server
