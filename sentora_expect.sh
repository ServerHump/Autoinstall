#!/usr/bin/expect -f

# Install expect if not already installed
sudo yum -y install expect

# Define default values for Sentora installation
set timeout -1
set defaultValues {
    "3"             # Language: English
    "Asia/Kolkata"  # Timezone: Asia/Kolkata
    "your-name"     # Your name
    "admin@example.com" # Email address
    "your-hostname" # Hostname
    "your-public-ip" # Public IP address
    "your-street"   # Street address
    "your-city"     # City
    "your-state"    # State
    "your-country"  # Country
    "your-zipcode"  # Zip code
}

spawn ./sentora_install.sh

expect "Select Language (0-6) [3]: "
send "$defaultValues\r"

expect "Enter a valid timezone [UTC]: "
send "$defaultValues\r"

expect "Please enter your name [your-name]: "
send "$defaultValues\r"

expect "Enter your email address [admin@example.com]: "
send "$defaultValues\r"

expect "Enter your hostname [your-hostname]: "
send "$defaultValues\r"

expect "Enter your public IP address [your-public-ip]: "
send "$defaultValues\r"

expect "Enter your street address [your-street]: "
send "$defaultValues\r"

expect "Enter your city [your-city]: "
send "$defaultValues\r"

expect "Enter your state [your-state]: "
send "$defaultValues\r"

expect "Enter your country [your-country]: "
send "$defaultValues\r"

expect "Enter your ZIP code [your-zipcode]: "
send "$defaultValues\r"

expect eof

# Uninstall expect
sudo yum -y remove expect

echo "Sentora installation completed successfully."
