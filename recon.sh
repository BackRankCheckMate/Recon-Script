#!/bin/bash
DOMAIN=$1
DIRECTORY=${DOMAIN}_recon
echo "Creating directory $DIRECTORY"
mkdir $DIRECTORY

nmap_scan()
{
	nmap $DOMAIN > $DIRECTORY/nmap
	echo "The results of the nmap scan are stored in $DIRECTORY/nmap"
}

gobuster_scan()
{
	gobuster dir -u $DOMAIN -w /usr/share/dirb/wordlists/big.txt > $DIRECTORY/gobuster_scans
	echo "The results of the bruteforce scan are stored in $DIRECTORY/gobuster_scans"
}

crt_scan()
{
	curl "https://crt.sh/?1=$DOMAIN&output=json" -o $DIRECTORY/crt
	echo "The results of cert parsing is stored in $DIRECTORY/crt"
}

case $2 in 
	nmap-only)
		nmap_scan
		;;
	dirsearch-only)
		gobuster_scan
		;;
	crt-only)
		crt_scan
		;;
	*)
		nmap_scan
		gobuster_scan
		crt_scan
		;;
esac

echo "Generating recon report from output files..."
TODAY=$(date)
echo "This scan was created on $TODAY" > $DIRECTORY/report
echo "Results for nmap:" >> $DIRECTORY/report
grep -E "^\s*\S+\s+\S+\s+\S+\s*$" $DIRECTORY/nmap >> $DIRECTORY/report
echo "Results of Gobuster:" >> $DIRECTORY/report
cat $DIRECTORY/gobuster_scans >> $DIRECTORY/report
echo "Results for crt.sh:" >> $DIRECTORY/report
jq -r ".[] | .name_value" $DIRECTORY/crt >> $DIRECTORY/report
