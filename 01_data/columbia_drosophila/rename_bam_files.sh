# Rename the files so they match the sample names.
# This doesn't work as part of a slurm job, so here we are.
# Tom Ellis 29th September 2023

scratch=/scratch-cbe/users/thomas.ellis/05_col0_flies
unzip_dir=$scratch/AACJNTVM5_0_R14907_20230206/demultiplexed

col0=/scratch-cbe/users/thomas.ellis/columbia/fastq
dmel=/scratch-cbe/users/thomas.ellis/drosophila/fastq
mkdir -p $col0
mkdir -p $dmel

# # Rename and move the files for Col-0
for i in $unzip_dir/22084*/*S9_*; do mv "$i" "${i/22084?_*_S+([0-9])/Col0_05_15X}"; done
for i in $unzip_dir/22084*/*S10_*; do mv "$i" "${i/22084?_*_S+([0-9])/Col0_10_15X}"; done
for i in $unzip_dir/22084*/*S1_*; do mv "$i" "${i/22084?_*_S+([0-9])/Col0_05_13X}"; done
for i in $unzip_dir/22084*/*S2_*; do mv "$i" "${i/22084?_*_S+([0-9])/Col0_10_13X}"; done
mv $unzip_dir/22084*/Col0* $col0

# # Rename files for drosophila 
for i in $unzip_dir/22084*/*S13_*; do mv "$i" "${i/22084?_*_S+([0-9])/Fly1_05_15X}"; done
for i in $unzip_dir/22084*/*S14_*; do mv "$i" "${i/22084?_*_S+([0-9])/Fly2_05_15X}"; done
for i in $unzip_dir/22084*/*S15_*; do mv "$i" "${i/22084?_*_S+([0-9])/Fly3_10_15X}"; done
for i in $unzip_dir/22084*/*S16_*; do mv "$i" "${i/22084?_*_S+([0-9])/Fly4_10_15X}"; done
for i in $unzip_dir/22084*/*S5_*; do mv "$i" "${i/22084?_*_S+([0-9])/Fly1_05_13X}"; done
for i in $unzip_dir/22084*/*S6_*; do mv "$i" "${i/22084?_*_S+([0-9])/Fly2_05_13X}"; done
for i in $unzip_dir/22084*/*S7_*; do mv "$i" "${i/22084?_*_S+([0-9])/Fly3_10_13X}"; done
for i in $unzip_dir/22084*/*S8_*; do mv "$i" "${i/22084?_*_S+([0-9])/Fly4_10_13X}"; done
mv $unzip_dir/22084*/Fly* $dmel

# Rename files for 9601. Not used.
# for i in $unzip_dir/22084*/*S11_*; do mv "$i" "${i/22084?_*_S+([0-9])/9601_cont_05_15X}"; done
# for i in $unzip_dir/22084*/*S12_*; do mv "$i" "${i/22084?_*_S+([0-9])/9601_cont_10_15X}"; done
# for i in $unzip_dir/22084*/*S3_*; do mv "$i" "${i/22084?_*_S+([0-9])/9601_cont_05_13X}"; done
# for i in $unzip_dir/22084*/*S4_*; do mv "$i" "${i/22084?_*_S+([0-9])/9601_cont_10_13X}"; done