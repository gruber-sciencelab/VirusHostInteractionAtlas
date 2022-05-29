# Source of the SMEAGOL data used
# Copy the virus screening results
mkdir RESULTS
# Version 1 (for submission):
##cp -r -p ../../../RNAVirusScanning_20210829/RESULTS_v1_USED/RESULTS_class_IV_genomes/ RESULTS/
##mv RESULTS/RESULTS_class_IV_genomes/ RESULTS/RESULTS_GroupIV_genomes/
#
# Version 2 (for revision):
cp -r -p \
~/Documents/Publications/VirusHostLandscape/Analyses/VirusHostInteractionAtlas_REVISION/VirusHostInteractionAtlas_Figure4/notebooks/RESULTS/RESULTS_GroupIV_genomes/ \
RESULTS/
# The second directory was just copied to make sure it's for sure reproducible!
cp -r -p \
~/Documents/Publications/VirusHostLandscape/Analyses/VirusHostInteractionAtlas_REVISION/VirusHostInteractionAtlas_Figure4/notebooks/RESULTS/RESULTS_GroupIV_genomes_REPRODUCE_TEST/ \
RESULTS/

# Copy the annotation and PWM files
##cp ../../../Figure2_code_from_Mari/annot_virus_host_GroupIV.txt RESULTS/
##cp ../../../Figure2_code_from_Mari/PWM_DB_encode_attract_rbpdb.txt RESULTS/
cp -r -p \
~/Documents/Publications/VirusHostLandscape/Analyses/VirusHostInteractionAtlas_REVISION/VirusHostInteractionAtlas_Figure4/notebooks/RESULTS/annot_virus_host_GroupIV.txt \
RESULTS/
cp -r -p \
~/Documents/Publications/VirusHostLandscape/Analyses/VirusHostInteractionAtlas_REVISION/VirusHostInteractionAtlas_Figure4/notebooks/RESULTS/PWM_DB_encode_attract_rbpdb.txt \
RESULTS/

# Source of the experimental validation data
##cp \
##/home/andreas/bc2_mountpoints/group_dir/gruberan/working_dir/paper_RBPs/viruses/04_HCV_high_throughput_studies/all_experiments.tab \
##../DATA/ENRICHMENT_VALIDATION/HCV_experiments.tsv

# Activate the conda environment in which SMEAGOL and all dependencies are installed
##conda activate Figure3
conda activate VirusHostLandscape

# Start the notebook
jupyter notebook &

