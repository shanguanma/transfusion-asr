#!/usr/bin/env bash


stage=0

stop_stage=100
 
. utils/parse_options.sh


if [ ${stage} -le -1 ] && [ ${stop_stage} -ge -1 ];then
   echo "download librispeech and wavlm-large pretrain model"
   echo " wavlm-large pretrain model is from https://github.com/microsoft/unilm/tree/master/wavlm"
fi

if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ];then
  echo "get wavlm feature from wavlm-large pretrain model using librispeech data"
  librispeech_dir=/mntnfs/lee_data1/xianghuyue/datasets/LibriSpeech/
  wavlm_model=exp/model_hub/wavlm_pretrained_model/WavLM-Large.pt
  feat_dir=data/wavlm_feat
  mkdir -p $feat_dir
  python -m wavlm.extract \
      --librispeech_path $librispeech_dir\
      --ckpt_path $wavlm_model\
      --out_path  $feat_dir
 
fi


if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ];then
  echo "prepare train, valid, test set and vocab"
  librispeech_dir=/mntnfs/lee_data1/xianghuyue/datasets/LibriSpeech/
  feat_dir=data/wavlm_feat
  mkdir -p $feat_dir

 python  split_data.py \
    --librispeech_path $librispeech_dir\
    --ls_wavlm_path $feat_dir \
    --include_test true

fi





if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ];then
  echo "training the diffusion model"
  deepspeed  --include=localhost:0,1,2 train.py \
    train_csv=data/train.csv\
    valid_csv=data/valid.csv \
    checkpoint_path=exp/transfusion_asr/ \
    vocab_path=data/vocab.pt\
    batch_size=12\
     --deepspeed --deepspeed_config=/mntnfs/lee_data1/maduo/w_2022/librispeech/transfusion-asr/deepspeed_cfg.json validation_interval=20000 \
    checkpoint_interval=20000

fi
