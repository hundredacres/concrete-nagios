#!/bin/bash

# Quick script to test if reboot required on systems.
# Justin 15/10/2014

if [ ! -f /var/run/reboot-required ]; then
        # no reboot is needed
        echo "OK: no reboot required on this system"
        exit 0
else
        # a reboot required
        echo "WARNING: $(cat /var/run/reboot-required*)"
        exit 1
fi


