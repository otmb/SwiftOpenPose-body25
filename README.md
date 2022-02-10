This is a verification that the lightweight-human-pose-estimation works with OpenPose body25.

## Installation

```
$ git clone https://github.com/otmb/SwiftOpenPose-body25.git
$ cd SwiftOpenPose-body25
$ bash install.sh
$ open PoseDetection/PoseDetection.xcodeproj
```

### Build and prepare yourself

- XcodeにOpenPoseモデルを用意する
    - [OpenPose Model to CoreML convert](convert/)
- XcodeにOpenCVをXCFrameworkで用意する
    - [Minimum OpenCV](minimum_opencv.md)

## PoseDecoder 

[Daniil-Osokin](https://github.com/Daniil-Osokin)のlightweight-human-pose-estimationのCPP版を部分移植。 

- C++実装
    - [openvinotoolkit/open_model_zoo](https://github.com/openvinotoolkit/open_model_zoo)
    - この辺のコードを取得
        - [openpose_decoder.cpp](https://github.com/openvinotoolkit/open_model_zoo/blob/master/demos/common/cpp/models/src/openpose_decoder.cpp)
        - [hpe_model_openpose.cpp](https://github.com/openvinotoolkit/open_model_zoo/blob/master/demos/common/cpp/models/src/hpe_model_openpose.cpp)

### Features
- [x] SwiftでのOpenPose推論
- [x] PCM/PAFコアの処理移植
- [x] CPPコードのSwift Package対応
- [x] 推論前処理: Padding移植
- [x] 推論後処理: Upsampling移植

## Citation

    @article{8765346,
      author = {Z. {Cao} and G. {Hidalgo Martinez} and T. {Simon} and S. {Wei} and Y. A. {Sheikh}},
      journal = {IEEE Transactions on Pattern Analysis and Machine Intelligence},
      title = {OpenPose: Realtime Multi-Person 2D Pose Estimation using Part Affinity Fields},
      year = {2019}
    }

    @inproceedings{simon2017hand,
      author = {Tomas Simon and Hanbyul Joo and Iain Matthews and Yaser Sheikh},
      booktitle = {CVPR},
      title = {Hand Keypoint Detection in Single Images using Multiview Bootstrapping},
      year = {2017}
    }

    @inproceedings{cao2017realtime,
      author = {Zhe Cao and Tomas Simon and Shih-En Wei and Yaser Sheikh},
      booktitle = {CVPR},
      title = {Realtime Multi-Person 2D Pose Estimation using Part Affinity Fields},
      year = {2017}
    }

    @inproceedings{wei2016cpm,
      author = {Shih-En Wei and Varun Ramakrishna and Takeo Kanade and Yaser Sheikh},
      booktitle = {CVPR},
      title = {Convolutional pose machines},
      year = {2016}
    }

    @inproceedings{osokin2018lightweight_openpose,
        author={Osokin, Daniil},
        title={Real-time 2D Multi-Person Pose Estimation on CPU: Lightweight OpenPose},
        booktitle = {arXiv preprint arXiv:1811.12004},
        year = {2018}
    }