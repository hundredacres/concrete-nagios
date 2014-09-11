#!/bin/bash
#This is going to need permission restart the ntp service. Need sudo?

/etc/init.d/ntp stop
ntpd -q
/etc/init.d/ntp start