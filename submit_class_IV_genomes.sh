# Define parameters that will be used for all runs
virtual_env="smeagol"
site_score_threshold="0.8"

# Define the analysis and results dirs
analysis_dir=$(dirname $PWD)
results_dir="${analysis_dir}/RESULTS/RESULTS_class_IV_genomes"
mkdir -p ${results_dir}

# Submit the jobs for each genome
##| head -n 3 \
find $PWD/DATA/Genomes/Genomes/IV/ -type f -name "*_genomic.fna.gz" | grep -v -F "_cds_" | grep -v -F -i "_rna_" \
| while read line;
do 

  # Get the filename from the filepath
  genomic_filename=$(basename ${line})

  # Get the virus id
  virus_id=$( echo -e ${genomic_filename} | awk -F '_' '{print $1"_"$2}')

  # Give some feedback on what we are submitting
  echo "Working on viral genome ${virus_id} in file: ${line}"

  # Set up the job
  job_command="${PWD}/scan_PLUS_strand_virus.sh -c ${PWD} -v ${virtual_env} -r ${results_dir} -t ${site_score_threshold} -g ${line} -n ${virus_id}"

  # Run job command
  echo ${job_command}
  bash ${job_command}

  # -------------------------------------------------------------------------
  # JOB SUBMISSION v1
  # -------------------------------------------------------------------------
  ##job_file="${results_dir}/${virus_id}.sh"
  ##echo "#!/bin/bash " > ${job_file}
  ##echo "#PBS -k o " >> ${job_file}
  ##echo "#PBS -l nodes=1:ppn=8,walltime=02:00:00 " >> ${job_file}
  ##echo "#PBS -l mem=50000mb " >> ${job_file}
  ##echo "#PBS -N ${virus_id} " >> ${job_file}
  ##echo "#PBS -j oe " >> ${job_file}
  ##echo "${job_command}" >> ${job_file}
  ##echo "\"${job_command}\"" >> ${job_file}

  # Submit the job
  ##echo "qsub ${job_file}"
  ##bash ${job_command}
  ##qsub ${job_file}

  # -------------------------------------------------------------------------
  # JOB SUBMISSION v2
  # -------------------------------------------------------------------------
  ##echo "qsub \\" > ${job_file}
  ##echo "-l nodes=1:ppn=8,walltime=02:00:00 \\" >> ${job_file}
  ##echo "-l mem=5000mb \\" >> ${job_file}
  ##echo "-N ${virus_id} \\" >> ${job_file}
  ##echo "-j oe \\" >> ${job_file}
  ##echo "${job_command}" >> ${job_file}
  ##echo "\"${job_command}\"" >> ${job_file}

  # Finally, submit the job.
  ##bash ${job_file} \
  ##| cut -d'<' -f2 | cut -d'>' -f1 \
  ##&> "${results_dir}.jobid"

done

