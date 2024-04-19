#!/bin/bash

destination="10.0.0.5"  # Destination IP address for ping
interval=0.1  # Interval between pings in seconds

while true; do
    # Generate random packet size between 64 and 1500 bytes
    packet_size=$(( ( RANDOM % 1436 ) + 64 ))
    
    echo "Sending ping with packet size: $packet_size bytes"
    
    # Send ping with specified packet size
    ping -c 1 -s $packet_size $destination
    
    sleep $interval  # Wait for the next iteration
done

