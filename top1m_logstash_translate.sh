#!/bin/bash
# 
# Script requires wget and zip to be installed
FOLDER=/usr/share/logstash/data/translate/alexa
mkdir -p $FOLDER
rm -f $FOLDER/*
cd $FOLDER
wget http://s3.amazonaws.com/alexa-static/top-1m.csv.zip -O $FOLDER/top-1m.csv.zip
unzip $FOLDER/top-1m.csv.zip
awk -F, '{print $2,$1}' OFS=, $FOLDER/top-1m.csv > $FOLDER/alexa.csv
rm -f $FOLDER/top-1m.csv.zip
rm -f $FOLDER/top-1m.csv
chmod 644 $FOLDER/*
