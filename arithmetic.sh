#!/usr/bin/bash
# The shebang line specifies the path to the Bash interpreter.
# Demonstrating arithmetic operations in Bash.

# Method 1: Using the arithmetic expansion

n1=5  # Assigning the value 5 to n1.
n2=3  # Assigning the value 3 to n2.
result=$((n1 + n2))  # Performing arithmetic using arithmetic expansion.
echo $result  # Echoing the result. This will print 8.

# Method 2: Using the 'expr' command

n1=19  # Assigning a new value, 19, to n1.
n2=20  # Assigning a new value, 20, to n2.
result=$(expr $n1 + $n2)  # Performing arithmetic using 'expr' command.
echo "$result"  # Echoing the result. This will print 39.
