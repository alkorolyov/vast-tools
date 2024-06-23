#!/bin/bash

# Check if bandwidthTest is already present in /usr/local/bin
if [ ! -f /usr/local/bin/bandwidthTest ]; then
    echo "Downloading bandwidthTest..."
    # Use curl to download bandwidthTest from the specified URL
    sudo curl -o /usr/local/bin/bandwidthTest https://raw.githubusercontent.com/alkorolyov/vast-tools/main/bin/bandwidthTest

    # Check if download was successful
    if [ $? -eq 0 ]; then
        echo "bandwidthTest downloaded successfully."
        # Make the downloaded file executable
        sudo chmod +x /usr/local/bin/bandwidthTest
    else
        echo "Failed to download bandwidthTest. Please check your internet connection."
        exit 1
    fi
fi


# Function to check and install required packages
check_and_install() {
  local package=$1
  local status=$(dpkg-query -W --showformat='${db:Status-Status}\n' "$package" 2>/dev/null)

  if [[ "$status" != "installed" ]]; then
    echo "Package $package is not installed or not fully configured. Installing..."
    sudo apt update -qq > /dev/null 2>&1
    sudo apt install -y -qq "$package" > /dev/null 2>&1
  fi
}

# Check and install dmidecode and pciutils if necessary
check_and_install "dmidecode"
check_and_install "pciutils"

# Get the GPU devices and their addresses
nvidia_output=$(nvidia-smi --query-gpu=index,name,gpu_bus_id,pcie.link.gen.max --format=csv,noheader)

# Function to get slot information based on bus ID
get_slot_info() {
  local bus_id=$1
  local slot_info=""
  local capture=0

  # Loop through the dmidecode output
  while IFS= read -r line; do
    # Start capturing if we find the beginning of a slot info block
    if [[ "$line" == *"System Slot Information"* ]]; then
      capture=1
      slot_info=""
    fi

    # If capturing, append the line to slot_info
    if [[ $capture -eq 1 ]]; then
      slot_info+="$line"$'\n'
    fi

    # Stop capturing at the end of a slot info block
    if [[ "$line" == "" && $capture -eq 1 ]]; then
      capture=0
      # Check if this block contains the bus_id
      if echo "$slot_info" | grep -q -i "$bus_id"; then
        echo "$slot_info"
        return
      fi
    fi
  done < <(sudo dmidecode -t slot)
}

# Loop through each line in nvidia_output
while IFS=, read -r gpu_id gpu_name bus_id pci_gen; do
  # run bandwidth test
  bw_result=$(bandwidthTest device=$gpu_id)
  host_to_device=$(echo "$bw_result" | awk '/Host to Device Bandwidth/ {getline; getline; getline; print $2}')
  device_to_host=$(echo "$bw_result" | awk '/Device to Host Bandwidth/ {getline; getline; getline; print $2}')
  pci_speed=$(echo "scale=1; ($host_to_device + $device_to_host) / 2 / 1024" | bc)


  # Remove leading '00000000:' from bus_id
  bus_id=$(echo "$bus_id" | awk -F: '{print $2":"$3}')

  # Use the function to get slot information
  slot_info=$(get_slot_info "$bus_id")

  # Extract the slot designation and bus address from slot_info
  slot_designation=$(echo "$slot_info" | grep "Designation" | awk -F: '{print $2}' | sed 's/^[ \t]*//')

  # Get the PCIe link width and speed status
  lnksta=$(sudo lspci -s "$bus_id" -vvv | grep -i "LnkSta:" | xargs)
  pci_width=$(echo "$lnksta" | awk '{print $6, $7}')
 #  pci_speed=$(echo "$lnksta" | awk '{print $3, $4}')

  # Print the modified information
#  echo "Index:  $gpu_id"
  echo "Slot:    $slot_designation"
  echo "Device: $gpu_name"
  echo "Bus:     $bus_id"
  echo "PCIe:   $pci_gen.0 $pci_width"
  echo "Speed:   $pci_speed GB/s"
  echo ""
done <<< "$nvidia_output"
