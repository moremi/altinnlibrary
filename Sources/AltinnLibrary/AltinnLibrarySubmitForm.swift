//
//  File.swift
//  
//
//  Created by Faizan Abid on 31/3/20.
//

import Foundation
import AEXML

//completion: @escaping (UpdateFormResponse?, Error?) -> ()
extension AltinnLibrary {
    public func attachRf1189Form(user: UserLoginInput, system: SystemLoginInput, auth: AuthInput,
                                 rf1030FormId: String, rf1189Form: RF1189FormData, completion: @escaping (UpdateFormResponse?, Error?) -> ()){
        guard let url = URL(string: "\(testMode ? Constants.testAltinnUrl : Constants.baseAltinnUrl)\(EndPoints.updateForms)") else {
            print("Error occurred while parsing URL")
            return
        }
        let action = Actions.updateFormsAction
        
        guard let envelope = try? AEXMLDocument(xml: XmlTemplates.updateFormData) else {
            print("Error occurred while parsing XML")
            return
        }
        
        envelope.root["soapenv:Body"]["ns:UpdateFormDataBasic"].appendAuthenticationElements(user: user, system: system, auth: auth)
        
        envelope.root["soapenv:Body"]["ns:UpdateFormDataBasic"]["ns:formTaskUpdate"]["ns1:ReporteeElementId"].value = rf1030FormId
        
        let formUpdateElement = AEXMLElement(name: "ns1:FormUpdate")
        formUpdateElement.addChild(name: "ns1:DataFormatId", value: Constants.rf1189dataFormatId)
        formUpdateElement.addChild(name: "ns1:DataFormatVersion", value: Constants.rf1189dataFormatVersion)
        formUpdateElement.addChild(name: "ns1:EndUserSystemReference", value: "1")
        
        
        do {
            
            guard let rf1189FormXml = try? rf1189Form.getXml() else {
                print("rf1189FormXml parse error!")
                throw AltinnLibraryError.xmlParseError
            }
            
            let form = "<![CDATA[" + rf1189FormXml.xml + "]]>"

            formUpdateElement.addChild(name: "ns1:FormData", value: "***DATA***")
            formUpdateElement.addChild(name: "ns1:FormId", value: "0") //if multiple forms this should increment
            envelope.root["soapenv:Body"]["ns:UpdateFormDataBasic"]["ns:formTaskUpdate"]["ns1:FormUpdateList"].addChild(formUpdateElement)
            
            //in order to avoid an issue where all the cdata gets escaped, we replace the cdata within a string
            let envelopeWithFormData = envelope.xml.replacingOccurrences(of: "***DATA***", with: form)

            print("SOAP Envelope: \(envelopeWithFormData)")
            
            SoapManager.send(toEndPoint: url, withAction: action, withEnvelope: envelopeWithFormData) { response in
                if response.error != nil {
                    //print("Error: \(response.error)")
                    completion(nil, response.error)
                    return
                }

                do {
                    let result = try parseStringToSoapResponse(data: response.data)
                    //print("Result:\n\(result.hasFault())")

                    //check if any fault occurred and handle that
                    if result.hasFault() {
                        throw getAltinnError(xml: result.getFault())
                    }

                    //check if UpdateFormDataBasicResult exists; if not throw error
                    let updateFormDataResultElement = result.root["s:Body"]["UpdateFormDataBasicResponse"]["UpdateFormDataBasicResult"]
                    if !updateFormDataResultElement.exists() {
                        throw AltinnLibraryError.elementNotFound("UpdateFormDataBasicResponse -> UpdateFormDataBasicResult")
                    }

                    let updateFormDataResult = UpdateFormResponse(updateFormDataResult: updateFormDataResultElement)


                    //print("updateFormDataResult:\n\(updateFormDataResult)")
                    completion(updateFormDataResult, nil)

                } catch {
                    //print("Error: \(error)")
                    completion(nil, error)
                }

            }
            
        } catch {
            //print("Error: \(error)")
            completion(nil, error)
        }
    }
}
