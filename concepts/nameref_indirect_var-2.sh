#!/usr/bin/env bash
#
# Demonstrate nameref and indirect array modification.
check_nameref() {
	# 'ref' is now an alias for the variable whose name was passed in $1
	declare -n ref="$1"
	if [[ -v ref ]]; then
		echo "Nameref: Variable '$1' exists with value '$ref'"
		# Modifying the reference modifies the original variable
		ref="goodbye"
	else
		echo "Nameref: Variable '$1' doesn't exist"
	fi
}

# Using indirect expansion
# Indirect expansion uses the value of one variable as the name of another.
# It's an older method but still widely used.
check_indirect() {
	local original_name="$1"
	local var_name="$original_name"
	# Note the use of indirect expansion `${!var_name}` to check the target variable
	if [[ -n "${!var_name+x}" ]]; then
		echo "Indirect: Variable '$var_name' exists with value '${!var_name}'"
		echo "Changing indirect Variable"
		printf -v "$var_name" "Adios"
	else
		echo "Indirect: Variable '$var_name' doesn't exist"
	fi
}

# With a nameref, modifying arrays is straightforward.
check_nameref_array() {
	declare -n ref="$1"
	echo "Nameref: Modifying array '$1'"
	ref[0]="modified_by_nameref_0"
	ref[key_assoc]="modified_by_nameref_assoc"
}

# With indirect expansion, modifying array elements often requires `eval`.
# This should be used with caution if the variable name is not controlled.
check_indirect_array() {
	local var_name="$1"
	echo "Indirect: Modifying array '$1'"
	# Using eval is powerful but potentially dangerous. It's safe here
	# because we fully control the input string.
	eval "$var_name[1]='modified_by_indirect_1'"
	eval "$var_name[key_assoc]='modified_by_indirect_assoc'"
}

main() {
	echo "### Scalar variable tests ###"
	greetings="hello"
	echo "--- Initial state ---"
	echo "greetings = '$greetings'"
	echo

	echo "--- Calling functions with the variable NAME ---"
	# Pass the NAME of the variable, not its value
	check_nameref "greetings"
	check_indirect "greetings"
	echo

	echo "--- Final state ---"
	# Show that the nameref function modified the original variable
	echo "greetings = '$greetings'"
	echo
	echo "----------------------------------------"
	echo

	echo "### Array modification tests ###"
	declare -a my_array=("index_0" "index_1")
	declare -A my_assoc_array=([key_one]="value1" [key_assoc]="value_assoc")

	echo "--- Initial array states ---"
	echo "Indexed array: (${my_array[@]})"
	echo -n "Associative array: "
	declare -p my_assoc_array
	echo

	echo "--- Modifying arrays with nameref ---"
	check_nameref_array "my_array"
	check_nameref_array "my_assoc_array"
	echo "Indexed array after nameref: (${my_array[@]})"
	echo -n "Associative array after nameref: "
	declare -p my_assoc_array
	echo

	echo "--- Modifying arrays with indirect expansion ---"
	check_indirect_array "my_array"
	check_indirect_array "my_assoc_array"
	echo "Indexed array after indirect: (${my_array[@]})"
	echo -n "Associative array after indirect: "
	declare -p my_assoc_array
}

main
