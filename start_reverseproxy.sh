#!/bin/bash

# Read the port mappings from ports.txt
ports=$(awk '{print $0}' ORS=, ports.txt | sed 's/,$/\n/')

# Print out the formatted ports
echo "Formatted ports:"
echo "$ports"

# Set the environment variable with the port mappings
export PORT_MAPPINGS="[$ports]"

# Start Docker Compose
docker-compose up -d

