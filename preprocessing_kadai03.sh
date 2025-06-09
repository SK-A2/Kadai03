#!/bin/bash

# Make Directory for Intermediate Data (Delete after Run)
mkdir _tmp

# Split Data
time bzcat $1 | split -l 100000 -d -a 2 --additional-suffix=.json - ./_tmp/splitData

# Parallel + JQ
time parallel \
	"jq -c 	'{refsnp_id:.refsnp_id} + \
		{primary_snapshot_data:.primary_snapshot_data.placements_with_allele[] | \
		select(.is_ptlp==true) | \
		.alleles[] | \
		select(.hgvs|contains(\">\"))}' {} > {.}.tsv.json" \
	::: ./_tmp/splitData* 

time parallel \
	"jq -r -c 	'[.refsnp_id, \
			.primary_snapshot_data.allele.spdi.deleted_sequence, \
			.primary_snapshot_data.allele.spdi.inserted_sequence, \
			.primary_snapshot_data.hgvs[-3:]] | \
			@tsv' {} > {.}.tsv"  \
	::: ./_tmp/*.tsv.json 

# Sort
cat ./_tmp/*.tsv | sort -n -k 1 -t\t > ./result.tsv

# Remove Intermediate Data
# rm -r _tmp
