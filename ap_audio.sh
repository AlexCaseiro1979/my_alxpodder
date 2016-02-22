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

# if the program is called to clean a previous run which went wrong:
if [ "$1" = "clean" ]; then
	cat podcast.log >> temp_pc.log ; sort temp_pc.log | uniq > podcast.log ; rm temp_pc.log
	rm audio.mp3

else

# write the parse_enclosure2.xsl file

cat > parse_enclosure2.xsl << _EOF_
<?xml version="1.0"?>
<stylesheet version="1.0"
    xmlns="http://www.w3.org/1999/XSL/Transform">
    <output method="text"/>
    <template match="/">
        <apply-templates select="/rss/channel/item/enclosure"/>
    </template>
    <template match="enclosure">
        <value-of select="@url"/><text>&#10;</text>
    </template>
</stylesheet>
_EOF_

# datadir is the directory you want podcasts saved to, create datadir if necessary:
datadir=$(date +%Y-%m-%d_%H-%M)
mkdir -p $datadir

# Delete any temp_pc file:
rm -f temp_pc.log

# Read the $1 file and wget any url not already in the podcast.log file, and rename the downloaded file:
countlines=1
while read podcast
	do
		rem=$(( $countlines % 2 ))
		if [ $rem -eq 1 ]; then
		podname=$podcast
		echo -e "${YELLOW}$podname${NC}"
		else
		file=$(xsltproc parse_enclosure2.xsl $podcast 2> /dev/null || wget -q $podcast -O - | tr '\r' '\n' | tr \' \" | sed -n 's/.*url="\([^"]*\)".*/\1/p')
			for url in $file
				do
				echo $url >> temp_pc.log
				if [ "$2" != "no-download" ]
					then
					if ! grep "$url" podcast.log > /dev/null
						then
						#echo -e "${GREEN}\t$url${NC}"
						wget -q "$url" -O audio.mp3
						poddate=$(stat -c "%y" "audio.mp3"|awk '{print $1"_"$2}'|sed 's/\..*$//'|sed 's/:/-/'|sed 's/:/-/')
						extmp3=.mp3
						seprdr=_
						newname=$podname$seprdr$poddate$extmp3
						n=1
						while [ -f $(pwd)/$datadir/$newname  ]
							do
							newname=$podname$seprdr$poddate$n$extmp3
							n=$(expr $n + 1)
							done
						echo -e "${GREEN}\t$newname${NC}"
						mv "$(pwd)/audio.mp3" "$(pwd)/$datadir/$newname"
					fi
				fi
				done
		fi
		countlines=$(expr $countlines + 1)
	done < $1

# Move dynamically created log file to permanent log file:
cat podcast.log >> temp_pc.log
sort temp_pc.log | uniq > podcast.log
rm temp_pc.log parse_enclosure2.xsl

fi
