import torch
import threading

# Create an event flag to signal threads to stop
stop_event = threading.Event()

def test_device(device_index):
    device = torch.device(f'cuda:{device_index}')
    print(f"Running test on device {device_index} ({torch.cuda.get_device_name(device)})")

    # Create tensors on the current device
    a = torch.randn((1024, 1024)).to(device)
    b = torch.randn((1024, 1024)).to(device)

    # Perform a simple addition in a loop
    while not stop_event.is_set():
        torch.mm(a, b).shape

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
    test_cuda_devices_parallel()
