# kwel

sysadmin user config script

## Overview

Description This bash script automates the process of creating multiple users and groups on a Linux system. It reads user data from an input file (either .txt or .csv), creates users with their personal groups, assigns additional groups, sets random passwords, and logs all actions. This is a project from HNG  [https://hng.tech/internship] or [https://hng.tech.hire] I was able to learn and relearn many concepts form bash scripting

## Features

- Reads user data from .txt (semicolon-delimited) or .csv files
- Creates users with personal groups
- Assigns users to additional groups
- Generates random passwords for each user
- Logs all actions for auditing purposes
- Stores generated passwords securely

## Prerequisites

- Linux system with bash shell
- Root or sudo access
- useradd, groupadd, and usermod commands available
- openssl for generating random passwords

## Usage

1. Save the script as <your_name.sh>
2. Make the script executable: chmod +x <your_name.sh>
3. Prepare an input file (e.g., users.txt or users.csv) with user data: For users.txt (semicolon-delimited): username;group1,group2,group3 For users.csv (comma-delimited): username,group1,group2,group3
4. Run the script with sudo, providing the input file: sudo ./create_users.sh users.txt or sudo ./create_users.sh users.csv

## Output

- Users are created with their personal groups
- Additional groups are created if they don't exist
- Users are added to specified groups
- Random passwords are generated for each user
- All actions are logged in /var/log/user_management.log
- Passwords are stored in /var/secure/user_passwords.csv

## Security Notes

- The script must be run with root privileges
- Generated passwords are stored in a secure location (/var/secure/user_passwords.csv)
- It's recommended to change the generated passwords upon first login

## Customization

- Log file location can be modified by changing the LOG_FILE variable
- Password file location can be modified by changing the PASSWORD_FILE variable
- Password generation method can be customized by modifying the openssl rand -base64 12 command

## Troubleshooting

- Ensure the input file exists and is readable.
- Check /var/log/user_management.log for detailed information on each action.
- Verify that you have the necessary permissions to create users and groups.

Disclaimer This script is provided as-is, without any warranties. Always test in a safe environment before using in production.

I tested the above script in an AWS EC2 instance to avoid adding the users on my personal laptop, I will also be testing the above in AWS EKS cluster. 

Contributing Feel free to fork this project and submit pull requests with improvements or bug fixes.