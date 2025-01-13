//
//  SubmitController.swift
//  TestAssentifyPod
//
//  Created by TariQ on 05/09/2024.
//


import UIKit
import AVFoundation
import AssentifySdk
class SubmitController: UIViewController , SubmitDataDelegate , ContextAwareDelegate
{
    
    
    
    private var assentifySdk:AssentifySdk?;
    private var configModel:ConfigModel?;
    public var idOutputProperties: [String: Any]?
    public var faceOutputProperties: [String: Any]?
    private var  contextAwareSigning   :ContextAwareSigning?

    let yellowColor = "🔥 -> ";

    init(assentifySdk: AssentifySdk,configModel:ConfigModel?,idOutputProperties: [String: Any]?,faceOutputProperties: [String: Any]?) {
        self.assentifySdk = assentifySdk
        self.configModel = configModel
        self.idOutputProperties = idOutputProperties
        self.faceOutputProperties = faceOutputProperties
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear

        /** IF You Have Context Aware Step **/
         contextAwareSigning = assentifySdk?.startContextAwareSigning(contextAwareDelegate:self);
        
    }
    
    
       func onHasTokens(documentTokens: [DocumentTokensModel]) {
           print("onHasTokens")
           var data: [String : String] = [:];
           documentTokens.forEach(){item in
               print(item.displayName + " : " + item.tokenValue)
               data[item.id.description]="iOS Test"
           }
           contextAwareSigning?.createUserDocumentInstance(data: data);
           
       }
       
       func onCreateUserDocumentInstance(userDocumentResponseModel: CreateUserDocumentResponseModel) {
           print("onCreateUserDocumentInstance " + userDocumentResponseModel.templateInstanceId.description)
           print("onCreateUserDocumentInstance " + userDocumentResponseModel.templateInstance)
           ///
           contextAwareSigning?.signature(documentId: userDocumentResponseModel.documentId,documentInstanceId: userDocumentResponseModel.templateInstanceId, signature: "iVBORw0K...")
       }
       
       func onSignature(signatureResponseModel: SignatureResponseModel) {
           print("onSignature " + signatureResponseModel.signedDocument)
           print("onSignature " + signatureResponseModel.signedDocumentUri)
           submitData(signedDocumentUri: signatureResponseModel.signedDocumentUri);
       }
       
       func onError(message: String) {
           print("onError " + message)
       }
    
    /// Submit Data
   
