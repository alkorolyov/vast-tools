# test your machine
```
./vast show machines | grep machine_id
./vast search offers 'machine_id = xxx'
./vast create instance xxx --image pytorch/pytorch --disk 8 --jupyter --jupyter-lab
```
# connect via ssh and run
```wget https://raw.githubusercontent.com/alkorolyov/vast-tools/main/gpu_test_run.py; python3 gpu_test_run.py```

