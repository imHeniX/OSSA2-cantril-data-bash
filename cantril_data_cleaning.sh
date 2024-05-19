#!/bin/bash
# Cantil Data Cleaning Script
# Author: Yadhu


# here we take three input files as arguments (GDP.v.happiness, Homicide Rate, Life Expectancy)
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <gdp-vs-happiness.tsv> <homicide-rate-unodc.tsv> <life-satisfaction-vs-life-expectancy.tsv>"
    exit 1
fi

gdp_data_file="$1"
homicide_data_file="$2"
life__data_file="$3"

check_tsv_format() {
    awk -F'\t' '{if(NR>1 && NF<2) exit 1}' "$1" || { echo "Error: $1 is not a tab-separated format file"; exit 1; }
}

clean_gdp_data() {
    local input="$1"
    local output="$2"
    awk -F'\t' -v OFS='\t' '
    NR == 1 { next }
    $2 != "" && $5 != "" && $6 != "" {
        print $1, $2, $3, $5, $6, "", "", $4
    }
    ' "$input" > "$output"
}

clean_homicide_data() {
    local input="$1"
    local output="$2"
    awk -F'\t' -v OFS='\t' '
    NR == 1 { next }
    $2 != "" {
        print $1, $2, $3, "", "", $4, "", ""
    }
    ' "$input" > "$output"
}

# function created to clean Life data
clean_life_data() {
    local input="$1"
    local output="$2"
    awk -F'\t' -v OFS='\t' '
    NR == 1 { next }
    $2 != "" && $5 != "" {
        print $1, $2, $3, "", $5, "", $4, $6
    }
    ' "$input" > "$output"
}

# function created to merge cleaned data
merge_data() {
    local gdp_data_file="$1"
    local homicide_data_file="$2"
    local life__data_file="$3"
    local output="$4"
    awk -F'\t' -v OFS='\t' '
    BEGIN {
        print "Entity/Country", "Code", "Year", "GDP per capita", "Population", "Homicide Rate", "Life Expectancy", "Cantril Ladder score"
    }
    NR == FNR {
        key = $1 FS $2 FS $3
        data[key] = $0
        next
    }
    FNR == 1 { next }
    {
        key = $1 FS $2 FS $3
        if (key in data) {
            split(data[key], fields, FS)
            if ($6 != "") fields[6] = $6
            if ($7 != "") fields[7] = $7
            if ($8 != "") fields[8] = $8
            merged[key] = fields[1] FS fields[2] FS fields[3] FS fields[4] FS fields[5] FS fields[6] FS fields[7] FS fields[8]
        } else {
            merged[key] = $0
        }
    }
    END {
        for (key in merged) {
            print merged[key]
        }
    }
    ' "$gdp_data_file" "$homicide_data_file" "$life__data_file" > "$output"
}

# confirm input files are in tab-separated format
check_tsv_format "$gdp_data_file"
check_tsv_format "$homicide_data_file"
check_tsv_format "$life__data_file"

# clean and format input files
clean_gdp_data "$gdp_data_file" "cleaned_gdp.tsv"
clean_homicide_data "$homicide_data_file" "cleaned_homicide.tsv"
clean_life_data "$life__data_file" "cleaned_life.tsv"

# merge cleaned data
output_file="output.tsv"
merge_data "cleaned_gdp.tsv" "cleaned_homicide.tsv" "cleaned_life.tsv" "$output_file"

#clean up temporary files
rm "cleaned_gdp.tsv" "cleaned_homicide.tsv" "cleaned_life.tsv"

echo "Data cleaning completed. Cleaned data saved to $output_file"