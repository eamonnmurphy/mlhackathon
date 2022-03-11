#!/bin/bash
# Inputs: $1 num images of each species
# Example usage: bash get_data.sh 10

for order in *.txt; do
    echo "Order: $order";
    mkdir -p ../data/${order%.*}  # make directory for images of this order

    while IFS= read -r line; do
        echo "Getting images of: $line"
        ./dwn_pics.rb -s $line -n $1 -f ../data/${order%.*} -o ../sandbox/metadata.txt -r small
    done < "$order"  # filename

done

