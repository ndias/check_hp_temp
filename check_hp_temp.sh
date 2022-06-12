#!/bin/bash

# Check the "Ambient Zone" Temperature of a HP using ipmi
# Nuno.Dias@gmail.com 2021/02/22

function usage {

  echo "Usage: $0 -H hostname -U Username -P password -w warning -c critical"
  exit 0
}

function isnumber {

  case $OPTARG in
    [!0-9]* ) echo "Error: -$opt must be an Integer"
              usage;;
  esac

}

while getopts "H:U:P:w:c:" opt; do
  case $opt in
    H) THEHOST=$OPTARG;;
    U) THEUSER=$OPTARG;;
    P) PASS=$OPTARG;;
    w) isnumber
       WARN=$OPTARG;;
    c) isnumber
       CRIT=$OPTARG;;
    *) usage;;
   esac
done

if [ -z "$THEHOST" ] || [ -z "$THEUSER" ] || [ -z "$PASS" ] || [ -z "$WARN" ] || [ -z "$CRIT" ]; then
  echo "Error: Required option not found"
  usage
fi

if [ "$WARN" -gt "$CRIT" ]; then
  echo "Error: -c must be higher than -w"
  usage
fi

TEMP=$(ipmitool -H "$THEHOST" -I lanplus -U "$THEUSER" -P "$PASS" sensor  | grep "Temp 2" | cut -d"|" -f2 | tail -1 | tr -d " "| cut -d"." -f1)

if [ $? -eq 0 ]; then
  if [ "$TEMP" -ge "$CRIT" ]; then
    echo "CRITICAL Temp: ${TEMP} C"
    exit 2
  elif [ "$TEMP" -ge "$WARN" ] && [ "$TEMP" -lt "$CRIT" ]; then
    echo "Warning: ${TEMP} C"
    exit 1
  else
    echo "OK: ${TEMP} C"
    exit 0
  fi 
fi
