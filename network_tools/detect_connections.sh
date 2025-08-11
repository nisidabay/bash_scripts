#!//bin/bash

netstat -anp | grep -i "established" | \
grep -v "127.0.0.1" | \
awk '{print $5}' | \
cut -d: -f1 | sort | uniq -c | \
sort -nr

# Why It Is Useful:

# The script is useful for cybersecurity practitioners, particularly those on a Blue Team, which is responsible for defending an organization's information systems. By running this script, they can:

# Quickly identify which external IP addresses have the most connections to the system.
# Detect potential security threats, like if an IP address has an unusually high number of connections, which could suggest a scanning attack or unauthorized access.
# Assess the current state of network connections to help with incident response or ongoing network analysis.
