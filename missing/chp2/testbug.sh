#!/bin/bash

	count=0
	while true
	do
		./buggy.sh &> testbug.log

		if [[ $? -ne 0 ]]; then
			cat testbug.log
			echo "The program ran $count times and went wrong"
			break
		fi
		((count++))

	done
