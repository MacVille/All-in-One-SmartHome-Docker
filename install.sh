#!/bin/bash

# Clear Terminal from previous Text
clear

echo "#########################################################################"
echo "#     _____                          __   __  __                        #"
echo "#    / ___/ ____ ___   ____ _ _____ / /_ / / / /____   ____ ___   ___   #"
echo "#    \\__ \\ / __ \`__ \\ / __ \`// ___// __// /_/ // __ \\ / __ \`__ \\ / _ \\  #"
echo "#   ___/ // / / / / // /_/ // /   / /_ / __  // /_/ // / / / / //  __/  #"
echo "#  /____//_/ /_/ /_/ \\__,_//_/    \\__//_/ /_/ \\/____//_/ /_/ /_/ \\___/   #"
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
read -p "Do you want to download all files to the specified destination? (y/n): " confirmation
confirmation=${confirmation:-y}
if [ "$confirmation" = "n" ] || [ "$confirmation" = "N" ]; then
    echo ""
else
    echo ""
fi

echo ""
echo "Checking for existing files..."
for URL in "${!REPO_FILES[@]}"; do
    FILENAME="${REPO_FILES[$URL]}"  # Get the corresponding desired filename
    
    # Check if file exists with current name and ask for overwrite confirmation
    if [ -e "$DESTINATION_PATH/$FILENAME" ]; then
        echo "File $DESTINATION_PATH/$FILENAME already exists. Overwrite? (y/n):"
        read answer
        case $answer in
            y|Y) continue ;;
            n|N) continue ;;
            *) usage; exit 1;;
        esac
    # Download the file using curl and save it to the destination path with a copy and a backup
    else
        filename=$(basename "$URL")
        filepath="$DESTINATION_PATH/$filename"
        
        if [ ! -f "$filepath" ]; then
            echo "Downloaded file: $filepath"
        fi
        
        # Copy original URL into the new path
        cp "$URL" "$filepath"
        
        # Create a backup copy
        mv "$filepath" "$DESTINATION_PATH/$(basename "$filename").bak"
    fi
done

echo ""
echo "Download completed."