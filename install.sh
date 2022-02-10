#!/bin/bash

OPENCV_FRAMWEORK_URL="https://github.com/otmb/SwiftOpenPose-body25/releases/download/0.0.1/opencv2.xcframework.tar.gz"
COREMLMODEL_URL="https://github.com/otmb/SwiftOpenPose-body25/releases/download/0.0.1/body_25_fp16.mlmodel"

# opencv2.xcframework Model Download.
curl -L ${OPENCV_FRAMWEORK_URL} > opencv2.xcframework.tar.gz
tar xvzf opencv2.xcframework.tar.gz
mkdir ./PoseDecoder/Frameworks
mv opencv2.xcframework ./PoseDecoder/Frameworks

# CoreML Model Download.
curl -L ${COREMLMODEL_URL} > body_25_fp16.mlmodel
mv body_25_fp16.mlmodel ./PoseDetection/PoseDetection
