# OpenPose Model to CoreML convert

1. OpenPoseモデル用意

```
$ git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git
$ bash openpose/models/getModels.sh
```
2. 必要なモジュールインストール

```
$ pip install coremltools
```

3. Edit pose_deploy_linevec.prototxt

edit input_dim of pose_deploy_linevec.prototxt.  
368(height)x656(width) = multiple of 16.

```
input: "image"
input_dim: 1
input_dim: 3
input_dim: 368 # This value will be defined at runtime
input_dim: 656 # This value will be defined at runtime
```

4. OpenPoseモデル変換

```
$ python coreml_conv_body25.py
```
