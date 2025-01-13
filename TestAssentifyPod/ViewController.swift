//
//  ViewController.swift
//  TestAssentifyPod
//
//  Created by TariQ on 03/06/2024.
//
import AssentifySdk
import UIKit


class ViewController: UIViewController , AssentifySdkDelegate{
  


    let environmentalConditions = EnvironmentalConditions(
        enableDetect: true, enableGuide: true,
          BRIGHTNESS_HIGH_THRESHOLD: 500.0,
          BRIGHTNESS_LOW_THRESHOLD: 0.0,
          PREDICTION_LOW_PERCENTAGE: 50.0,
          PREDICTION_HIGH_PERCENTAGE: 100.0,
          CustomColor: "#FFC400",
          HoldHandColor: "#FFC400"
      )
    
   
    
    private var assentifySdk :AssentifySdk?
    private var configModel :ConfigModel?

    
    let yellowColor = "🔥 -> ";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assentifySdk = AssentifySdk(
                apiKey: "",
                tenantIdentifier: "",
                interaction: "",
                environmentalConditions: self.environmentalConditions,
                assentifySdkDelegate: self,
                processMrz: true,
                storeCapturedDocument: true,
                performLivenessDocument:false,
                performLivenessFace: false,
                saveCapturedVideoID: true,
                saveCapturedVideoFace: true
            )
        
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func onAssentifySdkInitError(message: String) {
        print("\(yellowColor) -> onAssentifySdkInitError \(message)")
    }
    
    func onAssentifySdkInitSuccess(configModel: ConfigModel) {
        self.configModel = configModel;
        var templates =  assentifySdk?.getTemplates();
        print("\(yellowColor) -> onAssentifySdkInitSuccess \(configModel)")
        print("\(yellowColor) -> onHasTemplates \(templates)")

        // --------------------  ID Flow  -------------------- //
        
        // Define instances of KycDocumentDetails For Test
        let document1 = KycDocumentDetails(
            name: "ID Front",
            order: 0,
            templateProcessingKeyInformation: "75b683bb-eb81-4965-b3f0-c5e5054865e7",
            templateSpecimen: ""
        )

        let document2 = KycDocumentDetails(
            name: "ID Back",
            order: 1,
            templateProcessingKeyInformation: "eae46fac-1763-4d31-9acc-c38d29fe56e4",
            templateSpecimen: ""
        )
        // Create an array of KycDocumentDetails
        let documentsList: [KycDocumentDetails] = [document1, document2]
        
//        
//        DispatchQueue.main.async {
//            let idController = IDController(assentifySdk: self.assentifySdk!, kycDocumentDetails: documentsList,configModel:self.configModel!)
//            self.navigationController?.pushViewController(idController, animated: true)
//        }
        
        
        // --------------------  Passport Flow  -------------------- //
        
        DispatchQueue.main.async {       let idController = PassportController(assentifySdk: self.assentifySdk! ,configModel:self.configModel!)
                    self.navigationController?.pushViewController(idController, animated: true)
    }
        // --------------------  Other Flow  -------------------- //
        
//        DispatchQueue.main.async {
//            let idController = OtherController(assentifySdk: self.assentifySdk! ,configModel:self.configModel!)
//            self.navigationController?.pushViewController(idController, animated: true)
//        }
        
    }
    
     
    
    
    
   
 
 
    
  
}
