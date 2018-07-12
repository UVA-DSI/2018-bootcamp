#!/bin/bash

counter=$1
while [ $counter -ge 1 ]
do
	echo $counter
	((counter--))
done

echo All done

