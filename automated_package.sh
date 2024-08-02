#!/bin/bash

# Array of available roles
roles=("ansible" "base" "web_server" "workstation")

# Display menu
echo "Select roles to include in the playbook (e.g., 1,2):"
for i in "${!roles[@]}"; do
    echo "$((i+1)). ${roles[i]}"
done

read -p "Enter the numbers corresponding to your choices, separated by commas: " choices

# Function to map choice to role
map_choice_to_role() {
  local index=$(( $1 - 1 ))
  if [[ $index -ge 0 && $index -lt ${#roles[@]} ]]; then
    echo "${roles[$index]}"
  else
    echo "Invalid choice: $1"
    exit 1
  fi
}

# Split the choices into an array
IFS=',' read -r -a choice_array <<< "$choices"

# Initialize selected roles array
selected_roles=()

# Map choices to roles
for choice in "${choice_array[@]}"; do
  role=$(map_choice_to_role "$choice")
  selected_roles+=("$role")
done

# Prompt user to choose the host
read -p "Enter the host you want to run the playbook on (e.g., localhost or an IP address): " host

# Create playbook file
cat <<EOL > install_packages.yml
---
- hosts: $host
  become: yes
  roles:
EOL

# Add roles to the playbook
for role in "${selected_roles[@]}"; do
  echo "    - $role" >> install_packages.yml
done

# Prompt user to run the playbook or check it manually
echo "Playbook 'install_packages.yml' has been created."
read -p "Do you want to run the playbook now? (y/n): " run_now

if [[ $run_now == "y" ]]; then
  ansible-playbook install_packages.yml
  rm install_packages.yml
  echo "Playbook executed and file removed."
else
  echo "Playbook saved as 'install_packages.yml'. Please check and run it with the following command:"
  echo "ansible-playbook install_packages.yml"
fi

