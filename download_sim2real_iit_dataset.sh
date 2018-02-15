#!/usr/bin/env bash
mkdir datasets
FILE=sim2real_iit

URL=https://zenodo.org/record/1173747/files/sim2real_iit.tar.gz
ZIP_FILE=./datasets/$FILE.tar.gz
TARGET_DIR=./datasets/$FILE/
wget -N $URL -O $ZIP_FILE
mkdir $TARGET_DIR
#unzip $ZIP_FILE -d ./datasets/
tar -xvzf $ZIP_FILE -C $TARGET_DIR
rm $ZIP_FILE
