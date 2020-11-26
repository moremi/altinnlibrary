//
//  File.swift
//  
//
//  Created by Faizan Abid on 31/3/20.
//

import Foundation
import AEXML

//completion: @escaping ([ReporteeElement]?, Error?) -> ()
extension AltinnLibrary {
    //assumed that we are only submitting for current year
    public func getRf1030Forms(user: UserLoginInput, system: SystemLoginInput,auth: AuthInput, language: Language = .bokmal,
                               completion: @escaping ([ReporteeElement]?, Error?) -> ()){
        guard let url = URL(string: "\(testMode ? Constants.testAltinnUrl : Constants.baseAltinnUrl)\(EndPoints.getForms)") else {
            print("Error occurred while parsing URL")
            return
        }
        let action = Actions.getFormsAction
        
        guard let envelope = try? AEXMLDocument(xml: XmlTemplates.getReporteeElementList) else {
            print("Error occurred while parsing XML")
            return
        }
        
        
        do{
            let calendar = Calendar.current
            let today = Date()
            //check if we support the year
            let currentYear = calendar.component(.year, from: today)
            if(currentYear != Constants.supportedYear){
                throw AltinnLibraryError.yearNotSupported("AltinnLibrary only supports submitting for \(Constants.supportedYear) (tax year: 2019). The year found for today is \(currentYear)")
            }
            
            //build fromdate which is start of the current year
            var dateComponents = DateComponents()
            dateComponents.year = currentYear
            dateComponents.month = 1
            dateComponents.day = 1
            
            guard let fromDate = Calendar.current.date(from: dateComponents) else {
                throw AltinnLibraryError.objectWasNil("building fromDate from Calendar resulted in nil date")
            }
            print("fromDate: \(fromDate.toSimpleString())")
            
            //start building envelope
            //add 30 hours for toDate since altinn sometimes doesnt show the latest forms if today is sent
            let search = SearchFormInput(fromDate: fromDate, toDate: today.addingTimeInterval(30*60*60), reportee: user.userSsn).getAsXml()
            
            envelope.root["soapenv:Body"]["ns:GetReporteeElementListBasicV2"].appendAuthenticationElements(user: user, system: system, auth: auth)
            envelope.root["soapenv:Body"]["ns:GetReporteeElementListBasicV2"].addChild(search)
            envelope.root["soapenv:Body"]["ns:GetReporteeElementListBasicV2"].addChild(name: "ns:languageID", value: language.rawValue)
            
            print("SOAP Envelope: \(envelope.xml)")
            
            SoapManager.send(toEndPoint: url, withAction: action, withEnvelope: envelope.xml) { response in
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
                    
                    var reporteeElements: [ReporteeElement] = []
                    
                    for reporteeElementXml in result.root["s:Body"]["GetReporteeElementListBasicV2Response"]["GetReporteeElementListBasicV2Result"].children {
                        
                        //a:ExternalServiceCode
                        //let serviceEditionVersion = reporteeElementXml["a:ServiceEditionVersion"].value ?? ""
                        let externalServiceCode = reporteeElementXml["a:ExternalServiceCode"].value ?? ""
                        let formStatus = reporteeElementXml["a:Status"].value ?? ""
                        if Constants.rf1030ServiceCodes.contains(externalServiceCode) &&
                        Constants.filterFormStatusBy.contains(formStatus){
                            if let reporteeElement = try? ReporteeElement(xmlData: reporteeElementXml) {
                                reporteeElements.append(reporteeElement)
                            }
                        }
                        
                        //print(reporteeElementXml["a:ReporteeElementId"].value)
                        
                    }
                    
                    //print("\(reporteeElements)")
                    completion(reporteeElements, nil)
                    
                    
                } catch {
                    //print("Error: \(error)")
                    completion(nil, error)
                }
            }
        }catch{
            //print("Error: \(error)")
            completion(nil, error)
        }
        
    }
}
