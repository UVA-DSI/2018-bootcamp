#!/bin/bash

counter=1
while [ $counter -le $1 ]
do
	echo $counter
	((counter++))
done

echo All done

