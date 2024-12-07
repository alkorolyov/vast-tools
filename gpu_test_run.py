import torch
import subprocess
import os
import signal
import threading

# Create an event flag to signal threads to stop
stop_event = threading.Event()

# Function to install the stress tool if not already installed
def install_stress():
    try:
        # Check if 'stress' is already installed
        subprocess.run(['which', 'stress'], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print("Stress tool is already installed.")
    except subprocess.CalledProcessError:
        print("Stress tool not found. Installing quietly...")
        # Install 'stress' using apt without prompting the user
        subprocess.run(['sudo', 'apt', 'install', '-y', 'stress'], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print("Stress tool installed successfully.")

# Function to run the stress command on CPU
def run_stress(cpu_cores):
    # Start the stress command
    command = ["stress", "-c", str(cpu_cores)]  # Using -c instead of --cpu and removing timeout
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    print(f"Started CPU stress test on {cpu_cores} cores...")

    # Wait for the process to be interrupted
    try:
        # Keep the process running until a keyboard interrupt
        process.wait()
    except KeyboardInterrupt:
        print("\nKeyboardInterrupt received, stopping stress...")
        # Send SIGTERM to the process when we interrupt
        process.send_signal(signal.SIGTERM)
        process.wait()
        print("Stress test stopped.")

# Function to test GPU
def test_device(device_index):
    device = torch.device(f'cuda:{device_index}')
    print(f"Running test on device {device_index} ({torch.cuda.get_device_name(device)})")

    # Create tensors on the current device
    a = torch.randn((1024, 1024)).to(device)
    b = torch.randn((1024, 1024)).to(device)

    # Perform a matrix multiplication in a loop
    while not stop_event.is_set():
        torch.mm(a, b)

# Function to test CUDA devices in parallel
def test_cuda_devices_parallel():
    # Check if CUDA is available
    if not torch.cuda.is_available():
        print("CUDA is not available on this system.")
        return

    # Get the number of available CUDA devices
    num_devices = torch.cuda.device_count()
    print(f"Number of CUDA devices available: {num_devices}")

    # Create a thread for each device
    threads = []
    for i in range(num_devices):
        thread = threading.Thread(target=test_device, args=(i,))
        threads.append(thread)

    # Start all threads
    for thread in threads:
        thread.start()

    try:
        # Wait for all threads to complete
        for thread in threads:
            thread.join()
    except KeyboardInterrupt:
        print("\nKeyboardInterrupt received, stopping all threads... ", end="")
        stop_event.set()
        for thread in threads:
            thread.join()
        print("Done")

if __name__ == "__main__":
    try:
        # Step 1: Install stress tool if not already installed
        install_stress()

        # Step 2: Determine how many CPU cores to stress (leave 1 core per GPU)
        total_cpu_cores = os.cpu_count()
        num_gpus = torch.cuda.device_count()

        # Leave 1 core free for each GPU
        cpu_cores_to_use = max(1, total_cpu_cores - num_gpus)

        # Step 3: Run CPU stress test in the background
        cpu_stress_thread = threading.Thread(target=run_stress, args=(cpu_cores_to_use,))
        cpu_stress_thread.start()

        # Step 4: Run CUDA devices stress test
        test_cuda_devices_parallel()

        # Join CPU stress thread to ensure it finishes after GPU stress
        cpu_stress_thread.join()

    except KeyboardInterrupt:
        print("\nProgram interrupted by user.")
        stop_event.set()
