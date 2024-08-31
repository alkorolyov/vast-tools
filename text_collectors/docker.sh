#!/usr/bin/env bash
#
# Description: Expose metrics from docker stats 
#
# Author: Alexander Korolyov <korol.al@gmail.com>

# Run docker stats command and capture the output
docker stats --no-stream --format "{{.ID}} {{.Name}} {{.CPUPerc}} {{.MemUsage}} {{.MemPerc}} {{.NetIO}} {{.BlockIO}} {{.PIDs}}" | while read -r line; do
    # Parse each line of the docker stats output
    CONTAINER_ID=$(echo $line | awk '{print $1}')
    NAME=$(echo $line | awk '{print $2}')
    CPU=$(echo $line | awk '{print $3}' | sed 's/%//')
    MEM_USAGE=$(echo $line | awk '{print $4}')
    MEM_LIMIT=$(echo $line | awk '{print $6}')
    MEM_PERC=$(echo $line | awk '{print $7}' | sed 's/%//')
    NET_IO_RX=$(echo $line | awk '{print $8}')
    NET_IO_TX=$(echo $line | awk '{print $10}')
    BLOCK_IO_READ=$(echo $line | awk '{print $11}')
    BLOCK_IO_WRITE=$(echo $line | awk '{print $13}')
    PIDS=$(echo $line | awk '{print $14}')

    # Convert to bytes
    convert_to_bytes() {
        local input=$1
        local value=$(echo "$input" | sed 's/[A-Za-z%]//g')
        # strip 'i' and normalize to upper letters
        local unit=$(echo "$input" | sed 's/[0-9.%i]//g' | tr '[:lower:]' '[:upper:]')
        # Debug
        # echo -e "\ninput $1"
        # echo -e "value $value"
        # echo -e "unit $unit"

        case "$unit" in
            B) echo "${value}";;
            KB) echo "$(echo "${value} * 1024" | bc | awk '{printf "%.0f", $0}')";;
            MB) echo "$(echo "${value} * 1024 * 1024" | bc | awk '{printf "%.0f", $0}')";;
            GB) echo "$(echo "${value} * 1024 * 1024 * 1024" | bc | awk '{printf "%.0f", $0}')";;
            TB) echo "$(echo "${value} * 1024 * 1024 * 1024 * 1024" | bc | awk '{printf "%.0f", $0}')";;
        esac
    }

    MEM_USAGE_BYTES=$(convert_to_bytes $MEM_USAGE)
    MEM_LIMIT_BYTES=$(convert_to_bytes $MEM_LIMIT)
    NET_IO_RX_BYTES=$(convert_to_bytes $NET_IO_RX)
    NET_IO_TX_BYTES=$(convert_to_bytes $NET_IO_TX)
    BLOCK_IO_READ_BYTES=$(convert_to_bytes $BLOCK_IO_READ)
    BLOCK_IO_WRITE_BYTES=$(convert_to_bytes $BLOCK_IO_WRITE)

    # Output metrics in Prometheus format
    echo "docker_container_cpu_percentage{name=\"$NAME\",id=\"$CONTAINER_ID\"} $CPU"
    echo "docker_container_memory_usage_bytes{name=\"$NAME\",id=\"$CONTAINER_ID\"} $MEM_USAGE_BYTES"
    echo "docker_container_memory_limit_bytes{name=\"$NAME\",id=\"$CONTAINER_ID\"} $MEM_LIMIT_BYTES"
    echo "docker_container_memory_percentage{name=\"$NAME\",id=\"$CONTAINER_ID\"} $MEM_PERC"
    echo "docker_container_network_receive_bytes{name=\"$NAME\",id=\"$CONTAINER_ID\"} $NET_IO_RX_BYTES"
    echo "docker_container_network_transmit_bytes{name=\"$NAME\",id=\"$CONTAINER_ID\"} $NET_IO_TX_BYTES"
    echo "docker_container_block_io_read_bytes{name=\"$NAME\",id=\"$CONTAINER_ID\"} $BLOCK_IO_READ_BYTES"
    echo "docker_container_block_io_write_bytes{name=\"$NAME\",id=\"$CONTAINER_ID\"} $BLOCK_IO_WRITE_BYTES"
    echo "docker_container_pids{name=\"$NAME\",id=\"$CONTAINER_ID\"} $PIDS"
done
