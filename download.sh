#!/bin/bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the Llama 2 Community License Agreement.

read -p "Enter the URL from email:https://download2.llamameta.net/*?Policy=eyJTdGF0ZW1lbnQiOlt7InVuaXF1ZV9oYXNoIjoiaTl1cjJsYnZqbWxlOGppNXhlOThnZzd5IiwiUmVzb3VyY2UiOiJodHRwczpcL1wvZG93bmxvYWQyLmxsYW1hbWV0YS5uZXRcLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2OTc1NTcyNzl9fX1dfQ__&Signature=BbIwNmlNXjhqSCP0qyu49T8auz%7EcDMkK5kQPIUMfPK6JuYDWf%7EJ1SL2g8nHSUF%7E7mpd-x2okgO0NrwPB0gHOEM4zRfXaOtel1vWxm8yoYJ3vhxoB-OMjOeziPjri4yr7mFTsnqG7h%7E--PACsegCjjAWcdNta71dE0AKKzMFvkcaSjuXZTt%7Eqe0zlpdwSvi-9HVNtZwbCZ-RmHCKCUlJ0nS5NHflkAOUDYs8mT2ndnQDBY29g-t1fEuUHCxEMgn0w81pIcpX3cs5%7EHVO18NNn-t%7EpKvhxBydtoHTERuKiywYtQwSVQEMjDgvCCG0Zm9L7UHX5L7riNKtZM2lOiiKLzg__&Key-Pair-Id=K15QRJLYKIFSLZ&Download-Request-ID=859994752406877 " PRESIGNED_URL
echo ""
ALL_MODELS="7b,13b,34b,7b-Python,13b-Python,34b-Python,7b-Instruct,13b-Instruct,34b-Instruct"
read -p "Enter the list of models to download without spaces ($ALL_MODELS), or press Enter for all: " MODEL_SIZE
TARGET_FOLDER="."             # where all files should end up
mkdir -p ${TARGET_FOLDER}

if [[ $MODEL_SIZE == "" ]]; then
    MODEL_SIZE=$ALL_MODELS
fi

echo "Downloading LICENSE and Acceptable Usage Policy"
wget --continue ${PRESIGNED_URL/'*'/"LICENSE"} -O ${TARGET_FOLDER}"/LICENSE"
wget --continue ${PRESIGNED_URL/'*'/"USE_POLICY.md"} -O ${TARGET_FOLDER}"/USE_POLICY.md"

for m in ${MODEL_SIZE//,/ }
do
    case $m in
      7b)
        SHARD=0 ;;
      13b)
        SHARD=1 ;;
      34b)
        SHARD=3 ;;
      7b-Python)
        SHARD=0 ;;
      13b-Python)
        SHARD=1 ;;
      34b-Python)
        SHARD=3 ;;
      7b-Instruct)
        SHARD=0 ;;
      13b-Instruct)
        SHARD=1 ;;
      34b-Instruct)
        SHARD=3 ;;
      *)
        echo "Unknown model: $m"
        exit 1
    esac

    MODEL_PATH="CodeLlama-$m"
    echo "Downloading ${MODEL_PATH}"
    mkdir -p ${TARGET_FOLDER}"/${MODEL_PATH}"

    for s in $(seq -f "0%g" 0 ${SHARD})
    do
        wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/consolidated.${s}.pth"
    done

    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/params.json"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/params.json"
    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/tokenizer.model"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/tokenizer.model"
    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/checklist.chk"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/checklist.chk"
    echo "Checking checksums"
    (cd ${TARGET_FOLDER}"/${MODEL_PATH}" && md5sum -c checklist.chk)
done
