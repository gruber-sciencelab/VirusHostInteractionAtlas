# General imports
import os
import numpy as np
import pandas as pd
import time
import logging
import argparse

# SMEAGOL
import smeagol.io, smeagol.enrich, smeagol.models

# Set up logging
log_formatter = logging.Formatter('%(levelname)s:%(asctime)s:%(name)s] %(message)s')
_logger = logging.getLogger('SiteEnrichment')
_handler = logging.StreamHandler()
_handler.setLevel(logging.INFO)
_handler.setFormatter(log_formatter)
_logger.setLevel(logging.INFO)
_logger.addHandler(_handler)


# Argument parser
def parse_args():
    """Parse command line arguments.
    Return:
        args : parsed argument object.
    """
    parser = argparse.ArgumentParser(
        description='Binding site prediction and enrichment.')
    parser.add_argument('--genome_file', type=str,
                        help='Path to genome fasta file', required=True)
    parser.add_argument('--pwm_file', type=str,
                        help='Path to .h5 file with processed PWMs',
                        required=True)
    parser.add_argument('--out_home', type=str,
                        help='head directory to save output folder.',
                        required=True)
    parser.add_argument('--threshold', type=float,
                        help='threshold for binding site identification. \
                        Fractional value ranging from 0 to 1.', 
                        required=True)
    parser.add_argument('--rcomp', type=str, help='only, both or none', required=True)
    parser.add_argument('--sense', type=str, choices=('+', '-'),
                        help='whether input sequence is + or - sense',
                        required=False)
    parser.add_argument('--simN', type=int, 
                        help='Number of shuffling iterations for background distribution.',
                        required=True)
    parser.add_argument('--simK', type=int, 
                        help='K-mer frequency to conserve in background distribution.',
                        required=True)
    parser.add_argument('--seq_batch', type=int, 
                        help='Number of shuffled sequences to scan at once.',
                        default=0)
    parser.add_argument('--out_tsv', action='store_true',
                        help='if specified, output is saved as .tsv; otherwise output is saved as.h5')
    args = parser.parse_args()
    return args


args = parse_args()


genome_file = args.genome_file
pwm_file = args.pwm_file
out_home = args.out_home
threshold = args.threshold
rcomp = args.rcomp
sense = args.sense
simN = args.simN
simK = args.simK
seq_batch = args.seq_batch
out_tsv = args.out_tsv

start_time = time.time()

# Make results directory
out_dir = os.path.join(out_home, genome_file.split('/')[-2])
os.makedirs(out_dir, exist_ok=True)
_logger.info("Results will be saved to " + out_dir)   

# Name output files

## File with shuffled genomes
shuf_genome_file = os.path.join(out_dir, 'shuf_' + str(simN) + '_' + str(simK) + '.fa.gz')
_logger.info("Shuffled genome sequences will be saved to " + shuf_genome_file)

## Name separate .tsv files
if out_tsv:
    file_end = os.path.splitext(os.path.basename(pwm_file))[0] + '.tsv'

    ## File with predicted binding sites on genome
    genome_sites_file = os.path.join(out_dir, 'sites_' + file_end)
    _logger.info("Predicted binding sites on the genome will be saved to " + genome_sites_file)
    
    ## File with enrichment results
    enrichment_file = os.path.join(out_dir, 
                                   'enrichment_' + 'shuf_' + str(simN) + '_' + str(simK) + '_' + file_end)
    _logger.info("Enrichment results will be saved to " + enrichment_file)
        
else:
    ## Name single h5 file for all results
    all_results_file = os.path.join(out_dir, 'results_' + os.path.basename(pwm_file))
    _logger.info("Predicted binding sites and enrichment results will be saved to " + all_results_file)

    
# Load PWMs
pwms = pd.read_hdf(pwm_file, key="data")
_logger.info("Read information on " + str(len(pwms)) + " PWMs from " + pwm_file)

# Encode PWMs
model = smeagol.models.PWMModel(pwms)
_logger.info("Encoded PWMs.")

# Load genome
genome = smeagol.io.read_fasta(genome_file)
_logger.info('Read ' + str(len(genome)) + ' sequences from ' + genome_file)

# Enrichment analysis
enrichment_result = smeagol.enrich.enrich_in_genome(genome, model, simN, simK, rcomp, sense, 
                                     threshold, verbose=False, combine_seqs=True, 
                                     background='binomial', seq_batch=seq_batch)

_logger.info("Completed enrichment analysis.")

# Filter enrichment results
enr = enrichment_result['enrichment']
for sense in pd.unique(enr.sense):
    enr_sense = enr[(enr.fdr<0.05) & (enr.num > enr.avg) & (enr.sense=='+')]
    dep_sense = enr[(enr.fdr<0.05) & (enr.num < enr.avg) & (enr.sense=='+')]
    print(str(len(enr_sense)) + 'PWMs were enriched on the ' + sense + ' strand.')
    print(str(len(dep_sense)) + 'PWMs were depleted on the ' + sense + ' strand.')

# Save output
if out_tsv:
    # Saving output to .tsv files
    ## Real sites
    enrichment_result['real_sites'].to_csv(genome_sites_file, sep='\t', index=False)
    _logger.info("Wrote genome binding site locations to " + genome_sites_file)
    ## Enrichment
    enr.to_csv(enrichment_file, sep='\t', index=False)
    _logger.info("Wrote enrichment results to " + enrichment_file)

else:
    # Save all results to a single .h5 file
    ## Real sites
    enrichment_result['real_sites'].to_hdf(all_results_file, key='real_sites', complevel=9)
    _logger.info("Wrote genome binding site locations to " + all_results_file)
    ## Enrichment
    enr.to_hdf(all_results_file, key='enr', complevel=9)
    _logger.info("Wrote enrichment results to " + all_results_file)

# Time taken

end_time = time.time()
_logger.info("Total runtime: " + str(end_time - start_time) + " seconds")
