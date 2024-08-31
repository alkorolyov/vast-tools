#!/usr/bin/env bash
pip install gdown==v4.6.0																									
export PATH=$PATH:$HOME/.local/bin
gdown --id 16XOUHmXUr2ckwAunKK01wMsHzB6xEIsx --output ipmicfg																									
sudo chmod +x ipmicfg
