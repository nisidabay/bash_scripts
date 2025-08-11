#!/bin/bash
#
# Bash factory design pattern
order_product() {
    product_type=$1
    if [ "$product_type" == "beds" ]; then
        create_beds
    elif [ "$product_type" == "furniture" ]; then
        create_furniture
    else
        echo "Unknown product type"
    fi
}

# Create a new Beds product
create_beds() {
    echo "Creating new Beds"
}

# Create a new Furniture product
create_furniture() {
    echo "Creating new Furniture"
}

# Client code to order products
client_code() {
    product_type=$1
    order_product "$product_type"
}

# Main script
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <product_type>"
    exit 1
fi

client_code "$1"

