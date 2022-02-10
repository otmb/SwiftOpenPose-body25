#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#include <iostream>
#include <vector>

#import "PoseDecoder.h"
#import "hpe_model_openpose.h"
#import "utils/image_utils.h"
#import <mach/mach_time.h>
#import <CoreML/MLModel.h>
#import <Vision/Vision.h>

@implementation PoseDecoder

-(UIImage*) detection: (float *) data
             dataSize: (int) dataSize
            uiImage: (UIImage*) uiImage
           modelWidth: (int) modelWidth
          modelHeight: (int) modelHeight
                scale: (CGPoint) scale
{
    uint64_t start, elapsed;
    start = mach_absolute_time();
    
    int imgW = uiImage.size.width;
    int imgH = uiImage.size.height;
    int dim2 = modelHeight / 8;
    int dim3 = modelWidth / 8;
    
    int keypointsNumber = HPEOpenPose::keypointsNumber;
    
    std::cout << "imgSize: " << imgW << "x" << imgH << std::endl;
    std::cout << "keypoint: " << keypointsNumber << std::endl;

    int mapIdxOffset = keypointsNumber + 1;
    std::vector<float> vec(&data[0], data + dataSize);
    std::vector<float>
                hvec(vec.begin(), vec.begin() + mapIdxOffset*dim2*dim3),
                pvec(vec.begin() + mapIdxOffset*dim2*dim3, vec.end());
    
    std::cout << "hvec: " << hvec.size() << std::endl;
    std::cout << "matrix: " << mapIdxOffset << "x" << dim2 << "x" << dim3 << std::endl;
    
    float* predictions = &pvec[0];
    float* heats = &hvec[0];
    
    std::vector<cv::Mat> heatMaps(mapIdxOffset);
    for (size_t i = 0; i < heatMaps.size(); i++) {
        heatMaps[i] = cv::Mat(dim2, dim3, CV_32FC1, heats + i * dim2 * dim3);
    }
    std::vector<cv::Mat> pafs(mapIdxOffset * 2);
    for (size_t i = 0; i < pafs.size(); i++) {
        pafs[i] = cv::Mat(dim2, dim3, CV_32FC1,
                       predictions + i * dim2 * dim3);
    }
    
    auto hpe = new HPEOpenPose(0.1);
    hpe->resizeFeatureMaps(heatMaps);
    hpe->resizeFeatureMaps(pafs);
    
    std::vector<HumanPose> poses = hpe->extractPoses(heatMaps, pafs);
    std::cout << "pose: " << poses.size() << std::endl;
    
    float upsampleRatio = (float) HPEOpenPose::upsampleRatio;
    float scaleX = 8.0 / upsampleRatio * scale.x;
    float scaleY = 8.0 / upsampleRatio * scale.y;
    
    for (auto& pose : poses) {
        for (auto& keypoint : pose.keypoints) {
            if (keypoint != cv::Point2f(-1, -1)) {
                keypoint.x *= scaleX;
                keypoint.y *= scaleY;
            }
        }
    }
    
    elapsed = mach_absolute_time() - start;
    double e = elapsed / 1000000000.0; // second
    std::cout << "PCM/PAF time is " << e << " seconds." << std::endl;
    
    delete(hpe);
    vec.clear();
    hvec.clear();
    pvec.clear();
    
    return renderHumanPose(poses, uiImage);
}

