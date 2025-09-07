#!/bin/bash

marco(){
	echo "$(pwd)" > $HOME/marco_history.log
	echo "Save pwd $(pwd)"
}

polo(){
	cd "$(cat "$HOME/marco_history.log")"
}


