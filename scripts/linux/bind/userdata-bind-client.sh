#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for set environment for labs
    Author: Marcos Silvestrini
    Date: 14/02/2023
MULTILINE-COMMENT

export LANG=C

cd /home/vagrant || exit

# Install packages
dnf install -y bind-utils
