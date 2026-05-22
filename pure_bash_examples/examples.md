# Pure Bash Examples

These examples show how to work with text and variables directly
in Bash, which is much faster than using external tools like awk,
sed, or cut.

## 1. Getting a Part of a String

You can grab specific characters from a variable directly.

```bash
# Set a variable with today's day (e.g., Tuesday)
day=$(date +%a)

# Get the first 4 characters
echo ${day:0:4}

# You can skip the '0' if you are starting from the very beginning
echo ${day::4}

# Start 2 characters in
echo ${day:2}

# Get the last 3 characters (make sure to leave a space before the
# minus sign)
echo ${day: -3}
```

## 2. Removing the Beginning of a String (Like basename)

If you want to get just the final folder name from a full path,
pure Bash is the fastest way to do it.

```bash
mydir=$(pwd)

# Slowest way (using awk)
echo $mydir | awk -F/ '{print $NF}'

# Faster way (using the core tool basename)
basename $mydir

# Fastest way (Pure Bash: removes everything up to the final
# slash)
echo ${mydir##*/}
```

## 3. Changing Uppercase and Lowercase

You can easily change the case of letters. In this example, $0
represents the name of the shell you are currently using (like
bash).

```bash
# Change to ALL UPPERCASE
echo ${0^^}

# Change just the first letter to Uppercase
echo ${0^}

# Change to all lowercase
echo ${0,,}
```

## 4. Replacing Words

You can swap out parts of a string instantly without using sed.

```bash
# Replace the word 'bash' with 'Spongebob'
echo ${0/bash/Spongebob}
```

## 5. Finding Variable Names

If you have multiple variables that start with the same letters,
you can find them easily.

```bash
day="Tuesday"
day2="Wednesday"

# List all variable names that start with "da"
echo ${!da@}
```

## 6. Default Values and Error Messages

You can control what happens if a variable is empty or hasn't been
created yet.

```bash
# Delete the variable first so it doesn't exist
unset day

# 1. Set and save a default value if the variable doesn't exist
echo ${day:=Tuesday}

unset day

# 2. Print a string if the variable doesn't exist (but don't save
# it)
echo ${day:-Tuesday}

unset day

# 3. Print a custom error message if the variable doesn't exist
echo ${day?error message}

# 4. Print a string ONLY if the variable DOES exist
day="directory"
echo ${day+print this thing}
```

## 7. Sending Text Directly to a Command

Instead of using echo and a pipe (|) to send text to a tool, you
can use three arrows (<<<). This is faster and looks cleaner.

```bash
# Normal way using an echo and a pipe
echo $0 | sed 's/ba/bread/'

# Better way using three arrows
sed 's/ba/bread/' <<< $0

# Another example: counting words of a variable directly
wc <<< $0
```


