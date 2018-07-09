#!/bin/bash

counter=10
while [ $counter -ne 0 ]
do
	echo $counter
	((counter--))
done

echo All done

