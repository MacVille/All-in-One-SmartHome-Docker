#!/bin/bash

# Define variables
DESTINATION_PATH="/opt/stacks/TEST"  # Replace with the desired destination path

# Define an array of GitHub raw links
REPO_URLS=(
    "https://raw.githubusercontent.com/MacVille/All-in-One-SmartHome-Docker/refs/heads/main/ha-configuration-example.yaml"  # Sample HA-Config-YAML
    "https://raw.githubusercontent.com/MacVille/All-in-One-SmartHome-Docker/refs/heads/main/docker-compose.yaml" #Docker-Compose File for All Containers
    "https://raw.githubusercontent.com/MacVille/All-in-One-SmartHome-Docker/refs/heads/main/.envexample" #Docker TEMPLATE .env File
)

# Function to display usage
function usage() {
    echo "No parameters are needed. Please edit the script to set the raw links and destination path."
    exit 1
}

# Ask the user if they want to proceed with the download
read -p "Do you want to download files from the specified GitHub raw links? (y/n): " confirmation

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Download canceled by the user."
    exit 0
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl could not be found. Please install curl before running this script."
    exit 1
fi

# Create the destination directory if it doesn't exist
mkdir -p "$DESTINATION_PATH"

# Loop through each URL in the array and download the file
for URL in "${REPO_URLS[@]}"; do
    echo "Downloading $URL..."
    FILE_NAME=$(basename "$URL")  # Extracting filename from the URL

    # Download the file with a progress bar
    curl -L --progress-bar -o "$DESTINATION_PATH/$FILE_NAME" "$URL"

    # Check if the download was successful
    if [ $? -ne 0 ]; then
        echo "Failed to download $URL."
    else
        echo "Successfully downloaded $FILE_NAME to $DESTINATION_PATH."
    fi
done

echo "Download complete."
exit 0
