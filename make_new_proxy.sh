#!/bin/bash

# Function to validate if a string is a valid integer
is_valid_integer() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Ask the user for container name, input port, and output port
echo "Enter a Docker container name (e.g. nginx):"
read container

# Validate external port input
while true; do
    echo "Enter the external (URL) port number:"
    read external_port
    if is_valid_integer "$external_port"; then
        break
    else
        echo "Error: Please enter a valid integer for the external port."
    fi
done

# Validate internal port input
while true; do
    echo "Enter the internal (Docker container) port number (e.g. 80):"
    read internal_port
    if is_valid_integer "$internal_port"; then
        break
    else
        echo "Error: Please enter a valid integer for the internal port."
    fi
done

# Write the Nginx configuration to a file
# The resolver is set to Docker's DNS resolver IP (127.0.0.11) so Nginx doesn't crash if the container isn't up.
echo "server {
    listen $external_port ssl;

    location / {
        resolver 127.0.0.11 valid=30s;
        proxy_pass http://$container:$internal_port;
        proxy_redirect off;
    }
}
" > "sites-available/$container.conf"


echo "location /$container {
        rewrite ^ https://sodasdev.space.swri.edu:$external_port/;
}
" > "all-redirects/$container.conf"


# Confirm that the file was created
echo "Nginx configuration created: $container.conf"

printf "\033[1;31m%s\033[0m\n" "Now add the port ($external_port:$external_port) to the docker-compose.yml and run docker-compose restart"

