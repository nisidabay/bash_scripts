#!/bin/bash

# Check for suspicious network activity
# Check for any established TCP connections

sudo netstat -tn | awk '$6 == "ESTABLISHED" {print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr

# Why It Is Useful:

# The script is useful for system administrators who need to monitor network
# connections for unusual or unexpected activity. By identifying IP addresses with
# numerous established connections, it can help pinpoint potential security
# threats, like network scans or DDoS attacks. The sorted list of IP addresses,
# along with the count of connections for each, can be used for further
# investigation or as input for security tools and firewalls.

