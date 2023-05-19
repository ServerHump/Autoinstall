#!/bin/bash

# Install required dependencies
sudo yum -y install wget perl

# Download Sentora installation script
wget http://sentora.org/install -O sentora_install.sh

# Make the script executable
chmod +x sentora_install.sh

# Define default values for Sentora installation
defaultLanguage=3
defaultTimezone="Asia/Kolkata"
defaultName="your-name"
defaultEmail="admin@example.com"
defaultHostname="your-hostname"
defaultPublicIP="your-public-ip"
defaultStreet="your-street"
defaultCity="your-city"
defaultState="your-state"
defaultCountry="your-country"
defaultZipcode="your-zipcode"

# Run the Sentora installation script with default values
sudo ./sentora_install.sh <<EOF
$defaultLanguage
$defaultTimezone
$defaultName
$defaultEmail
$defaultHostname
$defaultPublicIP
$defaultStreet
$defaultCity
$defaultState
$defaultCountry
$defaultZipcode
EOF

# Clean up installation files
rm sentora_install.sh

echo "Sentora installation completed successfully."
