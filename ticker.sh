#!/bin/bash
if [ "$1" = "" ]
then
  echo "Example use: ./ticker.sh AAPL"
  exit 1
fi
curl terminal-stocks.dev/$1
