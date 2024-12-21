#!/bin/bash
# Clear Terminal from previous Text
clear
echo "#########################################################################"
echo "#     _____                          __   __  __                        #"
echo "#    / ___/ ____ ___   ____ _ _____ / /_ / / / /____   ____ ___   ___   #"
echo "#    \\__ \\ / __ \`__ \\ / __ \`// ___// __// /_/ // __ \\ / __ \`__ \\ / _ \\  #"
echo "#   ___/ // / / / / // /_/ // /   / /_ / __  // /_/ // / / / / //  __/  #"
echo "#  /____//_/ /_/ /_/ \\__,_//_/    \\__//_/ /_/ \\____//_/ /_/ /_/ \\___/   #"
echo "#                                                                       #"
echo "#      ___     __ __        _                ____                       #"
echo "#     /   |   / // /       (_)____          / __ \\ ____   ___           #"
echo "#    / /| |  / // /______ / // __ \\ ______ / / / // __ \\ / _ \\          #"
echo "#   / ___ | / // //_____// // / / //_____// /_/ // / / //  __/          #"
echo "#  /_/  |_|/_//_/       /_//_/ /_/        \\____//_/ /_/ \\___/           #"
echo "#                                                                       #"
echo "#########################################################################"
echo ""
echo ""

# Define a default destination path
DEFAULT_DESTINATION_PATH="/opt/stacks/SmartHome-All-in-One"  # Replace with your default destination path
# Ask the user for the destination path with a default value
read -p "Please enter the destination path for downloaded files [default: $DEFAULT_DESTINATION_PATH]: " DESTINATION_PATH
# Use default destination path if the user doesn't input anything
if [ -z "$DESTINATION_PATH" ]; then
    DESTINATION_PATH="$DEFAULT_DESTINATION_PATH"
    echo "Using default destination path: $DESTINATION_PATH"
fi
# Define an associative array for GitHub raw links and their desired filenames
declare -A REPO_FILES=(
    ["https://raw.githubusercontent.com/MacVille/All-in-One-SmartHome-Docker/refs/heads/main/ha-configuration-example.yaml"]="configuration.yaml"
    ["https://raw.githubusercontent.com/MacVille/All-in-One-SmartHome-Docker/refs/heads/main/docker-compose.yaml"]="compose.yaml"
    ["https://raw.githubusercontent.com/MacVille/All-in-One-SmartHome-Docker/refs/heads/main/.envexample"]=".env"
)
# Function to display usage
function usage() {
    echo "No parameters are needed. Please edit the script to set the raw links and destination path."
    exit 1
}
# Ask the user if they want to proceed with downloading all files
read -p "Do you want to download all files to the specified destination? (Y/n): " confirmation
# Use default confirmation as "y" if the user doesn't input anything
confirmation=${confirmation:-y}
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
# Loop through each entry in the associative array and download the files
for URL in "${!REPO_FILES[@]}"; do
    FILENAME="${REPO_FILES[$URL]}"  # Get the corresponding desired filename
    # Use the custom filename if provided; otherwise, use the original filename from the URL
    if [ -z "$FILENAME" ]; then
        FILENAME=$(basename "$URL")
    fi
    # Add an empty line for clarity before each download
    echo ""
    echo "Downloading $URL as $FILENAME..."
    # Download the file with a progress bar
    curl -L --progress-bar -o "$DESTINATION_PATH/$FILENAME" "$URL"
    # Check if the download was successful
    if [ $? -ne 0 ]; then
        echo "Failed to download $URL."
    else
        echo "Successfully downloaded $FILENAME to $DESTINATION_PATH."
    fi
done
echo ""
echo "Download process complete."
exit 0