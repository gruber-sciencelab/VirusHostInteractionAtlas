#code_dir=${1}
#virtual_env=${2}
#results_dir=${3}
#threshold=${4}
#genome_file=${5}

# _____________________________________________________________________________
# -----------------------------------------------------------------------------
# Give some feedback to the user on which files and directories are used
# -----------------------------------------------------------------------------
echo "________________________________________________________________________"
echo "------------------------------------------------------------------------"
echo "The directory with the code: ${code_dir}"
echo "The virtual environment used: ${virtual_env}"
echo "The directory to which the results will be written: ${results_dir}"
echo "The site prediction threshold used: ${threshold}"
echo "The genome file to be analysed: ${genome_file}"
echo "The genome name: ${genome_name}"
echo "------------------------------------------------------------------------"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/beeond/software/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/beeond/software/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/beeond/software/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/beeond/software/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Load the conda environment
conda activate ${virtual_env}

# Run scan_fasta.py
python ${code_dir}/scan_fasta.py \
--genome_file ${genome_file} \
--pwm_file ${code_dir}/DATA/PWMs/ATtRACT/attract_filtered.h5 \
--out_home ${results_dir} \
--threshold ${threshold} \
--sense + \
--simN 1000 \
--simK 2 \
&> ${results_dir}/${genome_name}.log

# Give some feedback so we know that the job finished successfully.
echo "Job finished successfully."