    func submitData(signedDocumentUri:String){
        print("\(yellowColor) -> Start Submiting Data")
        
        let outputPropertiesModelID = self.idOutputProperties;
        let outputPropertiesModelFace = self.faceOutputProperties;
        
        
        // Initialize the SubmitRequestModel instances
        var wrapUp: SubmitRequestModel? = nil
        var blockLoader: SubmitRequestModel? = nil
        var sharedStepDefinitionsStepDoc: SubmitRequestModel? = nil
        var sharedStepDefinitionsStepFace: SubmitRequestModel? = nil
        var sharedStepDefinitionsSignature: SubmitRequestModel? = nil
        
        let steps  =   self.configModel?.stepDefinitions;
        
        steps?.forEach { item in
            
            /** DocumentCapture **/
            if item.stepDefinition == StepsName.DocumentCapture {
                var values: [String: String] = [:]
                outputPropertiesModelID?.forEach { (key, value) in
                    if let unwrappedValue = value as? String {
                        if unwrappedValue != "<null>" {
                            values[key] = "\(unwrappedValue)"
                        }
                    }
               
                }
                    sharedStepDefinitionsStepDoc = SubmitRequestModel(
                    stepId: item.stepId,
                    stepDefinition: StepsName.DocumentCapture,
                    extractedInformation: values
                )
            }
            
            /** FaceMatch **/
            if item.stepDefinition == StepsName.FaceMatch {
                var values: [String: String] = [:]
                faceOutputProperties?.forEach { (key, value) in
                    if let unwrappedValue = value as? String {
                        if unwrappedValue != "<null>" {
                            values[key] = "\(unwrappedValue)"
                        }
                    }
                }
                
                sharedStepDefinitionsStepFace = SubmitRequestModel(
                    stepId: item.stepId,
                    stepDefinition: StepsName.FaceMatch,
                    extractedInformation: values
                )
            }
            
            /** ContextAwareSigning **/
            if item.stepDefinition == StepsName.ContextAwareSigning {
                var values: [String: String] = [:]
                item.outputProperties.forEach { property in
                    if property.key.contains("OnBoardMe_ContextAwareSigning_DocumentURL") {
                        values[property.key] = signedDocumentUri
                     }
                 }
                
                sharedStepDefinitionsSignature = SubmitRequestModel(
                    stepId: item.stepId,
                    stepDefinition: StepsName.ContextAwareSigning,
                    extractedInformation: values
                )
            }
            
            /** WrapUp **/
            if item.stepDefinition == StepsName.WrapUp {
                var values: [String: String] = [:]
                item.outputProperties.forEach { property in
                    if property.key.contains("TimeEnded") {
                        values[property.key] = getCurrentDateTime()
                     }
                 }
                
                wrapUp = SubmitRequestModel(
                    stepId: item.stepId,
                    stepDefinition: StepsName.WrapUp,
                    extractedInformation: values
                )
            }
            
            /** BlockLoader **/
            if item.stepDefinition == StepsName.BlockLoader {
                var values: [String: String] = [:]
                item.outputProperties.forEach { property in
                    print(property.key)
                    if property.key.contains("TimeStarted") {
                        values[property.key] = getCurrentDateTime()
                    }
                    if property.key.contains("DeviceName") {
                        values[property.key] = "ENTER YOUR DEVICE NAME HERE"
                    }
                    if property.key.contains("Application") {
                        values[property.key] = "ENTER YOUR APPLICATION HERE"
                    }
                    if property.key.contains("FlowName") {
                        values[property.key] = "ENTER YOUR FLOW NAME HERE"
                    }
                    if property.key.contains("InstanceHash") {
                        values[property.key] = "ENTER YOUR INSTANCE HASH HERE"
                    }
                    if property.key.contains("UserAgent") {
                        values[property.key] = "ENTER YOUR USER AGENT HERE"
                    }
                    if property.key.contains("Interaction") {
                        values[property.key] = "ENTER YOUR INTERACTION ID HERE"
                    }
                    if property.key.contains("phoneNumber") {
                        values[property.key] = "1000"
                    }
                    if property.key.contains("userName") {
                        values[property.key] = "SDK TEST"
                    }
                }
                
                blockLoader = SubmitRequestModel(
                    stepId: item.stepId,
                    stepDefinition: StepsName.BlockLoader,
                    extractedInformation: values
                )
                
            }
        }
        
        
        // Collect all created SubmitRequestModel instances into a list
        var listData: [SubmitRequestModel] = []
        if let doc = sharedStepDefinitionsStepDoc {
            listData.append(doc)
        }
        if let face = sharedStepDefinitionsStepFace {
            listData.append(face)
        }
        if let signature = sharedStepDefinitionsSignature {
            listData.append(signature)
        }
        if let wrap = wrapUp {
            listData.append(wrap)
        }
        if let block = blockLoader {
            listData.append(block)
        }
        
        print("\(yellowColor) -> SubmitRequestModel : " + listData.description)
        
        _ =  self.assentifySdk?.startSubmitData(submitDataDelegate: self, submitRequestModel:listData)

    }
    

    func onSubmitError(message: String) {
        print("\(yellowColor) -> onSubmitError")
    }
    
    func onSubmitSuccess() {
        print("\(yellowColor) -> onSubmitSuccess")
    }
    func getCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return formatter.string(from: Date())
    }
    
}

