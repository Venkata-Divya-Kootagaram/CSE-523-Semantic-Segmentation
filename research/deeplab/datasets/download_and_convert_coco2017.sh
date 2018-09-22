#!/bin/bash
# Copyright 2018 The TensorFlow Authors All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#
# Script to download and preprocess the COCO2017 dataset.
#
# Usage:
#   bash ./download_and_convert_voc2012.sh
#
# The folder structure is assumed to be:
#  + datasets
#     - build_data.py
#     - build_voc2012_data.py
#     - download_and_convert_voc2012.sh
#     - remove_gt_colormap.py
#     + pascal_voc_seg
#       + VOCdevkit
#         + VOC2012
#           + JPEGImages
#           + SegmentationClass
#

# Exit immediately if a command exits with a non-zero status.
set -e

CURRENT_DIR=$(pwd)
WORK_DIR="./coco_seg"
mkdir -p "${WORK_DIR}"
ANNOTATE_DIR="${WORK_DIR}/annotations/"
mkdir -p "${ANNOTATE_DIR}"
#mkdir -p "${WORK_DIR}/images/"
cd "${WORK_DIR}"

# Helper function to download and unpack VOC 2012 dataset.
download_and_uncompress() {
  local BASE_URL=${1}
  local FILENAME=${2}

  if [ ! -f "${FILENAME}" ]; then
    echo "Downloading ${FILENAME} to ${WORK_DIR}"
    wget -nd -c "${BASE_URL}/${FILENAME}"
  fi
  echo "Uncompressing ${FILENAME}"
  unzip "${FILENAME}"
 
}

# Helper function2 to download and unpack VOC 2012 dataset.
download_and_uncompress_images() {
  local BASE_URL=${1}
  local FILENAME=${2}

  if [ ! -f "${FILENAME}" ]; then
    echo "Downloading ${FILENAME} to ${WORK_DIR}"
    wget -nd -c "${BASE_URL}/${FILENAME}"
  fi
  echo "Uncompressing ${FILENAME}"
  unzip "${FILENAME}"

}

# Download the images.
BASE_URL="http://images.cocodataset.org/annotations"
FILENAME="annotations_trainval2017.zip"

BASE_URL2="http://images.cocodataset.org/zips"
FILENAME2="train2017.zip"

BASE_URL3="http://images.cocodataset.org/zips"
FILENAME3="val2017.zip"

download_and_uncompress "${BASE_URL}" "${FILENAME}"

download_and_uncompress_images "${BASE_URL2}" "${FILENAME2}"

download_and_uncompress_images "${BASE_URL3}" "${FILENAME3}"

cd "${CURRENT_DIR}"

# Root path for PASCAL VOC 2012 dataset.
COCO_ROOT="${WORK_DIR}/COCO2017"

# Build TFRecords of the dataset.
# First, create output directory for storing TFRecords.
OUTPUT_DIR="${WORK_DIR}/tfrecord"
mkdir -p "${OUTPUT_DIR}"

#IMAGE_FOLDER="${COCO_ROOT}/JPEGImages"
#LIST_FOLDER="${COCO_ROOT}/ImageSets/Segmentation"

echo "Converting COCO training dataset..."
python ./build_coco2017_data.py --data_dir="${WORK_DIR}" \
        --set=train \
        --output_path="${OUTPUT_DIR}"
        --shuffle_imgs=True

echo "Converting COCO val dataset..."
python ./build_coco2017_data.py --data_dir="${WORK_DIR}" \
        --set=val \
        --output_path="${OUTPUT_DIR}"
        --shuffle_imgs=True

'''python ./build_coco2017_data.py  \
  --train_image_folder="${WORK_DIR}/train2017/" \
  --train_image_label_folder="${WORK_DIR}/annotations/" \
  --val_image_folder="${WORK_DIR}/val2017/" \
  --val_image_label_folder="${WORK_DIR}/annotations/" \
  --output_dir="${OUTPUT_DIR}" '''

