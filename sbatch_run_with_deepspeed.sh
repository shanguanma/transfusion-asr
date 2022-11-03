#!/bin/bash
#SBATCH -J transfusion
#SBATCH -p p-V100
#SBATCH -N 1
#SBATCH --ntasks=24
#SBATCH --gres=gpu:3

source /cm/shared/apps/anaconda3/etc/profile.d/conda.sh
conda activate transfusion-asr 
cd /mntnfs/lee_data1/maduo/w_2022/librispeech/transfusion-asr
#bash run.sh --stage 0 --stop-stage 0
#bash run.sh --stage 1 --stop-stage 1   
bash run.sh --stage 2 --stop-stage 2                                                            
