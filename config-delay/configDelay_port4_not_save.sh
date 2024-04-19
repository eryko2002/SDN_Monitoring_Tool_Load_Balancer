#!/bin/bash

eth_out=s1-eth4

tc qdisc del dev $eth_out root

tc qdisc add dev $eth_out root netem delay $1

