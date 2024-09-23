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
	check_mount_point_root "$@"

    mount_nas_nfs_shares "$@"
}

function check_args() {
    
    if [[ "$#" -lt 3 ]]; then
		echo -e "${RED}Error: this script must be run with at least three arguments.${NC}"
		echo ""
		print_help
		exit 1
    fi
}

function print_help() {

    echo -e "${LBLUE}Usage: "$0" {NAS hostname or IP} [{NFS path 1, NFS path 2, ...}] {path to mount point root}${NC}"
}

function check_mount_point_root() {

    local arg_array=("$@")
    local mount_point_root=${arg_array[-1]}
	
    if [[ ! -d "$mount_point_root" ]]; then
        echo "Creating mount point root: $mount_point_root"
        mkdir -p $mount_point_root
    fi
}

function mount_nas_nfs_shares() {

	local arg_array=("$@")
	local nas_ip=${arg_array[0]}
    local mount_point_root=${arg_array[-1]}
	unset arg_array[0]
    unset arg_array[-1]

	echo "Mounting NFS shares from NAS: $nas_ip"
    echo "Mount point root: $mount_point_root"

	local i=1
	for nfs_path in "${arg_array[@]}"
	do
		local full_mount_point="$mount_point_root/$(basename $nfs_path)"

		if [[ ! -d "$full_mount_point" ]]; then
			echo "${i}: Creating mount point: $full_mount_point"
			mkdir -p $full_mount_point
		fi
        
        echo "${i}: Mounting ${nas_ip}:${nfs_path} -> $full_mount_point"
        sudo mount -t nfs4 ${nas_ip}:${nfs_path} $full_mount_point

		i=$(($i + 1))
	done
}

main "$@"