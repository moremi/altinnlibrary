//
//  File.swift
//  
//
//  Created by Faizan Abid on 18/3/20.
//

import Foundation
import AEXML

//note: All public struct need public init.

public struct UserLoginInput {
    let userSsn: String
    let userPassword: String
    
    public init(userSsn: String, userPassword: String){
        self.userSsn = userSsn
        self.userPassword = userPassword
    }
}

public struct SystemLoginInput {
    let systemUserName: String
    let systemPassword: String
    
    public init(systemUserName: String, systemPassword: String){
        self.systemUserName = systemUserName
        self.systemPassword = systemPassword
    }
}

public struct AuthInput {
    let userPinCode: String
    let authMethod: AuthenticationMethod
    
    public init(userPinCode: String, authMethod: AuthenticationMethod){
        self.userPinCode = userPinCode
        self.authMethod = authMethod
    }
}

public struct SearchFormInput {
    let fromDate: Date
    let toDate: Date
    let reportee: String
    
    public func getAsXml() -> AEXMLElement {
        let xml = AEXMLElement(name: "ns:searchBE")
        
        //NOTE: Sequence is IMPORTANT
        xml.addChild(name: "ns1:FromDate", value: fromDate.toSimpleString())
        xml.addChild(name: "ns1:Reportee", value: reportee)
        xml.addChild(name: "ns1:ToDate", value: toDate.toSimpleString())
        return xml
    }
}

public enum AuthenticationMethod: String {
    case altinnPin = "AltinnPin"
    case smsPin = "SMSPin"
    case taxPin = "TaxPin"
}

public enum Language: String {
    case english = "1033"
    case bokmal = "1044"
    case sami = "1083"
    case nynorsk = "2068"
}
