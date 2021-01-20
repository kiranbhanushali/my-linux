#!/bin/sh

# stores all packages name in apps.snap.txt file 
sudo snap list | awk '$1!="Name" {print $1}' | paste -sd\t > apps.snap.txt

# removes all the packages 
while read p;do
	sudo snap remove $p
done < apps.snap.txt
