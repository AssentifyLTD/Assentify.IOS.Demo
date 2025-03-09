
import UIKit
import AVFoundation
import AssentifySdk

class PassportController: UIViewController ,ScanPassportDelegate
{
   
    
    

    private var assentifySdk:AssentifySdk?;
    private var configModel:ConfigModel?;

    init(assentifySdk: AssentifySdk,configModel:ConfigModel) {
          self.assentifySdk = assentifySdk
          self.configModel = configModel
          super.init(nibName: nil, bundle: nil)
      }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        UIApplication.shared.isStatusBarHidden = false;
        DispatchQueue.main.async {
            var scanPassport =  self.assentifySdk?.startScanPassport(scanPassportDelegate:self)
            self.addChild(scanPassport!)
            self.view.addSubview(scanPassport!.view)
            scanPassport!.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scanPassport!.view.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 0),
                scanPassport!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                scanPassport!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                scanPassport!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            ])
            scanPassport!.didMove(toParent: self)
    
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
    }
    
    func onError(dataModel: RemoteProcessingModel) {
    }
    
    
    func onRetry(dataModel: RemoteProcessingModel) {
    }
    
    func onLivenessUpdate(dataModel: RemoteProcessingModel) {
    }
    
  
    func onClipPreparationComplete(dataModel: RemoteProcessingModel) {
    }
    
    func onStatusUpdated(dataModel: RemoteProcessingModel) {
    }
    
    func onUpdated(dataModel: RemoteProcessingModel) {
    }
    
    var image = "";
    var idOutputProperties: [String: Any]? = [:]
    
    func onComplete(dataModel: PassportResponseModel) {
        
        // You Can Use One Of These 
        dataModel.passportExtractedModel?.identificationDocumentCapture?.IsExpired //
        dataModel.passportExtractedModel?.identificationDocumentCapture?.Expiry_Date //
        
        
        self.image = dataModel.passportExtractedModel!.imageUrl!
        print("Image" , self.image)
        dataModel.passportExtractedModel?.outputProperties?.forEach({ (key: String, value: Any) in
            self.idOutputProperties?[key] = value;
        })
        
    
            if let url = URL(string:self.image) {
                self.imageToBase64(from: url) { base64String in
                    DispatchQueue.main.async {
                    let faceViewController = FaceMatchController(assentifySdk: self.assentifySdk!, image:base64String!,configModel: self.configModel,idOutputProperties:self.idOutputProperties)
                    self.navigationController?.pushViewController(faceViewController, animated: true)
                    }
                }
            } else {
                print("Invalid URL")
            }
        
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
    
    func onEnvironmentalConditionsChange(   brightnessEvents: BrightnessEvents,
                                            motion: MotionType,
                                            zoom: ZoomType) {
        print("onEnvironmentalConditionsChange" , brightnessEvents.rawValue)
    }
 
   
    func imageToBase64(from url: URL, completion: @escaping (String?) -> Void) {
        
        var request = URLRequest(url: url)
        
        let headers = ["X-Api-Key": "7UXZBSN2CeGxamNnp9CluLJn7Bb55lJo2SjXmXqiFULyM245nZXGGQvs956Fy5a5s1KoC4aMp5RXju8w"]

        for (headerField, headerValue) in headers {
            request.setValue(headerValue, forHTTPHeaderField: headerField)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let imageData = data, error == nil else {
                print("Failed to download image from URL: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            let base64String = imageData.base64EncodedString()
            
            completion(base64String)
        }
        
        task.resume()
    }

}



