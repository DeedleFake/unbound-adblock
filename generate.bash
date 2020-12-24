#!/usr/bin/env bash

# Usage: generate.bash [output]
#
# Creates an Unbound config file with a list of blocked domains
# generated from the files at the URLs listed below. Files are
# expected to be in a hosts-style format with blocked domains mapped
# to 0.0.0.0.
#
# Default output is a file in the same directory as the script called
# adblock.conf.

lists=(
	https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
)

set -eo pipefail

output="$1"
if [ -z "$output" ]; then
	output="$(dirname "$BASH_SOURCE")/adblock.conf"
fi

generate() {
	echo "server:"
	for list in "${lists[@]}"; do
		domains="$(curl -s "$list" | grep '^0\.0\.0\.0' | grep -v '^0\.0\.0\.0\s0\.0\.0\.0$' | awk '{print $2}')"
		for domain in $domains; do
			echo "  local-zone: \"$domain\" always_nxdomain"
		done
	done
}

generate > "$output"