UIImage* renderHumanPose(std::vector<HumanPose> poses, UIImage* uiImage){
    
    if (poses.size() < 1){
        return uiImage;
    }
    cv::Mat outputImg;
    UIImageToMat(uiImage, outputImg);
    cv::cvtColor(outputImg, outputImg, cv::COLOR_RGB2RGBA);

    static const cv::Scalar colors[HPEOpenPose::keypointsNumber] = {
        cv::Scalar(255,  0, 85), cv::Scalar(255,  0,  0),
        cv::Scalar(255, 85,  0), cv::Scalar(255,170,  0),
        cv::Scalar(255,255,  0), cv::Scalar(170,255,  0),
        cv::Scalar( 85,255,  0), cv::Scalar(  0,255,  0),
        cv::Scalar(255,  0,  0), cv::Scalar(  0,255, 85),
        cv::Scalar(  0,255,170), cv::Scalar(  0,255,255),
        cv::Scalar(  0,170,255), cv::Scalar(  0, 85,255),
        cv::Scalar(  0,  0,255), cv::Scalar(255,  0,170),
        cv::Scalar(170,  0,255), cv::Scalar(255,  0,255),
        cv::Scalar( 85,  0,255), cv::Scalar(0  ,  0,255),
        cv::Scalar(  0,  0,255), cv::Scalar(0  ,  0,255),
        cv::Scalar(  0,255,255), cv::Scalar(0  ,255,255),
        cv::Scalar(  0,255,255)
    };
    
    static const std::pair<int, int> keypointsOP[] = {
        {1, 8}, {1, 2}, {1, 5}, {2, 3}, {3, 4}, {5, 6}, {6, 7},
        {8, 9}, {9, 10}, {10, 11}, {8, 12}, {12, 13}, {13, 14},
        {1, 0}, {0, 15}, {15, 17}, {0, 16}, {16, 18},
        {2, 17}, {5, 18}, {14, 19}, {19, 20},
        {14, 21}, {11, 22}, {22, 23}, {11, 24}
    };

    const int stickWidth = 4;
    const cv::Point2f absentKeypoint(-1.0f, -1.0f);
    for (auto& pose : poses) {
        for (size_t keypointIdx = 0; keypointIdx < pose.keypoints.size(); keypointIdx++) {
            if (pose.keypoints[keypointIdx] != absentKeypoint) {
                cv::circle(outputImg, pose.keypoints[keypointIdx], 4, colors[keypointIdx], -1);
            }
        }
    }
    
    std::vector<std::pair<int, int>> limbKeypointsIds;
    if (!poses.empty()) {
        limbKeypointsIds.insert(limbKeypointsIds.begin(), std::begin(keypointsOP), std::end(keypointsOP));
    }
    
    cv::Mat pane = outputImg.clone();
    for (auto pose : poses) {
        for (const auto& limbKeypointsId : limbKeypointsIds) {
            if ((limbKeypointsId.first == 2 && limbKeypointsId.second == 17)
                || (limbKeypointsId.first == 5 && limbKeypointsId.second == 18)){
                continue;
            }
            std::pair<cv::Point2f, cv::Point2f> limbKeypoints(pose.keypoints[limbKeypointsId.first],
                    pose.keypoints[limbKeypointsId.second]);
            if (limbKeypoints.first == absentKeypoint
                    || limbKeypoints.second == absentKeypoint) {
                continue;
            }

            float meanX = (limbKeypoints.first.x + limbKeypoints.second.x) / 2;
            float meanY = (limbKeypoints.first.y + limbKeypoints.second.y) / 2;
            cv::Point difference = limbKeypoints.first - limbKeypoints.second;
            double length = std::sqrt(difference.x * difference.x + difference.y * difference.y);
            int angle = static_cast<int>(std::atan2(difference.y, difference.x) * 180 / CV_PI);
            std::vector<cv::Point> polygon;
            cv::ellipse2Poly(cv::Point2d(meanX, meanY), cv::Size2d(length / 2, stickWidth),
                             angle, 0, 360, 1, polygon);
            cv::fillConvexPoly(pane, polygon, colors[limbKeypointsId.second]);
        }
    }
    cv::addWeighted(outputImg, 0.4, pane, 0.6, 0, outputImg);
    
    UIImage *preview = MatToUIImage(outputImg);
    outputImg.release();
    return preview;
}


-(UIImage*) resizeImageExt: (UIImage*) uiImage
                modelWidth: (int) modelWidth
               modelHeight: (int) modelHeight
                     scale: (CGPoint *) scale
{
    cv::Mat image;
    UIImageToMat(uiImage, image);
    
    cv::Rect roi;
    auto paddedImage = resizeImageExt(image, modelWidth, modelHeight, RESIZE_KEEP_ASPECT, true, &roi);
    std::cout << "roi: " << roi.width << "x" << roi.height << std::endl;
    
    scale->x = (CGFloat)uiImage.size.width / (CGFloat)roi.width;
    scale->y = (CGFloat)uiImage.size.height / (CGFloat)roi.height;
    return MatToUIImage(paddedImage);
}

@end


