#!/bin/bash

# Change the username(if needed) and filename to the appropriate entries.
USERNAME="stu"
FILENAME="/home/stu/testIP1"

# Enter the domain names or IP addresses of the servers here
IP1=192.168.122.94
IP2=192.168.122.229
IP3=
IP4=

# Change this array to reflect the domain name or IP address above.
files_array=( $IP1 $IP2 )

DIRcurr="current"
DIRorig="original"


# Check for a directory to contain copies of the files as they exist on the server.
if [ ! -d ${DIRcurr} ]; then
	echo ""
	echo "Creating directory for current files..."
	mkdir $DIRcurr
fi

# Iterates through the array of servers and copies the designated file to the "current" directory.
for f in "${files_array[@]}"; do
	echo ""
	echo "Retreiving file from ${f}"

	#Can use this line instead, with username if needed
	#scp "$USERNAME@${f}:${FILENAME}" "${DIRcurr}/${f}.temp"

	scp "${f}:${FILENAME}" "${DIRcurr}/${f}.temp"
done


# Check to see if the file containing copies of the original files exists, and if so ensures the files are the 
# same across the server and also the same as they were when the script was first run.

if [ -d $DIRorig ]; then
	
	echo ""
	echo "Ensuring files are the same across servers..."
	echo ""
	
	BASE="${files_array[0]}"
	isSame=true
	echo "Comparing files against "$BASE""
	echo "Note: If ALL servers reflect a difference, $BASE is the odd one out!"
	
	for j in "${files_array[@]}"; do
		if [ ! "${j}" = "${BASE}" ]; then
			echo ""
			if ! cmp -s "${DIRcurr}/${j}.temp" "${DIRcurr}/${BASE}.temp"; then
				echo "Testing: ${j} == different!"
				isSame=false
			else
				echo "Testing: ${j} == same."
			fi
		fi
	done

	echo ""	
	if $isSame; then 
		echo "All server files are the same"
	else
		echo "================================================="
		echo "ERROR: Server files are different"
		echo "================================================="
	fi

	echo ""
	echo "Now testing if the files have changed"
	echo ""
	for k in "${files_array[@]}"; do
		DIFF=$(diff -u "${DIRorig}/${k}.temp" "${DIRcurr}/${k}.temp")
		if [ ! "$DIFF" = "" ]; then
			echo ""
			echo "================================================="
			echo "ERROR: ${k} - Files have changed!"
			echo "================================================="
			echo "Printing diff..."
			echo "$DIFF"
		else
			echo ""
			echo "${k} - No change detected."
		fi
	done

else
	echo "No original copies found... Creating copies of the original files!"
	mkdir $DIRorig
	cp -r $DIRcurr/* $DIRorigS
	echo "Please run again to compare files between servers and against the originals."
fi


# Removes the directory containing the current files and prompts the user script is ready.
echo ""
echo "Removing current copies to prepare for next run..."
rm -rf $DIRcurr
echo ""
echo "Ready to run again!"

