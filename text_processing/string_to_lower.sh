#!/usr/local/bin/bash
#
# Convert string to lower
to_lower() {
  input="$1"
  echo "$input" | tr '[:upper:]' '[:lower:]'
}

while true; do
  echo -n "Enter c to continue: "
  read -sn1 REPLY
  REPLY="$(to_lower "$REPLY")"
  if [ "$REPLY" = "" ]; then
    break
  fi
done
echo "Finished"

# Correctly capture and display the output of to_lower
result=$(to_lower "TEST")
echo "$result"
