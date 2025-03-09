
import UIKit
import AVFoundation
import AssentifySdk

class IDController: UIViewController ,ScanIDCardDelegate
{
    
    
    
    
    
    private var assentifySdk:AssentifySdk?;
    private var configModel:ConfigModel?;
    private var _kycDocumentDetails:[KycDocumentDetails];

    let yellowColor = "🔥 -> ";
    
    init(assentifySdk: AssentifySdk,kycDocumentDetails:[KycDocumentDetails],configModel:ConfigModel) {
        self.assentifySdk = assentifySdk
        self._kycDocumentDetails = kycDocumentDetails
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
            var scanID =  self.assentifySdk?.startScanID(scanIDCardDelegate: self, kycDocumentDetails:  self._kycDocumentDetails)
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
        print("\(yellowColor) -> onSend")
    }
    
    func onError(dataModel: RemoteProcessingModel) {
        print("\(yellowColor) -> onError")
    }
    
    
    func onRetry(dataModel: RemoteProcessingModel) {
        print("\(yellowColor) -> onRetry")
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
    
    func onComplete(dataModel: IDResponseModel,order:Int) {
        print("\(yellowColor) -> onComplete \(dataModel.description) - \(order)")
        if(order == 0){
            image = (dataModel.iDExtractedModel?.imageUrl)!;
            dataModel.iDExtractedModel?.outputProperties?.forEach({ (key: String, value: Any) in
                self.idOutputProperties?[key] = value;
            })
            

        }else{
            dataModel.iDExtractedModel?.outputProperties?.forEach({ (key: String, value: Any) in
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



