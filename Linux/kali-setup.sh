#!/bin/bash
sed -i '9 s/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=hyperv_fb:1920x1080"/' /etc/default/grub
sudo update-grub