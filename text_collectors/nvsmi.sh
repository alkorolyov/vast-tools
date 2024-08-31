# HELP gpu_ecc_errors_corrected Total number of ECC errors corrected
# TYPE gpu_ecc_errors_corrected counter
# HELP gpu_ecc_errors_uncorrected Total number of ECC errors uncorrected
# TYPE gpu_ecc_errors_uncorrected counter
# HELP gpu_temperature GPU temperature in degrees Celsius
# TYPE gpu_temperature gauge
# HELP gpu_power_draw GPU power draw in watts
# TYPE gpu_power_draw gauge
# HELP gpu_power_limit GPU power limit in watts
# TYPE gpu_power_limit gauge
# HELP gpu_utilization_gpu Percent of time over the past sample period during which one or more kernels was executing on the GPU.
# TYPE gpu_utilization_gpu gauge
# HELP gpu_utilization_memory Percent of time over the past sample period during which global (device) memory was being read or written.
# TYPE gpu_utilization_memory gauge
# HELP gpu_fan_speed Fan speed percentage
# TYPE gpu_fan_speed gauge
# HELP gpu_clock_sm SM clock speed in MHz
# TYPE gpu_clock_sm gauge
# HELP gpu_clock_mem Memory clock speed in MHz
# TYPE gpu_clock_mem gauge
# HELP gpu_pcie_gen PCIe link generation
# TYPE gpu_pcie_gen gauge
# HELP gpu_pcie_width PCIe link width
# TYPE gpu_pcie_width gauge
# HELP gpu_pstate GPU performance state
# TYPE gpu_pstate gauge
# HELP gpu_ecc_mode_current Current ECC mode
# TYPE gpu_ecc_mode_current gauge
# HELP gpu_ecc_mode_pending Pending ECC mode
# TYPE gpu_ecc_mode_pending gauge
# HELP gpu_memory_usage Percentage of total memory in use
# TYPE gpu_memory_usage gauge
gpu_temperature{model="RTX 4090",bus_id="02:00.0"} 52
gpu_power_draw{model="RTX 4090",bus_id="02:00.0"} 149.63
gpu_power_limit{model="RTX 4090",bus_id="02:00.0"} 150.00
gpu_utilization_gpu{model="RTX 4090",bus_id="02:00.0"} 100
gpu_utilization_memory{model="RTX 4090",bus_id="02:00.0"} 47
gpu_fan_speed{model="RTX 4090",bus_id="02:00.0"} 32
gpu_clock_sm{model="RTX 4090",bus_id="02:00.0"} 390
gpu_clock_mem{model="RTX 4090",bus_id="02:00.0"} 11251
gpu_pcie_gen{model="RTX 4090",bus_id="02:00.0"} 3
gpu_pcie_width{model="RTX 4090",bus_id="02:00.0"} 16
gpu_pstate{model="RTX 4090",bus_id="02:00.0"} 2
gpu_ecc_mode_current{model="RTX 4090",bus_id="02:00.0"} 0
gpu_ecc_mode_pending{model="RTX 4090",bus_id="02:00.0"} 0
gpu_memory_usage{model="RTX 4090",bus_id="02:00.0"} 11.12
gpu_temperature{model="RTX 4090",bus_id="84:00.0"} 53
gpu_power_draw{model="RTX 4090",bus_id="84:00.0"} 149.71
gpu_power_limit{model="RTX 4090",bus_id="84:00.0"} 150.00
gpu_utilization_gpu{model="RTX 4090",bus_id="84:00.0"} 100
gpu_utilization_memory{model="RTX 4090",bus_id="84:00.0"} 40
gpu_fan_speed{model="RTX 4090",bus_id="84:00.0"} 30
gpu_clock_sm{model="RTX 4090",bus_id="84:00.0"} 345
gpu_clock_mem{model="RTX 4090",bus_id="84:00.0"} 11251
gpu_pcie_gen{model="RTX 4090",bus_id="84:00.0"} 3
gpu_pcie_width{model="RTX 4090",bus_id="84:00.0"} 16
gpu_pstate{model="RTX 4090",bus_id="84:00.0"} 2
gpu_ecc_mode_current{model="RTX 4090",bus_id="84:00.0"} 0
gpu_ecc_mode_pending{model="RTX 4090",bus_id="84:00.0"} 0
gpu_memory_usage{model="RTX 4090",bus_id="84:00.0"} 11.12
