//
//  File.swift
//  
//
//  Created by Faizan Abid on 18/3/20.
//

import Foundation
import AEXML

public func parseStringToSoapResponse(data: String?) throws -> AEXMLDocument {
    guard let resultString = data else {
        print("Network library nil result received")
        throw AltinnLibraryError.nilResponse
    }

    guard let resultXml = try? AEXMLDocument(xml: resultString) else {
        print("Result xml parse error!")
        throw AltinnLibraryError.xmlParseError
    }
    
    //look for soapenv:Body. If not there, this is not valid soap
    let body = resultXml.root["s:Body"].children
    //print("body count: \(body.count)")
    if body.count == 0 {
        print("Not valid soap response: \(resultString)")
        throw AltinnLibraryError.notSoapResponse
    }
    
    return resultXml
}

public func getLoginStatus(statusText: String) throws -> AltinnLoginStatus {
    switch statusText {
    case AltinnLoginStatus.ok.rawValue:
        return AltinnLoginStatus.ok
        
    case AltinnLoginStatus.invalidCredentials.rawValue:
        return AltinnLoginStatus.invalidCredentials
        
    case AltinnLoginStatus.invalidPinType.rawValue:
        return AltinnLoginStatus.invalidPinType
        
    case AltinnLoginStatus.noPhoneNumber.rawValue:
    return AltinnLoginStatus.noPhoneNumber
        
    default:
        throw AltinnLibraryError.invalidStatusText(statusText)
    }
}

extension AEXMLElement {
    public func exists() -> Bool {
        return self.count > 0
    }
    
    public func hasValue() -> Bool {
        return self.value != nil
    }
}

extension AEXMLDocument {
    public func isValidSoapResponse() -> Bool {
        return self.root["s:Body"].exists()
    }
    
    public func hasFault() -> Bool {
        return self.root["s:Body"]["s:Fault"].exists()
    }
    
    public func getFault() -> AEXMLElement {
        return self.root["s:Body"]["s:Fault"]
    }
}

extension String {
    //for dates like 2020-03-29T23:49:21.7667607+02:00
    public func asAltinnDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter.date(from: self)
    }
    
    //for dates like 2020-03-17T00:04:17.837 ; no timezone and fractional seconds
    public func asAltinnDateSimple() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withYear, .withMonth, .withDay, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter.date(from: self)
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension Date {
    public func toSimpleString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd"
        return dateFormatter.string(from: self)
    }
}

public func showError(error: Error){
    print("Library Error: \(error)")
}

extension AEXMLElement {
    public func appendAuthenticationElements(user: UserLoginInput, system: SystemLoginInput, auth: AuthInput) {
        self.addChild(name: "ns:systemUserName", value: system.systemUserName)
        self.addChild(name: "ns:systemPassword", value: system.systemPassword)
        self.addChild(name: "ns:userSSN", value: user.userSsn)
        self.addChild(name: "ns:userPassword", value: user.userPassword)
        self.addChild(name: "ns:userPinCode", value: auth.userPinCode)
        self.addChild(name: "ns:authMethod", value: auth.authMethod.rawValue)
        
    }
}

public func getReceiptStatusFromString(status: String) -> AltinnReceiptStatus {
    return AltinnReceiptStatus(rawValue: status) ?? AltinnReceiptStatus.unExpectedError
}



