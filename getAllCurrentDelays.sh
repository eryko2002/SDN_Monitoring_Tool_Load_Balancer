#!/bin/bash


getCurrentDelay(){
        list=(4 5 6)
        for digit in ${list[@]}; do
                value="$(tc qdisc show dev s1-eth$digit | grep -oP 'delay \K\d+\.\d+' | awk '{printf "%.0f", $1}')"
                echo -e "\nDelay of s1-eth$digit : $value ms";
        done

}

while true; do
	getCurrentDelay
	echo -e "\n-----------------------------------------"
	sleep 1
done


exit 0
