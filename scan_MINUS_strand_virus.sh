# _____________________________________________________________________________
# -----------------------------------------------------------------------------
# Ensure we do not run the script with 
# -----------------------------------------------------------------------------
# do not run the script if we try to use an uninitialized variable
##set -u
# exit the script, if any statement has a non-true return value
##set -e

# _____________________________________________________________________________
# -----------------------------------------------------------------------------
# Read in the parameters
# -----------------------------------------------------------------------------
usage()
{
cat << EOF
usage: $0 options

OPTIONS:
   -c                  The directory that contains the scripts (GitRepo).
   -v                  The path/name of the virtual environment (Conda).
   -r                  The path to the results directory.
   -t                  The site score threshold to be used.
   -g                  The genome file to run on.
   -n                  The name of the genome.
   -h                  Print the script help.
EOF
}

if [ $# -lt 1 ] ; then
    usage
    exit 1
fi

# _____________________________________________________________________________
# -----------------------------------------------------------------------------
# Declare input variables (DEBUG MODE)
# -----------------------------------------------------------------------------
code_dir=""
virtual_env=""
results_dir=""
threshold=""
genome_file=""
genome_name=""

unset code_dir
unset virtual_env
unset results_dir
unset threshold
unset genome_file
unset genome_name

# -----------------------------------------------------------------------------
# Declare input variables (OPERATIVE MODE)
# -----------------------------------------------------------------------------
while getopts c:v:r:t:g:n:h: opt
do
   case "$opt" in
      c) code_dir=$OPTARG;;
      v) virtual_env=$OPTARG;;
      r) results_dir=$OPTARG;;
      t) threshold=$OPTARG;;
      g) genome_file=$OPTARG;;
      n) genome_name=$OPTARG;;
      h) usage;;
   esac
done

# _____________________________________________________________________________
# -----------------------------------------------------------------------------
# check if we got an argument
if [ "$code_dir" == "" ] || [ "$virtual_env" == "" ] || [ "$results_dir" == "" ] || [ "$threshold" == "" ] || [ "$genome_file" == "" ] || [ "$genome_name" == "" ] ; then
    usage
    exit -1
fi

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
--pwm_file ${code_dir}/DATA/PWMs/attract_rbpdb_encode_filtered_human_pwms.h5 \
--out_home ${results_dir} \
--threshold ${threshold} \
--sense - \
--rcomp both \
--simN 1000 \
--simK 2 \
--out_tsv \
&> ${results_dir}/${genome_name}.log

conda deactivate

# Give some feedback so we know that the job finished successfully.
echo "Job finished successfully."

