#!/bin/bash


getStats() {



four=$(sudo ovs-ofctl dump-ports s1 4 | tail -n 1 | awk -F ',' '{print $2}' | awk -F '=' '{print $2}')

five=$(sudo ovs-ofctl dump-ports s1 5 | tail -n 1 | awk -F ',' '{print $2}' | awk -F '=' '{print $2}')

six=$(sudo ovs-ofctl dump-ports s1 6 | tail -n 1 | awk -F ',' '{print $2}' | awk -F '=' '{print $2}')

echo -e "\nTraffic transition per second in bytes:\nLink s1-s2:$four\nLink s1-s3:$five\nLink s1-s4:$six"
}

while true; do
	getStats
	sleep 1
done

