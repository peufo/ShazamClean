#!/bin/bash

TIMESTAMP=$(date +"%Y-%m-%d_%H:%M:%S")
INPUT_FILE="cleaning_list.txt"
LOGS_FOLDER="logs"
LOGFILE="$LOGS_FOLDER/cleaning_log_$TIMESTAMP.log"

abort(){
	echo "ABORTED" >> "$LOGFILE"
	exit 1
}

log_size(){
	if [ "$#" -ne 2 ]; then
		echo "Error: log_size expected 2 arguments: got $#: aborting" >&2
		abort
	fi
	local dir_name=$1
	local dir_size=$2
	echo -e "$dir_size\t$dir_name" >> "$LOGFILE"
}

delete_directory_contents(){
	if [ "$#" -ne 1 ]; then
		echo "Error: delete_directory_contents expected 1 argument: got $#: aborting" >&2
		abort
	fi
	local dir=$1
	rm -rf "$dir"/* "$dir"/.* 2>/dev/null
}

process_directory(){
	if [ "$#" -ne 1 ]; then
		echo "Error: process_directory expected 1 argument: got $#: aborting" >&2
		abort
	fi
	local dir=$1
	local size
	if [ ! -d "$dir" ]; then
		size="---"
	else
		size=$(du -sh "$dir" | awk '{print $1}')
		delete_directory_contents "$dir"
	fi
	log_size "$dir" "$size"
}

process_directories_from_file(){
	if [ "$#" -ne 1 ]; then
		echo "Error: process_directories_from_file expected 1 argument: got $#: aborting" >&2
		abort
	fi
	local file=$1
	if [ ! -f "$file" ] || [ ! -r "$file" ]; then
		echo "Error: input file "$file" does not exist or cannot be read: aborting" >&2
		abort
	fi
	while IFS= read -r dir || [ -n "$dir" ]; do
		if [ -z "$dir" ]; then
			continue
		fi
		process_directory "$dir"
	done < "$file"
}

#main script
mkdir -p $LOGS_FOLDER
process_directories_from_file "$INPUT_FILE"
echo "Processing complete. Logs written to '$LOGFILE'"
