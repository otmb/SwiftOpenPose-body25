import coremltools
from coremltools.models.neural_network import quantization_utils
import coremltools.proto.FeatureTypes_pb2 as ft

proto_file = 'pose/body_25/pose_deploy.prototxt'
caffe_model = 'pose/body_25/pose_iter_584000.caffemodel'

coreml_model = coremltools.converters.caffe.convert((caffe_model, proto_file)
, image_input_names='image'
, image_scale=1/255.
, is_bgr=True
)

# Image (Color 656 × 368)
# MultiArray (Double)
coreml_model.save('body_25.mlmodel')
model_fp16 = quantization_utils.quantize_weights(coreml_model, nbits=16)
model_fp16.save("body_25_fp16.mlmodel")

# spec = coremltools.utils.load_spec("body_25_fp16.mlmodel")
spec = model_fp16.get_spec()

def update_multiarray_to_float(feature):
    if feature.type.HasField("multiArrayType"):
        feature.type.multiArrayType.dataType = ft.ArrayFeatureType.FLOAT32

for feature in spec.description.output:
    update_multiarray_to_float(feature)

coremltools.utils.save_spec(spec, "body_25_fp16.mlmodel")
