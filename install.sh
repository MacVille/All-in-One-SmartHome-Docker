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
DEFAULT_DESTINATION_PATH="/opt/stacks/SmartHome-All-in-One"

# Ask the user for the destination path with a default value
read -p "Please enter the destination path for downloaded files [default: $DEFAULT_DESTINATION_PATH]: " DESTINATION_PATH

# Use default destination path if the user doesn't input anything
if [ -z "$DESTINATION_PATH" ]; then
    DESTINATION_PATH="$DEFAULT_DESTINATION_PATH"
    echo "Using default destination path: $DESTINATION_PATH"
fi

# Create the destination directory if it doesn't exist
if ! mkdir -p "$DESTINATION_PATH"; then
    echo "Error: Could not create directory $DESTINATION_PATH. Check your permissions."
    exit 1
fi

# Define an associative array for GitHub raw links and their desired filenames
declare -A REPO_FILES=(
    ["https://raw.githubusercontent.com/MacVille/All-in-One-SmartHome-Docker/refs/heads/main/smarthome/homeassistant/ha-configuration-example.yaml"]="configuration.yaml"
    ["https://raw.githubusercontent.com/MacVille/All-in-One-SmartHome-Docker/refs/heads/main/smarthome/mosquitto/mosquitto-template.conf"]="mosquitto.config"
    ["https://raw.githubusercontent.com/MacVille/All-in-One-SmartHome-Docker/refs/heads/main/docker/docker-compose.yaml"]="compose.yaml"
    ["https://raw.githubusercontent.com/MacVille/All-in-One-SmartHome-Docker/refs/heads/main/docker/.envexample"]=".env"
)

# Ask the user if they want to proceed with downloading all files
read -r -p "Do you want to download all files to the specified destination? (Y/n): " confirmation

# Use default confirmation as "y" if the user doesn't input anything
confirmation=${confirmation:-y}

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Download canceled by the user."
    exit 0
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl could not be found. Please install curl before running this script."
    exit 1
fi

# Loop through each entry in the associative array and download the files
for URL in "${!REPO_FILES[@]}"; do
    FILENAME="${REPO_FILES[$URL]}"  # Get the corresponding desired filename

    echo ""
    echo "Downloading $URL as $FILENAME..."
    curl -L --progress-bar -o "$DESTINATION_PATH/$FILENAME" "$URL"

    if [ $? -ne 0 ]; then
        echo "Failed to download $URL."
    else
        echo "Successfully downloaded $FILENAME to $DESTINATION_PATH."
    fi
done

# Modify placeholders in configuration.yaml
if [ -f "$DESTINATION_PATH/configuration.yaml" ]; then
    echo ""
    read -r -p "Do you want to modify the database connection placeholders in configuration.yaml? (Y/n): " modify_config
    modify_config=${modify_config:-y}

    if [[ "$modify_config" == "y" || "$modify_config" == "Y" ]]; then
        read -p "Enter DB username: " DBUSER
        read -p "Enter DB password: " DBPASSWORD
        read -p "Enter MySQL server address: " MYSQLSERVER
        read -p "Enter database name: " DATABASENAME

        sed -i \
            -e "s/DBUSERNAME/$DBUSER/g" \
            -e "s/DBUSERPASSWORD/$DBPASSWORD/g" \
            -e "s/MYSQLSERVER/$MYSQLSERVER/g" \
            -e "s/DATABASENAME/$DATABASENAME/g" \
            "$DESTINATION_PATH/configuration.yaml"

        echo "Placeholders in configuration.yaml have been updated."
    else
        echo "Skipping placeholder modifications for configuration.yaml."
    fi
fi

# Modify placeholders in .env
if [ -f "$DESTINATION_PATH/.env" ]; then
    echo ""
    read -r -p "Do you want to modify the placeholders in .env? (Y/n): " modify_env
    modify_env=${modify_env:-y}

    if [[ "$modify_env" == "y" || "$modify_env" == "Y" ]]; then
        read -p "Enter the value for TIME_ZONE: " TIMEZONE
        read -p "Enter the value for ROOT_ACCESS_PASSWORD: " ROOTACCESSPASSWORD
        read -p "Enter the value for USER_DB_NAME: " USERDBNAME
        read -p "Enter the value for MYSQL_USER: " MYSQLUSER
        read -p "Enter the value for DATABASE_PASSWORD: " MYSQLUSERPASSWORD
        read -p "Enter the value for PUID: " PUID
        read -p "Enter the value for PGID: " PGID

        sed -i \
            -e "s/TIME_ZONE/$TIMEZONE/g" \
            -e "s/ROOT_ACCESS_PASSWORD/$ROOTACCESSPASSWORD/g" \
            -e "s/USER_DB_NAME/$USERDBNAME/g" \
            -e "s/MYSQL_USER/$MYSQLUSER/g" \
            -e "s/DATABASE_PASSWORD/$MYSQLUSERPASSWORD/g" \
            -e "s/PUID/$PUID/g" \
            -e "s/PGID/$PGID/g" \

            "$DESTINATION_PATH/.env"

        echo "Placeholders in .env have been updated."
    else
        echo "Skipping placeholder modifications for .env."
    fi
fi

echo ""
echo "Download and modification process complete."
exit 0
