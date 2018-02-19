#!/usr/bin/env bash

RED='\033[0;31m'
NC='\033[0m' # No Color
SAMPLES=$1
CYCLE_GAN=~/Phuong/CycleGAN-tensorflow
KSL=~/Phuong/kinStructureLearning
DATADUMP_PATH=~/Phuong/large-data

# Default value of simulation dataset data_kSL_20171108_1900
DATASET=data_kSL_sim_20171205_1755 #data_kSL_20171108_1900
SIM2REAL=sim2real_iit2 #sim2real_iit2

# Generate full-size masks (320x240)
echo number of samples is $SAMPLES
echo -e "$RED generate masks of $DATASET"
echo -e "$NC"
cd $KSL/misc
python generate_image_mask.py $DATADUMP_PATH/$DATASET/images

# Generate cycleGAN dataset, left/right and 2 left_masked/right_masked
echo ===============================================
echo -e "$RED generate implanted images"
echo -e "$NC"
cd $KSL/keras_model/prepocessing
python create_sim_background_dataset.py --datapath $DATADUMP_PATH \
                                        --dataset $DATASET \
                                        --img_type origin \
                                        --background True \
                                        --crop True \
                                        --mask True \
                                        --create_img True \
                                        --samples $SAMPLES \

# Move implanted images folder to $CYCLE_GAN/datasets/$SIM2REAL
mkdir $CYCLE_GAN/datasets/$SIM2REAL
## left
mv $KSL/keras_model/processed_data/$DATASET/images/left $CYCLE_GAN/datasets/$SIM2REAL/testA
mv $KSL/keras_model/processed_data/$DATASET/images/left_masked $CYCLE_GAN/datasets/$SIM2REAL/testA_mask
## right
mv $KSL/keras_model/processed_data/$DATASET/images/right $CYCLE_GAN/datasets/$SIM2REAL/trainA
mv $KSL/keras_model/processed_data/$DATASET/images/right_masked $CYCLE_GAN/datasets/$SIM2REAL/trainA_mask

# Generate cycleGAN sim2real images in $CYCLE_GAN/test/left & $CYCLE_GAN/test/right
echo ===============================================
echo -e "$RED generate sim2real images with learned cycleGAN model sim2real"
echo -e "$NC"
cd $CYCLE_GAN
python main.py --dataset_dir $SIM2REAL --fine_size 256 --phase test --testA /testA --test_dir test/left
python main.py --dataset_dir $SIM2REAL --fine_size 256 --phase test --testA /trainA --test_dir test/right

# Generate synSim images in $CYCLE_GAN/test/left_synSim & $CYCLE_GAN/test/right_synSim
echo ===============================================
echo -e "$RED generate synSim images"
echo -e "$NC"
cd $KSL/misc

python generate_synSim_image.py --mask_path $CYCLE_GAN/datasets/$SIM2REAL \
                                --mask_folder trainA_mask --gen_path $CYCLE_GAN/test \
                                --gen_folder right --origin_folder trainA --combine True \
                                --samples $SAMPLES

python generate_synSim_image.py --mask_path $CYCLE_GAN/datasets/$SIM2REAL \
                                --mask_folder testA_mask --gen_path $CYCLE_GAN/test \
                                --gen_folder left --origin_folder testA --combine True \
                                --samples $SAMPLES

# Move 2 synSim images folders to $DATADUMP_PATH/DATASET/images
mv $CYCLE_GAN/test/left_synSim $DATADUMP_PATH/$DATASET/images/left_synSim
mv $CYCLE_GAN/test/right_synSim $DATADUMP_PATH/$DATASET/images/right_synSim

cp $DATADUMP_PATH/$DATASET/images/left/*.log $DATADUMP_PATH/$DATASET/images/left_synSim
cp $DATADUMP_PATH/$DATASET/images/right/*.log $DATADUMP_PATH/$DATASET/images/right_synSim

# Generate kinStrLearn dataset
echo ===============================================
echo -e "$RED generate kinematics structure learning dataset kSL"
echo -e "$NC"
cd $KSL/keras_model/prepocessing
python preprocess_kinStrLearn_data.py --dataset $DATASET \
                                       --datapath $DATADUMP_PATH \
                                       --img_type syn \
                                       --samples $SAMPLES

