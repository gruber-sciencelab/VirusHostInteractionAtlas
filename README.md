# The Virus-Host Interaction Landscape

Code to analyze the landscape of human ssRNA virus-host interactions.


## Curated PWM sets

[Full list of PWMs used in the study](DATA/PWMs/attract_rbpdb_encode_filtered_human_pwms.csv)

[List of cluster-representative PWMs](DATA/PWMs/attract_rbpdb_encode_representative_matrices.txt)

See [notebooks](notebooks) for the code used to produce these PWM lists.


## Script for genome enrichment

```
python scan_fasta.py --genome_file <Path to genome fasta file> \
                     --pwm_file <Path to .h5 file with processed PWMs> \
                     --out_home <head directory to save output folder> \
                     --threshold <threshold for binding site identification> \
                     --sense <whether input sequence is + or - sense> \
                     --simN <Number of shuffling iterations for background distribution> \
                     --simK <k-mer frequency to conserve in background distribution> \
                     --rcomp <none, only or both> \
                     --out_tsv <if this flag is specified, output is saved as .tsv; otherwise output is saved as.h5> \
```

An example command is below:
```
python scan_fasta.py --genome_file DATA/Genomes/Genomes/V/Segmented/Arenaviridae/GCF_000851025.1/GCF_000851025.1_ViralMultiSegProj14862_genomic.fna.gz \
                     --pwm_file DATA/PWMs/attract_rbpdb_encode_filtered_human_pwms.h5 \
                     --out_home RESULTS \
                     --threshold 0.8 \
                     --sense + \
                     --simN 1000 \
                     --simK 2 \
                     --rcomp both \
                     --out_tsv
```


## Output files

The above script creates a folder in the directory that was supplied through `--out_home`. The output files depend on the chosen format and options.

The example command above would produce the following output files:
```
RESULTS (head directory)
--GCF_000851025.1 (results directory)
----results_attract_filtered.h5
----shuf_1000_2.fa.gz
```
`shuf_1000_2.fa.gz` contains 1000 shuffled sequences generated from the given genome.
`results_attract_filtered.h5` contains the results of binding site prediction and analysis.

If `--out_tsv` is provided, the example command above would instead produce the following output files:
```
RESULTS (head directory)
--GCF_000851025.1 (results directory)
----enrichment_shuf_1000_2_attract_filtered.tsv
----shuf_1000_2.fa.gz
----sites_attract_filtered.tsv
```
`sites_attract_filtered.h5` contains the locations of binding sites found on the given genome.
`enrichment_shuf_1000_2_attract_filtered.h5` contains enrichment results for the given genome relative to the shuffled sequences.
If `--out_tsv` and `--out_all` are both provided, the example command above would also produce the following additional output file:
```
----sites_shuf_1000_2_attract_filtered.tsv
```
This file contains the locations of binding sites found on the shuffled genome sequences. If `-out_all` is provided but not `out_tsv`, these results will still be written, but to the same `.h5` file as the other results.


## Analyzing UTR sequences
```
python scan_utrs.py --utr_file DATA/Genomes/UTRs/Group_IV_UTR.txt \
                     --pwm_file DATA/PWMs/attract_rbpdb_encode_filtered_human_pwms.h5 \
                     --root_dir DATA/Genomes/Genomes/IV/ \
                     --out_home RESULTS \
                     --threshold 0.8 \
                     --sense + \
                     --simN 1000 \
                     --simK 2 \
                     --rcomp none
```



## Reading output from .h5 files

The .h5 output files can be opened in python using the pandas read_hdf command. For example:
```
import pandas as pd
results_file = 'RESULTS/GCF_000851025.1/results_attract_filtered.h5'

real_sites = pd.read_hdf(results_file, key='real_sites') # Read binding sites on real genome
enrichment_results = pd.read_hdf(results_file, key='enr') # Read enrichment results
shuf_sites = pd.read_hdf(results_file, key='shuf_sites') # Read binding sites on shuffled genomes, if they were written

real_sites.head()
```
You can save the same data to a tab-separated text file. For example:
```
enrichment_results.to_csv('output_file_name.csv', sep='\t', index=False)
```
