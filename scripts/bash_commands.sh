#!/bin/sh

beaverdir=`pwd`
echo ${beaverdir} | grep --quiet "beaver"
if [ $? = 1 ]; then
  echo "Run this command from inside the beaver directory"
  return 0;
fi

echo ${beaverdir} | grep --quiet "beaver/"
while [ $? = 0 ]; do
  cd ..
  beaverdir=`pwd`
  echo ${beaverdir} | grep --quiet "beaver/"
done

TOSET1="beaverPath=\"/home/ao/projects/beaver\""
TOSET2="source "$beaverdir"/.bash_beaver"
BASHNAME=$HOME"/.bashrc" # $HOME"/"
if [ -f $BASHNAME ]; then
  if [ -f ".bash_profile" ]; then
    echo "There are two bash profile in the home directory. Please delete one to use this script."
    return 0;
  fi
else
  BASHNAME=$HOME"/.bash_profile"
  if [ ! -f $BASHNAME ]; then
    echo "There is no bash profile in the home directory."
    return 0;
  fi
fi

BASHDIR=$BASHNAME


if grep -q "beaver" $BASHDIR; then
  echo "This bash already contians the commands. If this is incoreect, you must change it manually through editing the "$BASHNAME"."
else
  echo "Editing \""$BASHNAME"\"...";
  echo "Adding the following lines:"
  /bin/echo -e "\e[33m"$TOSET1"\e[39m\e[49m"
  echo $TOSET1 >> $BASHDIR
  /bin/echo -e "\e[33m"$TOSET2"\e[39m\e[49m"
  echo $TOSET2 >> $BASHDIR
fi
