
import UIKit
import AVFoundation
import AssentifySdk
class FaceMatchController: UIViewController ,FaceMatchDelegate
{
    
    
    
    private var assentifySdk:AssentifySdk?;
    private var image: String;
    private var configModel:ConfigModel?;
    public var idOutputProperties: [String: Any]?

    let yellowColor = "🔥 -> ";

    init(assentifySdk: AssentifySdk,image:String,configModel:ConfigModel?,idOutputProperties: [String: Any]?) {
        self.assentifySdk = assentifySdk
        self.image = image
        self.configModel = configModel
        self.idOutputProperties = idOutputProperties
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        UIApplication.shared.isStatusBarHidden = false

           
        DispatchQueue.main.async {
            var faceMatch =  self.assentifySdk?.startFaceMatch(faceMatchDelegate: self, secondImage:self.image,showCountDown: true)
            self.addChild(faceMatch!)
            self.view.addSubview(faceMatch!.view)
            faceMatch!.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                faceMatch!.view.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 0),
                faceMatch!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                faceMatch!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                faceMatch!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            ])
            faceMatch!.didMove(toParent: self)
        }
        
    }
    
    public  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
         return .portrait
     }
     public  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
         return .portrait
     }
     public   override var shouldAutorotate: Bool {
         return false
     }
    
    func onSend() {
        print("\(yellowColor) -> onSend")
    }
    
    func onError(dataModel: RemoteProcessingModel) {
        print("\(yellowColor) -> onError")
    }
    
    
    func onRetry(dataModel: RemoteProcessingModel) {
        print("\(yellowColor) -> onRetry")
    }
    
    func onLivenessUpdate(dataModel: RemoteProcessingModel) {  }
    
    func onClipPreparationComplete(dataModel: RemoteProcessingModel) {
    }
    
    func onStatusUpdated(dataModel: RemoteProcessingModel) {
    }
    
    func onUpdated(dataModel: RemoteProcessingModel) {
    }
    
    
    func onComplete(dataModel: FaceResponseModel) {
        print("\(yellowColor) -> onComplete ")

        if let url = URL(string:(dataModel.faceExtractedModel?.baseImageFace)!) {
            self.imageToBase64(from: url) { base64String in
              
            }
        } else {
            print("Invalid URL")
        }
        print(dataModel.faceExtractedModel!.outputProperties )
        print(dataModel.faceExtractedModel!.percentageMatch )


        
    }
    
    func onCardDetected(dataModel: RemoteProcessingModel) {
    }
    
    func onMrzExtracted(dataModel: RemoteProcessingModel) {
    }
    
    func onMrzDetected(dataModel: RemoteProcessingModel) {
    }
    
    func onNoMrzDetected(dataModel: RemoteProcessingModel) {
    }
    
    
    func onFaceDetected(dataModel: RemoteProcessingModel) {
    }
    
    func onNoFaceDetected(dataModel: RemoteProcessingModel) {
    }
    
    func onFaceExtracted(dataModel: RemoteProcessingModel) {
    }
    
    func onQualityCheckAvailable(dataModel: RemoteProcessingModel) {
    }
    
    func onDocumentCaptured(dataModel: RemoteProcessingModel) {
    }
    
    func onDocumentCropped(dataModel: RemoteProcessingModel) {
    }
    
    func onUploadFailed(dataModel: RemoteProcessingModel) {
    }
    
    
    func onEnvironmentalConditionsChange(brightness: Double, motion: MotionType) {
    }
    
 
    func imageToBase64(from url: URL, completion: @escaping (String?) -> Void) {
        var request = URLRequest(url: url)
        
        // Set headers for the request
        let headers = ["X-Api-Key": "7UXZBSN2CeGxamNnp9CluLJn7Bb55lJo2SjXmXqiFULyM245nZXGGQvs956Fy5a5s1KoC4aMp5RXju8w"]
        for (headerField, headerValue) in headers {
            request.setValue(headerValue, forHTTPHeaderField: headerField)
        }
        
        // Make a HEAD request to fetch the Content-Length without downloading the image
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { _, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("Failed to fetch response headers: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            // Get the Content-Length header to calculate the size in MB
            if let contentLengthString = httpResponse.allHeaderFields["Content-Length"] as? String,
               let contentLength = Double(contentLengthString) {
                let sizeInMB = contentLength / (1024.0 * 1024.0)
                print(String(format: "Image size: %.2f MB", sizeInMB))
            } else {
                print("Content-Length header not found")
            }
            
            // Proceed to download the image
            var downloadRequest = URLRequest(url: url)
            for (headerField, headerValue) in headers {
                downloadRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
            
            URLSession.shared.dataTask(with: downloadRequest) { data, _, error in
                guard let imageData = data, error == nil else {
                    print("Failed to download image: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                    return
                }
                
                // Convert the image data to Base64
                let base64String = imageData.base64EncodedString()
                completion(base64String)
            }.resume()
        }.resume()
    }

   
    
}

