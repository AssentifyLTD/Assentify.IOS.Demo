
import UIKit
import AVFoundation
import AssentifySdk

class OtherController: UIViewController ,ScanOtherDelegate
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
            var scanID =  self.assentifySdk?.startScanOthers(scanOtherDelegate: self)
            self.addChild(scanID!)
            self.view.addSubview(scanID!.view)
            scanID!.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scanID!.view.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 0),
                scanID!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                scanID!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                scanID!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            ])
            scanID!.didMove(toParent: self)
    
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
    
    func onWrongTemplate(dataModel:RemoteProcessingModel) {
    }
    
    func onClipPreparationComplete(dataModel: RemoteProcessingModel) {
    }
    
    func onStatusUpdated(dataModel: RemoteProcessingModel) {
    }
    
    func onUpdated(dataModel: RemoteProcessingModel) {
    }
    
 
    
    var image = "";
    var idOutputProperties: [String: Any]? = [:]
    
    func onComplete(dataModel: OtherResponseModel) {
        self.image = dataModel.otherExtractedModel!.imageUrl!
        dataModel.otherExtractedModel?.outputProperties?.forEach({ (key: String, value: Any) in
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
    
    func onEnvironmentalConditionsChange(brightness: Double, motion: MotionType, zoom: ZoomType) {
        
    }
 
    func imageToBase64(from url: URL, completion: @escaping (String?) -> Void) {
        
        var request = URLRequest(url: url)
        
        let headers = ["X-Api-Key": "Your Api Key"]

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



