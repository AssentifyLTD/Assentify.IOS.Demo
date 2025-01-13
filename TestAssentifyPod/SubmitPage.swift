//
//  SubmitPage.swift
//  TestAssentifyPod
//
//  Created by TariQ on 05/09/2024.
//


import UIKit
import AVFoundation
import AssentifySdk
class SubmitPage: UIViewController , SubmitDataDelegate
{
    
    
    
    private var assentifySdk:AssentifySdk?;
    private var configModel:ConfigModel?;
    public var idOutputProperties: [String: Any]?
    public var faceOutputProperties: [String: Any]?

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

        submitData();
        
    }
    
    /// Submit Data
   
    func submitData(){
        print("\(yellowColor) -> Start Submiting Data")
        
        let outputPropertiesModelID = self.idOutputProperties;
        let outputPropertiesModelFace = self.faceOutputProperties;
        
        
        // Initialize the SubmitRequestModel instances
        var wrapUp: SubmitRequestModel? = nil
        var blockLoader: SubmitRequestModel? = nil
        var sharedStepDefinitionsStepDoc: SubmitRequestModel? = nil
        var sharedStepDefinitionsStepFace: SubmitRequestModel? = nil
        
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

