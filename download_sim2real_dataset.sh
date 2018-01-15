#!/usr/bin/env bash
mkdir datasets
FILE=sim2real

URL=https://zenodo.org/record/1146867/files/sim2real.tar.gz
ZIP_FILE=./datasets/$FILE.tar.gz
TARGET_DIR=./datasets/$FILE/
wget -N $URL -O $ZIP_FILE
#mkdir $TARGET_DIR
#unzip $ZIP_FILE -d ./datasets/
tar -xvzf $ZIP_FILE -C $TARGET_DIR
rm $ZIP_FILE
