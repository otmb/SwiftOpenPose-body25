## Minimum OpenCV And Create XCFrameworks

```
$ git clone https://github.com/opencv/opencv.git
$ cd opencv
$ git checkout -b 4.5.5 refs/tags/4.5.5  

$ python3 platforms/ios/build_framework.py ios \
`cat ../opencv_option.txt` \
--build_only_specified_archs True \
--iphoneos_archs arm64

$ python3 platforms/ios/build_framework.py ios_simulator \
`cat ../opencv_option.txt` \
--build_only_specified_archs True \
--iphonesimulator_archs x86_64 

$ xcodebuild -create-xcframework  \
-framework ios/opencv2.framework \
-framework ios_simulator/opencv2.framework \
-output opencv2.xcframework
```
