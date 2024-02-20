#!/bin/bash

# file to read and stock name
file=$(echo nvda_prices_onemin)
stock=$(echo NVDA)

# variables to track totals
balance=0
gains=0
trades=0

# variables for engulfing bull strategy
hold=0 # check if stock is being held
line=4 # start at minute 4
current_price=$(./getline.sh $file $line)
current_open=$(./getline.sh $file $((line-1)))
prev_close=$(./getline.sh $file $((line-2)))
prev_open=$(./getline.sh $file $((line-3)))

for price in $(cat $file | tail -n +4) # for each price in the file starting from line 4
do
	# check for engulfing bull
	if [ $(bc <<< "$current_price >= $prev_open") -eq 1 ] && [ $(bc <<< "$current_open <= $prev_close") -eq 1 ] && [ $hold -eq 0 ] && [ $(bc <<< "$prev_open > $prev_close") -eq 1 ]
	then
		purchase_price=$current_price
		break_point=$current_open
		time_bought=$line
		hold=1
		trades=$((trades+1))
		echo Buy $stock at $purchase_price per share at minute $time_bought
	fi

	# sell cases
	if [ $hold -eq 1 ] && [ $line -eq $((time_bought+10)) ] # hold stock for 10 minutes
	then
		sale_price=$current_price
		difference=$(echo $sale_price $purchase_price | awk '{print ($1-$2)}')
		 if [ $(bc <<< "$difference < 0") -eq 1 ]
		 then
			 echo Sell $stock at $sale_price at minute $line with loss $difference
		 else
			 gains=$((gains+1))
			 echo Sell $stock at $sale_price at minute $line with gain $difference
		 fi
		 hold=0
		 balance=$(echo $balance $difference | awk '{print ($1+$2)}')
	elif [ $hold -eq 1 ] && [ $(bc <<< "$current_price < $break_point") -eq 1 ] # if stock price drops below open price of time bought
	then
		sale_price=$current_price
		difference=$(echo $sale_price $purchase_price | awk '{print ($1-$2)}')
		if [ $(bc <<< "$difference < 0") -eq 1 ]
		then
			echo Sell $stock at $sale_price at minute $line with loss $difference
		else
			gains=$((gains+1))
			echo Sell $stock at $sale_price at minute $line with gain $difference
		fi
		hold=0
		balance=$(echo $balance $difference | awk '{print ($1+$2)}')
	fi

	# increment the variables
	line=$((line+1))
	current_price=$(./getline.sh $file $line)
	current_open=$(./getline.sh $file $((line-1)))
	prev_close=$(./getline.sh $file $((line-2)))
	prev_open=$(./getline.sh $file $((line-3)))
	# echo $line c_price: $current_price c_open: $current_open p_close: $prev_close p_open: $prev_open
done

if [ $(bc <<< "$balance < 0") -eq 1 ]
then
	echo Loss of \$$balance
else
	echo Gain of \$$balance
fi
echo Win rate $(echo $gains $trades | awk '{print ($1/$2)*100 "%"}')
