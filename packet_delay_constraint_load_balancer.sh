#!/bin/bash




echo -e "What IP address do you want to load balance?\n1. 10.0.0.4\n2. 10.0.0.5\n3. 10.0.0.6\n"
read -p "Select 1, 2, or 3: " host

if [ $host -eq "1" ]; then
	echo -e "\nMonitoring of destination host 10.0.0.4"
elif [ $host -eq "2" ]; then
	echo -e "\nMonitoring of destination host 10.0.0.5"
elif [ $host -eq "3" ]; then
	echo -e "\nMonitoring of destination host 10.0.0.6"
else
	echo -e "\nNo destination address was selected!"
fi

getCurrentOutputPort() {
	local output=$(sudo ovs-ofctl dump-flows s1 | grep nw_dst=10.0.0.$dest_block | grep 'output:' | awk '{print $8}' | awk -F ':' '{print $2}')
	echo "$output"
}


getCurrentDelay(){
        list=(4 5 6)
        active_outputs=()
        threshold_delay=60
        for digit in ${list[@]}; do
                value="$(tc qdisc show dev s1-eth$digit | grep -oP 'delay \K\d+\.\d+' | awk '{printf "%.0f", $1}')"
                if [ $value -le $threshold_delay ]; then
                        active_outputs+=("$digit")
                fi
        done
        echo ${active_outputs[@]}
}



loadBalancer() {
	OUTPUT_PORTS=$(getCurrentDelay)
	time=0
	while [ $time -le 10 ]; do
		for output in ${OUTPUT_PORTS[@]}; do
			sudo ovs-ofctl mod-flows s1 priority=100,ip,nw_dst=10.0.0.$dest_block,actions=output:$output
			time=$((time + 1))
			sleep 0.1
		done
	done
}



while true; do
   dest_block=""
	case $host in
	1) dest_block=4;;
	2) dest_block=5;;
	3) dest_block=6;;
	*) echo "Invalid output!Please enter 1,2 or 3";;
	esac
    sleep 1
    current_delay=$(cat $(sudo find /home/student/ -type f -name "getCurrentDelay.txt"))
    threshold_delay=59  # Adjust the threshold as needed
    if [ "$current_delay" -gt "$threshold_delay" ]; then
        echo -e "\nHigh delay  detected on the specified link => current_delay=$current_delay>$threshold_delay" 
        loadBalancer
    else
	echo -e "\nDelay is acceptable => current_delay=$current_delay "

    fi
done
