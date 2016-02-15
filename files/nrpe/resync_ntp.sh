#!/bin/bash
#This is going to need permission restart the ntp service. Need sudo?

sudo /etc/init.d/ntp stop
sudo ntpd -q
sudo /etc/init.d/ntp start