#!/bin/bash

echo -e "What ip address you want to load balance?\n1. 10.0.0.4\n2. 10.0.0.5\n3. 10.0.0.6\n"
read -p "Select 1,2 or 3: " host


echo -e "\nLink: s1-s2 <=> output_port: 4\nLink: s1-s3 <=> output_port: 5\nLink: s1-s4 <=> output_port: 6\n"
read -p "Select 4,5,6 output numbers that refer to links used for load-balancing: " port_list

IFS=' ' read -r -a OUTPUT_PORTS <<< "$port_list"


while true; do
    dest_block=""
    case $host in
    	1) dest_block=4;;
	2) dest_block=5;;
 	3) dest_block=6;;
	*) echo "Invalid output!Please enter 1,2 or 3";;
    esac

    index=$(( (index + 1) % ${#OUTPUT_PORTS[@]} ))
    OUTPUT_PORT=${OUTPUT_PORTS[index]}

    sudo ovs-ofctl mod-flows s1 priority=100,ip,nw_dst=10.0.0.$dest_block,actions=output:$OUTPUT_PORT
    

    echo "Dumping flow entry for destination address 10.0.0.$dest_block:"
    sudo ovs-ofctl dump-flows s1 | grep "nw_dst=10.0.0.$dest_block"

    sleep 1
done

