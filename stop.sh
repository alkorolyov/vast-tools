#!/bin/bash
sudo systemctl stop docker.socket
sudo systemctl stop docker.service
sudo systemctl stop vastai_bouncer.service
sudo systemctl stop vastai.service
