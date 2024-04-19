#!/bin/bash


eth_out=s1-eth5

tc qdisc del dev $eth_out root

tc qdisc add dev $eth_out root netem delay $1

output=$(tc qdisc show dev $eth_out)
delay_value=$(echo "$output" | grep -oP 'delay \K\d+\.\d+' | awk '{printf "%.0f", $1}')
echo -e "$delay_value" > getCurrentDelay.txt

