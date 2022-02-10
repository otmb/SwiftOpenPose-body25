import SwiftUI
import CoreML
import Vision
import PoseDecoder

struct ContentView: View {
    var sourceImg = UIImage(named: "hadou.jpg")
    
    @ObservedObject var poseDetection = PoseDetection()
    @State var performanceText = ""
    init(){
        print(measure(poseDetection.runCoreML(sourceImg: sourceImg!)).duration)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if (poseDetection.uiImage != nil){
                Image(uiImage: poseDetection.uiImage!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Button(action: {
                performanceText = measure(poseDetection.runCoreML(sourceImg: sourceImg!)).duration
            }) {
                Text("Retry CoreML Detection")
            }
            Text(performanceText)
        }.preferredColorScheme(.light)
    }
    
    func measure <T> (_ f: @autoclosure () -> T) -> (result: T, duration: String) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = f()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return (result, String(format: "Elapsed time is %0.5f seconds.", timeElapsed))
    }
}

class PoseDetection : ObservableObject {
    @Published var uiImage: UIImage?
    let coremlModel = try! body_25_fp16(configuration: MLModelConfiguration())
    let modelWidth: Int32 = 656
    let modelHeight: Int32 = 368
    var scale = CGPoint(x: 0.0,y: 0.0);
    var sourceImg: UIImage?
    
    func runCoreML(sourceImg: UIImage) {
        self.sourceImg = sourceImg
        let pose = PoseDecoder()
        let paddedImage = pose.resizeImageExt(sourceImg,
                                              modelWidth: modelWidth,
                                              modelHeight: modelHeight,
                                              scale: &scale)
        
        let cgiImage = paddedImage?.cgImage!
        let classifierRequestHandler = VNImageRequestHandler(cgImage: cgiImage!, options: [:])
        do {
            let model = try VNCoreMLModel(for: coremlModel.model)
            let request = VNCoreMLRequest(model: model, completionHandler: handleClassification)
            try classifierRequestHandler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNCoreMLFeatureValueObservation] else { fatalError() }
        let mlarray = observations[0].featureValue.multiArrayValue!
        
        let length = mlarray.count
        let floatPtr =  mlarray.dataPointer.bindMemory(to: Float32.self, capacity: length)
        let floatBuffer = UnsafeBufferPointer(start: floatPtr, count: length)

        var mm = Array(floatBuffer)
        let pose = PoseDecoder()
        self.uiImage = pose.detection(&mm,dataSize: Int32(mm.count),
                                       uiImage: sourceImg,
                                       modelWidth: modelWidth,
                                       modelHeight: modelHeight,
                                       scale: scale)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
