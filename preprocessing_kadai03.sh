#!/bin/bash

# Split Data
time bzcat $1 | split -l 800000 -d -a 1 --additional-suffix=.json - splitData_

# Parallel + JQ
time parallel -j 4 "jq -c '{refsnp_id:.refsnp_id} + {primary_snapshot_data:.primary_snapshot_data.placements_with_allele[] | select(.is_ptlp==true) | .alleles[] | select(.hgvs|contains(\">\"))}' {} > _{/}" ::: splitData* 

time parallel -j 4 "jq -r -c '[.refsnp_id, .primary_snapshot_data.allele.spdi.deleted_sequence, .primary_snapshot_data.allele.spdi.inserted_sequence, .primary_snapshot_data.hgvs[-3:]] | @tsv' {}" ::: _splitData* |

# Sort
sort -n -k 1 -t\t > _result.tsv

# Remove Intermediate Data
rm splitData*
rm _splitData*
