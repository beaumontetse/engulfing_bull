While true
  curl terminal-stocks.dev/MSFT | ./cleanfile.sh | grep -Ein "" | head -6 | tail -1 | awk '{print $5}' | sed -r "s/.([0-9.,]*)/\1/g" >> msft_prices_onemin # set name of price file here
  Sleep 60 # grab price every minute
