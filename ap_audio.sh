#!/bin/bash
# By ambalex, latest development 23/08/2023
# Based on the bashpodder script by Linc http://lincgeek.org/bashpodder (Revision 1.21 12/04/2008 - Many Contributers!)

# Colors for the output
BLUE='\033[00;34m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
NC='\033[0m'

# Make script crontab friendly:
cd $(dirname $0)

# Some strings
extm3u=.m3u
extmp3=.mp3
seprdr=_

# backup podcast.log
cp podcast.log podcast.log.backup

# if the program is called to clean a previous run which went wrong:
if [[ "$1" = "clean" ]]; then
cat podcast.log >> temp_pc.log ; sort temp_pc.log | uniq > podcast.log ; rm temp_pc.log
rm audio.mp3

else

# datadir is the directory you want podcasts saved to
datadir=$(date +%Y-%m-%d_%H-%M)
mkdir -p $datadir

# Delete any leftover temp_pc file:
rm -f temp_pc.log

# Read the $1 file and wget any url not already in the podcast.log file
# and rename the downloaded file:
countlines=1
while read xml_url; do
  rem=$(( $countlines % 2 ))

  if [ $rem -eq 1 ]; then
    podname=$xml_url
    echo -e "${YELLOW}$podname${NC}"

  else
    podcast=$(wget -qO - "$xml_url")
    #file="$(xsltproc parse_enclosure2.xsl $podcast 2> /dev/null || wget -q $podcast -O - | tr '\r' '\n' | tr \' \" | sed -n 's/.*url="\([^"]*\)".*/\1/p')"
	#mp3_links=($(echo "$podcast" | grep '\.mp3"' | awk -F "\"" '{print $2}' ))
	mp3_links=($(echo "$podcast" | grep '\.mp3' | awk -F "\"" '{print $2}' ))

    #for url in $file; do
	for url in "${mp3_links[@]}"; do
      echo "$url" >> temp_pc.log
      if [[ "$2" != "no-download" ]]; then
        if ! grep "$url" podcast.log > /dev/null; then

      	  if [[ "$2" == "list" ]]; then
            echo "$url" >> $datadir$extm3u
          fi

  	  if [[ "$2" != "list" ]]; then
            wget -q --no-check-certificate "$url" -O audio.mp3
            poddate="$(stat -c "%y" "audio.mp3"|awk '{print $1"_"$2}'|sed 's/\..*$//'|sed 's/:/-/'|sed 's/:/-/')"
            newname=$podname$seprdr$poddate$extmp3
            n=1

            while [[ -f $(pwd)/$datadir/$newname ]]; do
              newname=$podname$seprdr$poddate$n$extmp3
              n=$(expr $n + 1)
            done

            if [ \! -s audio.mp3 ];then
              rm "$(pwd)/audio.mp3"
            else
              echo -e "${GREEN}\t$newname${NC}"
              mv "$(pwd)/audio.mp3" "$(pwd)/$datadir/$newname"
            fi

          fi

        fi
      fi
    done
  fi
  countlines=$(expr $countlines + 1)
done < $1

# If we just want a list
if [ "$2" = "list" ]; then
rmdir "$(pwd)/$datadir/"
fi

# Move dynamically created log file to permanent log file:
cat podcast.log >> temp_pc.log
sort temp_pc.log | uniq > podcast.log
rm temp_pc.log

fi
