#!/bin/bash
# By ambalex 12/11/2013
# Based on the bashpodder script by Linc http://lincgeek.org/bashpodder (Revision 1.21 12/04/2008 - Many Contributers!)

# Colors for the output
BLUE='\033[00;34m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
NC='\033[0m'

# Make script crontab friendly:
cd $(dirname $0)

# datadir is the directory you want podcasts saved to, create datadir if necessary:
datadir=$(date +%Y-%m-%d_%H-%M)
mkdir -p $datadir

# Delete any temp_vc file:
rm -f temp_vc.log

# Read the $1 file and wget any url not already in the vodcast.log file, and rename the downloaded file:
countlines=1
while read vodcast
	do
		rem=$(( $countlines % 2 ))
		if [ $rem -eq 1 ]; then
		vodname=$vodcast
		echo -e "${YELLOW}$vodname${NC}"
		else
		file=$(xsltproc parse_enclosure.xsl $vodcast 2> /dev/null || wget -q $vodcast -O - | tr '\r' '\n' | tr \' \" | sed -n 's/.*url="\([^"]*\)".*/\1/p')
			for url in $file
				do
				echo $url >> temp_vc.log
				if [ "$2"!="no-download" ]
					then
					if ! grep "$url" vodcast.log > /dev/null
						then
						wget -q "$url" -O video.mp4
						poddate=$(stat -c "%y" "video.mp4"|awk '{print $1"_"$2}'|sed 's/\..*$//'|sed 's/:/-/'|sed 's/:/-/')
						extmp4=.mp4
						seprdr=_
						newname=$vodname$seprdr$poddate$extmp4
						echo -e "${GREEN}\t$newname${NC}"
						cp video.mp4 output.mp4
						mv output.mp4 "$datadir/$newname"
					fi
				fi
				done
		fi
		countlines=$(expr $countlines + 1)
	done < $1

# Move dynamically created log file to permanent log file:
cat vodcast.log >> temp_vc.log
sort temp_vc.log | uniq > vodcast.log
rm temp_vc.log

# clean intermediate files
rm -f video.mp4
