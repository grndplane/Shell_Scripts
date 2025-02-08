#! /bin/bash
#
# Plex DVR Postprocessing
# Version 0.0.1
# twitter.com/thatvirtualboy
# www.thatvirtualboy.com
# Mike Edwards changed from Apple to Intel Quick Sync Video encoding.

# TRANSCODE AND COMPRESS

lockFile='/tmp/dvrProcessing.lock'
inFile="$1"
tmpFile="$1.mp4"
dvrPostLog='/tmp/dvrProcessing.log'
time=`date '+%Y-%m-%d %H:%M:%S'`
handbrake=/usr/bin/HandBrakeCLI

echo "'$time' Plex DVR Postprocessing script started" | tee $dvrPostLog

# Check if post processing is already running
while [ -f $lockFile ]
do
    echo "'$time' $lockFile' exists, sleeping processing of '$inFile'" | tee -a $dvrPostLog
    sleep 10
done

# Create lock file to prevent other post-processing from running simultaneously
echo "'$time' Creating lock file for processing '$inFile'" | tee -a $dvrPostLog
touch $lockFile

# Encode file to MP4 with handbrake-cli
echo "'$time' Transcoding started on '$inFile'" | tee -a $dvrPostLog

# $handbrake -i "$inFile" -o "$tmpFile" --preset="Apple 1080p30 Surround" --encoder-preset="veryfast" -O
$handbrake -i "$inFile" -o "$tmpFile" --preset="Fast 1080p30" --encoder-preset="slow" -O

# Overwrite original ts file with the transcoded file
echo "'$time' File rename started" | tee -a $dvrPostLog
mv -f "$tmpFile" "$inFile"

#Remove lock file
echo "'$time' All done! Removing lock for '$inFile'" | tee -a $dvrPostLog
rm $lockFile

exit 0
