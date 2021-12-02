# Define parameters that will be used for all runs
virtual_env="smeagol"
site_score_threshold="0.8"

# Define the analysis and results dirs
analysis_dir=$(dirname $PWD)
results_dir="${analysis_dir}/RESULTS/RESULTS_class_V_genomes"
mkdir -p ${results_dir}

# Submit the jobs for each genome
##| head -n 3 \
find $PWD/DATA/Genomes/Genomes/V/ -type f -name "*_genomic.fna.gz" | grep -v -F "_cds_" | grep -v -F -i "_rna_" \
| while read line;
do 

  # Get the filename from the filepath
  genomic_filename=$(basename ${line})

  # Get the virus id
  virus_id=$( echo -e ${genomic_filename} | awk -F '_' '{print $1"_"$2}')

  # Give some feedback on what we are submitting
  echo "Working on viral genome ${virus_id} in file: ${line}"

  # Set up the job
  job_command="${PWD}/scan_MINUS_strand_virus.sh -c ${PWD} -v ${virtual_env} -r ${results_dir} -t ${site_score_threshold} -g ${line} -n ${virus_id}"

  # Run job command
  echo ${job_command}
  bash ${job_command}
  ##qsub -d ${genome_results_dir} -V ${job_command}

done

