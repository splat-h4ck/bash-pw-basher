#!/bin/bash
AWK='/usr/bin/awk'
SHA256SUM='/usr/bin/sha256sum'

echo ""
echo "Welcome to [SpLaT]'s handy-dandy bash password basher. Sit back and relax while I get to work!"
echo ""


# Check arguments and return error if not present
if [ -z "$1" ] && [ -z "$2" ]
  then
    echo "Note: You may ask yourself.. why would I need a bash password basher? Well, I asked the same"
    echo "      thing when I was given this project for a school assignment. It might come in handy if"
    echo "      your shell is jailed or something. I don't know. It only needs awk to run. Yes I know"
    echo "      that there a bunch of ways to try breaking out of rbash with awk - so have another."
    echo ""
    echo "******"
    echo "Usage: ./pwcrack.sh [Passwords] [Dictionary File]"
    echo ""  
    exit
fi

# I love rockyou.txt so much I decided to use it as a variable. Suck it.
rockyou=$2

# Adjust this if you want to limit the brute-force times. Stupid.. I know - but it was in the specs.
timeout=120

# Declaring an associativete array to hold our successful passwords
declare -A successful

# Read the lines from the password and separate name from hash
read_line() {

    name=$(echo "$line" | cut -f1 -d: )
    hash=$(echo "$line" | cut -f2 -d: )
}

# try each password - used for both Brute Force and Dict attacks
try_password() {

  if [ "$try" == "$hash" ] ; then 
    if [ "${#successful[$name]}" = 0 ]
      then
        echo "Cracked $name"
        successful["$name"]=$clearpw
    fi
    success="true"
  fi
}

# prints the results at the end or when time runs out
print_results() {
  if [ ${#successful[@]} -gt 0 ]
  then
    for key in "${!successful[@]}"; do
      echo "The password for username $key is: ${successful[${key}]}"
    done
  else
    echo "Sorry - No Passwords were found"
  fi
}

# Checks the time from when the brute force attempt started and exits if time is up
check_time() {
  if [[ $(($SECONDS - $current_time)) -ge $timeout ]]
    then
      echo "Time's Up!"
      print_results
      exit
  fi
}

# Quick dictionary attack using 500 Wors Passwords
quick_attack() {
  while read -u 40 clearpw;
  do
    try=$(echo -n "$clearpw" | $SHA256SUM | $AWK '{print $1}')     
    try_password
    if [ "${success[*]}" = true ]
      then
        break
    fi      
  done 40<"wordlists/500-worst-passwords.txt"
}

# Dictionary attach using an arg from the command line
dictionary_attack() {
  while read -u 50 clearpw;
  do  
    try=$(echo -n "$clearpw" | $SHA256SUM | $AWK '{print $1}')     
    try_password
  done 50<"$rockyou"
}

brute_force_attack() {
  # Use an array to keep track of which letter is changing for the brute force
  array=();
  chars=(a b c d e f g h i j k l m n o p q r s t u v w x y z);

  # Yes I know - for loops probably are not the ideal solution, and I would agree
  # with you if there were more than four characters. But as the specs asked for
  # up to four characters, nested loops are efficient enough. If we wanted true 
  # efficiency, we would not be working in bash.

  # Note: check out GNU Parallel. It would speed things up significantly for this
  # project, however it is not installed on most O/S by default. 
  # You can read about it here: https://www.gnu.org/software/parallel/ 

  while [ "${success[*]}" = "false" ]; do
    echo "Trying password for: $name"    
    for a in {0..26}; do
      array[0]=${chars[a]}
      for e in {0..26}; do
        array[1]=${chars[e]}
        for i in {0..26}; do
          array[2]=${chars[i]}
          for o in {0..25}; do
            array[3]=${chars[o]}            
            clearpw=${array[0]}${array[1]}${array[2]}${array[3]}
            try=$(echo -n "$clearpw" | $SHA256SUM | $AWK '{print $1}')
            try_password
            sleep 0.1;
            check_time
            [ "${success[*]}" = true ] && break
          done
          [ "${success[*]}" = true ] && break
        done
        [ "${success[*]}" = true ] && break
      done
    [ "${success[*]}" = true ] && break
    done
  done
}

echo "*** STARTING QUICK ATTACK ***"
echo ""
while read -u 10 line; 
  do
    success="false"
    read_line
    echo "Trying password for: $name"    
    quick_attack
    if [ "${success[*]}" = true ]
      then
        success="false"
        continue
    fi 
done 10<"$1"

echo ""
echo "*** STARTING DICTIONARY ATTACK ***"
echo ""
while read -u 20 line; 
  do
    success="false"
    read_line
    if [ ${#successful[$name]} -gt 1 ]
      then
        continue
    fi        
    echo "Trying password for: $name"    
    dictionary_attack
    if [ "${success[*]}" = true ]
      then
        success="false"
        continue
    fi
done 20<"$1"

echo ""
echo "*** STARTING BRUTE FORCE ATTACK ***"
echo ""
while read -u 30 line; 
  do
    success="false"
    read_line
    current_time=$SECONDS
    if [ ${#successful[$name]} -gt 1 ]
      then
        continue
    fi
    brute_force_attack    
done 30<"$1"

print_results
