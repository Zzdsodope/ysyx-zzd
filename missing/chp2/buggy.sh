#!/bin/bash

	n=$((RANDOM % 100))

	if [[ n -eq 19 ]]; then
		echo "Something went wrong"
		>&2 echo "The error was using magic number"
		exit 1
	fi

	echo "Everything is fine"

