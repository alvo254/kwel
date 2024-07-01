#!/bin/bash


#    Description: 
#Creates users and groups based on input file (txt or csv), sets up home directories,
#generates random passwords, and logs all actions.

# Check if script is run as root for oriviledge escalation
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Check if input file is provided as a keyword arg
if [ $# -eq 0 ]; then
    echo "Please provide an input file"
    echo "Usage: $0 <input-file.txt or input-file.csv>"
    exit 1
fi

# This are my variables 
INPUT_FILE=$1
LOG_FILE="/var/log/user_management.log"
PASSWORD_DIR="/var/secure"
PASSWORD_FILE="$PASSWORD_DIR/user_passwords.csv"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Input file does not exist"
    exit 1
fi

# Create log file if it doesn't exist assuming this script was created after the infrastructure setup
touch $LOG_FILE

# Create secure directory if it doesn't exist assuming this script was created after the infrastructure setup
mkdir -p $PASSWORD_DIR

# Create password file if it doesn't exist and set permissions assuming this script was created after the infrastructure setup
touch $PASSWORD_FILE
chmod 600 $PASSWORD_FILE

# Function to log actions
log_action() {
    echo "$(date): $1" >> $LOG_FILE
}

# Determine the delimiter based on file extension
if [[ "$INPUT_FILE" == *.csv ]]; then
    delimiter=","
else
    delimiter=";"
fi

# Process user data
# Internal Field Separator(IFS) - is a special shell variable that determines how bash recognizes word boundaries
while IFS="$delimiter" read -r username groups
do
    # Remove leading/trailing whitespace that might be present in the input file 
    # xargs reads items from standard input, delimited by blanks or newlines, and executes a command using these items as arguments.
    username=$(echo $username | xargs)
    groups=$(echo $groups | xargs)

    # Skip empty lines
    [ -z "$username" ] && continue

    # Check if user already exists
    # &>/dev/null construct in bash is used for redirecting both standard output (stdout) and standard error (stderr) to /dev/null, effectively silencing all output from a command
    # Silencing output: When you don't want to see any output from a command, whether it's successful output or error messages
    if id "$username" &>/dev/null; then
        log_action "User $username already exists. Skipping...."
        continue
    fi

    # Create user's personal group. The groupadd command creates a new group in the system.
    groupadd $username
    log_action "Created group $username"

    # Create user with personal group
    useradd -m -g $username $username
    log_action "Created user $username with personal group $username"

    # Set random password
    password=$(openssl rand -base64 12) # the 12 specifies number of bytes generated
    echo "$username:$password" | chpasswd
    echo "$username,$password" >> $PASSWORD_FILE
    log_action "Set password for user $username"

    # Add user to additional groups that were non-existent
    IFS=',' read -ra group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        group=$(echo $group | xargs)
        if ! getent group $group > /dev/null 2>&1; then
            groupadd $group
            log_action "Created group $group"
        fi
        usermod -a -G $group $username
        log_action "Added user $username to group $group"
    done

    log_action "Completed setup for user $username"
done < "$INPUT_FILE"

echo "User creation process completed succesfuly. Check $LOG_FILE for more details."