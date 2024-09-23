#!/bin/bash

# Console Colors
#=============================================================================
NC='\033[0m'

RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'

LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'
#=============================================================================

function main() {
	
	check_args "$@"

    umount_nas_nfs_shares "$@"
}

function check_args() {
    
    if [[ "$#" -lt 1 ]]; then
		echo -e "${RED}Error: this script must be run with at least one arguments.${NC}"
		echo ""
		print_help
		exit 1
    fi
}

function print_help() {

    echo -e "${LBLUE}Usage: "$0" [{mount point 1, mount point 2, ...}]${NC}"
}

function umount_nas_nfs_shares() {

	local arg_array=("$@")

	local i=1
	for full_mount_point in "${arg_array[@]}"
	do
        echo "${i}: Unmounting $full_mount_point"
        sudo umount $full_mount_point

		i=$(($i + 1))
	done
}

main "$@"