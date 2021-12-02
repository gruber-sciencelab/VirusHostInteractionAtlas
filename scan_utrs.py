# General imports
import os
import numpy as np
import pandas as pd
import glob
import argparse
import logging

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
    parser.add_argument('--utr_file', type=str, help='Path to tab-separated file with UTR locations', required=True)
    parser.add_argument('--pwm_file', type=str, help='Path to .h5 file with processed PWMs', required=True)
    parser.add_argument('--root_dir', type=str, help='Path to genomes', required=True)
    parser.add_argument('--out_home', type=str, help='head directory to save output folder.', required=True)
    parser.add_argument('--threshold', type=float, help='threshold for binding site identification. \
                        Fractional value ranging from 0 to 1.', required=True)
    parser.add_argument('--rcomp', type=str, help='only, both or none', required=True)
    parser.add_argument('--sense', type=str, choices=('+', '-'), help='whether input sequence is + or - sense',
                        required=False)
    parser.add_argument('--simN', type=int, help='Number of shuffling iterations for background distribution.',
                        required=True)
    parser.add_argument('--simK', type=int, help='K-mer frequency to conserve in background distribution.',
                        required=True)
    args = parser.parse_args()
    return args

args = parse_args()


# utr_file: 'DATA/Genomes/UTRs/Group_IV_UTR.txt'
# genome_dir:'DATA/Genomes/Genomes/IV/'
# pwm_file:'DATA/PWMs/attract_rbpdb_encode_filtered_human_pwms.h5'
# root_dir: 'DATA/Genomes/Genomes/IV/'

# Parameters
utr_file = args.utr_file
pwm_file = args.pwm_file
root_dir = args.root_dir
out_home = args.out_home
threshold = args.threshold
rcomp = args.rcomp
sense = args.sense
simN = args.simN
simK = args.simK


# Read PWMs
pwms = pd.read_hdf(pwm_file, key="data")
_logger.info("Read information on " + str(len(pwms)) + " PWMs from " + pwm_file)

# Encode PWMs
model = smeagol.models.PWMModel(pwms)
_logger.info("Encoded PWMs.")

# Read UTRs
utrs = pd.read_csv(utr_file, sep='\t', header=None, usecols=(0,2,3,4))
_logger.info("Read information on " + str(len(utrs)) + " UTRs from " + utr_file)

# Add length, ID, file
utrs.columns = ['name', 'region', 'start', 'end']
utrs['len'] = utrs['end'] - utrs['start']
utrs['genome_file'] = [x.split('.gff')[0] + '.fna.gz' for x in utrs['name']]
utrs['id'] = [x.split(':')[1] for x in utrs['name']]

# Filter UTRs that are too short for PWM scanning
utrs = utrs[utrs.len >= 12].reset_index(drop=True)
_logger.info(str(len(utrs)) + 'UTRs remaining after length filter')

# Read UTR sequences
paths = []
seqs = []

for i in range(len(utrs)):
    file = utrs['genome_file'][i]
    for path in glob.iglob(root_dir + '**/' + file, recursive=True):
        genome = smeagol.io.read_fasta(path)
        segment = [x for x in genome if x.id==utrs['id'][i]]
        seq = segment[0][utrs['start'][i]:utrs['end'][i]]
        seqs.append(seq)

utrs['seq'] = seqs
_logger.info("Extracted UTR sequences")

# Enrichment
enrs = []
sites = []
for seq in utrs['seq']:
    enrichment_result = smeagol.enrich.enrich_in_genome([seq], model, simN, simK, rcomp, sense, 
                                     threshold, verbose=False, combine_seqs=True, background='binomial')
    enrs.append(enrichment_result['enrichment'])
    sites.append(enrichment_result['real_sites'])

assert len(enrs) == len(utrs)
assert len(sites) == len(utrs)

# Merge with UTR info
for i in range(len(utrs)):
    for param in ['name', 'region', 'genome_file', 'id']:
        enrs[i][param] = utrs.loc[i, param]
        sites[i][param] = utrs.loc[i, param]

enrs = pd.concat(enrs).reset_index(drop=True)
sites = pd.concat(sites).reset_index(drop=True)

# Merge with RBPs
enrs = enrs.merge(pwms.iloc[:,:3], on='Matrix_id')
sites = sites.merge(pwms.iloc[:,:3], on='Matrix_id')

# Save results
enrs.to_csv(out_home + '/gpIV_utr_enrichment.tsv', sep='\t', index=False)
sites.to_csv(out_home + '/gpIV_utr_sites.tsv', sep='\t', index=False)