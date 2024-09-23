#!/bin/bash

# console colors
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

# globals
#=============================================================================
USING_SSH=false
USING_NFS_MOUNT=false
LOGGING_ENABLED=false

# notes on rsync switches:
# -a: "archive mode", equivalent to -rlptgoD

# -n: dry-run
# -v: increase verbosity
# -hh: human readable output
# --delete: delete extraneous files for destination directory

# -r: recursive
# -p: preserve permissions
# -o: preserve owner
# -g: preserve group
# -l: preserve symbolic links
# -t: preserve modification times

# --omit-dir-times: neccessary if rsyncing to locally mounted NFS share

RSYNC_DRYRUN_OPTS="-avn --delete"
RSYNC_OPTS="-ahhh --delete --info=progress2"

BACKUP_FILENAME="backup.log"

function main() {

	if [[ "$USING_NFS_MOUNT" = true ]]; then
		RSYNC_OPTS="-ahhh --omit-dir-times --delete --info=progress2"
	fi

	check_args "$@"
	check_dirs "$@"
    test_rsync "$@"
    confirm_execute_rsync "$@"
    execute_rsync "$@"
}

function check_args() {
    
    if [[ "$#" -lt 2 ]]; then
		echo -e "${RED}error: this script must be run with minimum of two paths: source and backup.${NC}"
		echo ""
		print_help
		exit 1
    fi
}

function print_help() {

    echo -e "usage: $0 [-h] [-a] [-l] [{source path 1}, {source path 2}, ... ] {backup path}"
	echo "-h: display this help message"
	echo "-a: enable rsync archive mode (note: do not use this for mounted NFS shares)"
	echo "-l: create a backup.log file at root of backup path"
	echo ""
	echo "example #1: use rsync in archive mode to backup to external HD and create a log file"
	echo "rsync_helper.sh -a -l ~/Documents ~/Downloads ~/Music /run/media/robert/Iron_Wolf"
	echo ""
	echo "example #2: use rsync to backup to a mounted NFSv4 share"
	echo "rsync_helper.sh ~/Music ~/TrueNAS/media"
	echo ""
	echo "example #3: use rsync over ssh to backup another host and create a log file"
	echo "rsync_helper.sh -l ~/Games/SteamDeck/retrodeck/roms ~/Games/SteamDeck/retrodeck/bios deck@steamdeck:/home/deck/retrodeck"
}

function check_dirs() {

	echo "checking source directories..."

	local src_array=("$@")
	local trgt_root=${src_array[-1]}
	unset src_array[-1]

	local i=1
	for src in "${src_array[@]}"
	do
		check_dir_exists $i $src

		i=$(($i + 1))
	done

	echo "checking target directories..."

	i=1
	for src in "${src_array[@]}"
	do
		local trgt="$trgt_root/$(basename $src)"

		if [[ "$USING_SSH" = true ]]; then
			echo -e "${YELLOW}$i: $trgt -- using ssh, unable to check target directory${NC}"
		else
			check_dir_exists $i $trgt
		fi

		i=$(($i + 1))
	done
}

function check_dir_exists() {

	if [[ ! -d "$2" ]]; then
        echo -e "${RED}$1: $2 does not exist!${NC}"
        exit 1
	else
		echo -e "${GREEN}$1: $2 exists.${NC}"
    fi
}

function test_rsync() {

	echo "dry-run of rsync routines:"

	local src_array=("$@")
	local trgt_root=${src_array[-1]}
	unset src_array[-1]

	local i=1
	for src in "${src_array[@]}"
	do
		local trgt="$trgt_root/$(basename $src)"
		local rsync_src="$src/"
		local rsync_trgt="$trgt/."

		echo "${i}: $rsync_src --> $rsync_trgt"
		echo "---------------------------"
		echo "files that will be deleted:"
		echo -e "---------------------------${RED}"

		rsync $RSYNC_DRYRUN_OPTS $rsync_src $rsync_trgt | grep "deleting"
			
		echo -e "${NC}"

		i=$(($i + 1))
	done
}

function confirm_execute_rsync() {

	echo -e "${RED}warning you are about to execute rsync for following locations"'!'":${NC}"

	local src_array=("$@")
	local trgt_root=${src_array[-1]}
	unset src_array[-1]

	local i=1
	for src in "${src_array[@]}"
	do
		local trgt="$trgt_root/$(basename $src)"
		local rsync_src="$src/"
		local rsync_trgt="$trgt/."

		echo "${i}: $rsync_src --> $rsync_trgt"

		i=$(($i + 1))
	done

	echo ""
	read -p "do you want to continue? [y/N] " yn
	case $yn in
		[Yy]* )
			;;
		[Nn]* )
			exit
			;;
		* )
			exit
			;;
	esac
	echo ""
}

function execute_rsync() {

	local src_array=("$@")
	local trgt_root=${src_array[-1]}
	unset src_array[-1]

	if [[ "$LOGGING_ENABLED" = true && -e ${trgt_root}/${BACKUP_FILENAME} ]]; then
    	rm ${trgt_root}/${BACKUP_FILENAME}
	fi
	
	local start_date=$(date)
	echo_and_log $start_date $trgt_root
	echo_and_log "executing rsync routines:" $trgt_root

	local i=1
	for src in "${src_array[@]}"
	do
		local trgt="$trgt_root/$(basename $src)"
		local rsync_src="$src/"
		local rsync_trgt="$trgt/."

		echo_and_log "${i}: $rsync_src --> $rsync_trgt" $trgt_root

		rsync $RSYNC_OPTS $rsync_src $rsync_trgt

		i=$(($i + 1))
	done

	local end_date=$(date)
	echo_and_log $end_date $trgt_root
	echo_and_log "completed rsync routines." $trgt_root
}

function echo_and_log() {

	local echo_array=("$@")
	local trgt_root=${echo_array[-1]}
	unset echo_array[-1]

    echo "${echo_array[@]}"

	if [[ "$LOGGING_ENABLED" = true ]]; then
    	echo "${echo_array[@]}" >> ${trgt_root}/${BACKUP_FILENAME}
	fi
}

# get the options that are passed in (e.g. -h)
while getopts ":hsnl" option; do
  case $option in
    h) print_help; exit ;;
    s) USING_SSH=true; echo "using rsync over SSH"; ;;
    n) USING_NFS_MOUNT=true; echo "using rsync with locally mounted NFS share"; ;;
	l) LOGGING_ENABLED=true echo "logging is enabled"; ;;
    ?) echo "error: option -$OPTARG is not implemented"; exit ;;
  esac
done

# remove the options from the positional parameters
shift $(( OPTIND - 1 ))

main "$@"