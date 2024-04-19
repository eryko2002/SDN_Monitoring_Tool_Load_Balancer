#!/bin/bash


echo -e "What IP address do you want to load balance?\n1. 10.0.0.4\n2. 10.0.0.5\n3. 10.0.0.6\n"
read -p "Select 1, 2, or 3: " host

if [ $host -eq "1" ]; then
	echo -e "\nMonitoring of destination host 10.0.0.4"
elif [ $host -eq "3" ]; then
	echo -e "\nMonitoring of destination host 10.0.0.6"
elif [ $host -eq "2" ]; then
	echo -e "\nMonitoring of destination host 10.0.0.5"
else
	echo -e "\nNo destination address was selected!"
fi

getCurrentOutputPort() {
        #print $8 if you created ping in bash, print $9 if you passed ping from mininet
	local output=$(sudo ovs-ofctl dump-flows s1 | grep nw_dst=10.0.0.$dest_block | grep 'output:' | awk '{print $8}' | awk -F ':' '{print $2}')
	echo "$output"
}
getByteCount() {
    local value=$(sudo ovs-ofctl dump-ports s1 $1 | tail -n 1 | awk -F ',' '{print $2}' | awk -F '=' '{print $2}')
    echo "$value"
}

loadBalancer() {
        OUTPUT_PORTS=(4 5 6)
	#index=$(( (index + 1) % ${#OUTPUT_PORTS[@]} ))
	index=0
	OUTPUT_PORT=${OUTPUT_PORTS[index]}
	sudo ovs-ofctl mod-flows s1 priority=100,ip,nw_dst=10.0.0.$dest_block,actions=output:$OUTPUT_PORT

	echo "Dumping flow entry for destination address 10.0.0.$dest_block:"
        sudo ovs-ofctl dump-flows s1 | grep "nw_dst=10.0.0.$dest_block"
	sleep 0.3
	#index=$(( (index + 1) % ${#OUTPUT_PORTS[@]} ))
	index=1
	OUTPUT_PORT=${OUTPUT_PORTS[index]}
        sudo ovs-ofctl mod-flows s1 priority=100,ip,nw_dst=10.0.0.$dest_block,actions=output:$OUTPUT_PORT

	echo "Dumping flow entry for destination address 10.0.0.$dest_block:"
	sudo ovs-ofctl dump-flows s1 | grep "nw_dst=10.0.0.$dest_block"
	sleep 0.3
	index=2
        OUTPUT_PORT=${OUTPUT_PORTS[index]}
        sudo ovs-ofctl mod-flows s1 priority=100,ip,nw_dst=10.0.0.$dest_block,actions=output:$OUTPUT_PORT

        echo "Dumping flow entry for destination address 10.0.0.$dest_block:"
        sudo ovs-ofctl dump-flows s1 | grep "nw_dst=10.0.0.$dest_block"
}


while true; do
	dest_block=""
	case $host in
	1) dest_block=4;;
	2) dest_block=5;;
	3) dest_block=6;;
	*) echo "Invalid output!Please enter 1,2 or 3";;
	esac

   # bytes=$(getByteCount "$(getCurrentOutputPort)")
    prev_bytes=$(getByteCount "$(getCurrentOutputPort)")
    #echo -e "\nPrevBytes:$prev_bytes"
    sleep 1
    bytes=$(getByteCount "$(getCurrentOutputPort)") 
    bytes_per_second=$((bytes - prev_bytes))
    #echo -e "\nBytes:$bytes"
    #echo -e "\nBytesPerSecond:$speed"
    threshold=3800  # Adjust the threshold as needed
    if [ "$bytes_per_second" -gt "$threshold" ] && [ "$bytes_per_second" -lt "10000" ]; then
        echo -e "\nHigh traffic detected on the specified link => bytes_per_second $bytes_per_second > $threshold\nPerforming load balancing..." 
        loadBalancer
    fi
    if [ "$bytes_per_second" -eq "0" ]; then
        #echo -e "\nTraffic on the specified link is within normal range."
	echo -e "\nNo traffic is being sent within this second..."
    else
	echo -e "\nTraffic on the specified link is within normal range => bytes_per_second $bytes_per_second"

    fi
done
