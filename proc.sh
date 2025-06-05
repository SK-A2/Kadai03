#!/bin/bash

bzcat $1 | 
parallel --pipe --block 10M  "jq -c '{refsnp_id:.refsnp_id} + 
	{primary_snapshot_data:.primary_snapshot_data.placements_with_allele[] | select(.is_ptlp==true) | .alleles[] | select(.hgvs|contains(\">\"))}'" |
parallel --pipe --block 10M "jq -r -c '[.refsnp_id, .primary_snapshot_data.allele.spdi.deleted_sequence, .primary_snapshot_data.allele.spdi.inserted_sequence, .primary_snapshot_data.hgvs[-3:]] | @tsv'" > _result.tsv


