#!/usr/bin/env bash

# Print Prometheus metrics header
echo "# HELP nvidia_gpu_ecc_errors_corrected Total number of ECC errors corrected"
echo "# TYPE nvidia_gpu_ecc_errors_corrected counter"
echo "# HELP nvidia_gpu_ecc_errors_uncorrected Total number of ECC errors uncorrected"
echo "# TYPE nvidia_gpu_ecc_errors_uncorrected counter"
echo "# HELP nvidia_gpu_temperature GPU temperature in degrees Celsius"
echo "# TYPE nvidia_gpu_temperature gauge"
echo "# HELP nvidia_gpu_power_draw GPU power draw in watts"
echo "# TYPE nvidia_gpu_power_draw gauge"
echo "# HELP nvidia_gpu_power_limit GPU power limit in watts"
echo "# TYPE nvidia_gpu_power_limit gauge"
echo "# HELP nvidia_gpu_utilization_gpu GPU utilization percentage"
echo "# TYPE nvidia_gpu_utilization_gpu gauge"
echo "# HELP nvidia_gpu_utilization_memory Memory utilization percentage"
echo "# TYPE nvidia_gpu_utilization_memory gauge"
echo "# HELP nvidia_gpu_fan_speed Fan speed percentage"
echo "# TYPE nvidia_gpu_fan_speed gauge"
echo "# HELP nvidia_gpu_clock_sm SM clock speed in MHz"
echo "# TYPE nvidia_gpu_clock_sm gauge"
echo "# HELP nvidia_gpu_clock_mem Memory clock speed in MHz"
echo "# TYPE nvidia_gpu_clock_mem gauge"
echo "# HELP nvidia_gpu_pcie_gen PCIe link generation"
echo "# TYPE nvidia_gpu_pcie_gen gauge"
echo "# HELP nvidia_gpu_pcie_width PCIe link width"
echo "# TYPE nvidia_gpu_pcie_width gauge"
echo "# HELP nvidia_gpu_pstate GPU performance state"
echo "# TYPE nvidia_gpu_pstate gauge"
echo "# HELP nvidia_gpu_ecc_mode_current Current ECC mode"
echo "# TYPE nvidia_gpu_ecc_mode_current gauge"
echo "# HELP nvidia_gpu_ecc_mode_pending Pending ECC mode"
echo "# TYPE nvidia_gpu_ecc_mode_pending gauge"

# Query NVIDIA GPU metrics including GPU name
output=$(nvidia-smi --query-gpu=gpu_bus_id,pcie.link.gen.current,pcie.link.width.current,fan.speed,pstate,utilization.gpu,utilization.memory,ecc.mode.current,ecc.mode.pending,ecc.errors.uncorrected.aggregate.total,ecc.errors.corrected.aggregate.total,temperature.gpu,power.draw,power.limit,clocks.sm,clocks.mem,name --format=csv,noheader)

# Read the output line by line
while IFS=',' read -r pci_bus_id pcie_gen pcie_width fan_speed pstate gpu_util mem_util ecc_mode_current ecc_mode_pending ecc_errors_uncorrected ecc_errors_corrected temp_gpu power_draw power_limit clocks_sm clocks_mem name; do

    # Sanitize GPU name for Prometheus label
    name=$(echo "$name" | awk '{print $(NF-1), $NF}')
    pci_bus_id=$(echo "$pci_bus_id" | awk -F':' '{print $(NF-1)":"$NF}')

    # Remove percentage signs and extra characters
    fan_speed=$(echo "$fan_speed" | tr -d ' %')
    gpu_util=$(echo "$gpu_util" | tr -d ' %')
    mem_util=$(echo "$mem_util" | tr -d ' %')
    temp_gpu=$(echo "$temp_gpu" | tr -d ' ')
    power_draw=$(echo "$power_draw" | tr -d ' W')
    power_limit=$(echo "$power_limit" | tr -d ' W')
    clocks_sm=$(echo "$clocks_sm" | tr -d ' MHz')
    clocks_mem=$(echo "$clocks_mem" | tr -d ' MHz')

    # Handle other columns
    pcie_gen=$(echo "$pcie_gen" | tr -d ' ')
    pcie_width=$(echo "$pcie_width" | tr -d ' ')
    pstate=$(echo "$pstate" | tr -d ' ' | sed 's/P//')
    ecc_errors_corrected=$(echo "$ecc_errors_corrected" | tr -d ' ')
    ecc_errors_uncorrected=$(echo "$ecc_errors_uncorrected" | tr -d ' ')

    # Convert ECC modes to boolean
    ecc_mode_current=$( [[ "$ecc_mode_current" == "Enabled" ]] && echo 1 || echo 0 )
    ecc_mode_pending=$( [[ "$ecc_mode_pending" == "Enabled" ]] && echo 1 || echo 0 )

    # Print Prometheus metrics
    if [[ "$ecc_errors_corrected" != "[N/A]" ]]; then
        echo "nvidia_gpu_ecc_errors_corrected{model=\"$name\",bus_id=\"$pci_bus_id\"} $ecc_errors_corrected"
    fi

    if [[ "$ecc_errors_uncorrected" != "[N/A]" ]]; then
        echo "nvidia_gpu_ecc_errors_uncorrected{model=\"$name\",bus_id=\"$pci_bus_id\"} $ecc_errors_uncorrected"
    fi

    echo "nvidia_gpu_temperature{model=\"$name\",bus_id=\"$pci_bus_id\"} $temp_gpu"
    echo "nvidia_gpu_power_draw{model=\"$name\",bus_id=\"$pci_bus_id\"} $power_draw"
    echo "nvidia_gpu_power_limit{model=\"$name\",bus_id=\"$pci_bus_id\"} $power_limit"
    echo "nvidia_gpu_utilization_gpu{model=\"$name\",bus_id=\"$pci_bus_id\"} $gpu_util"
    echo "nvidia_gpu_utilization_memory{model=\"$name\",bus_id=\"$pci_bus_id\"} $mem_util"
    echo "nvidia_gpu_fan_speed{model=\"$name\",bus_id=\"$pci_bus_id\"} $fan_speed"
    echo "nvidia_gpu_clock_sm{model=\"$name\",bus_id=\"$pci_bus_id\"} $clocks_sm"
    echo "nvidia_gpu_clock_mem{model=\"$name\",bus_id=\"$pci_bus_id\"} $clocks_mem"
    echo "nvidia_gpu_pcie_gen{model=\"$name\",bus_id=\"$pci_bus_id\"} $pcie_gen"
    echo "nvidia_gpu_pcie_width{model=\"$name\",bus_id=\"$pci_bus_id\"} $pcie_width"
    echo "nvidia_gpu_pstate{model=\"$name\",bus_id=\"$pci_bus_id\"} $pstate"
    echo "nvidia_gpu_ecc_mode_current{model=\"$name\",bus_id=\"$pci_bus_id\"} $ecc_mode_current"
    echo "nvidia_gpu_ecc_mode_pending{model=\"$name\",bus_id=\"$pci_bus_id\"} $ecc_mode_pending"

done <<< "$output"
