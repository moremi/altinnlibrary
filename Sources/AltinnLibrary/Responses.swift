//
//  File.swift
//  
//
//  Created by Faizan Abid on 18/3/20.
//
import Foundation
import AEXML

public struct LoginResponse {
    public let message: String
    public let validTo: Date?
    public let status: AltinnLoginStatus
}

//the message and status get first populated from the main response and then we look for the subform response, and if there, the fields are updated with that instead.
public struct UpdateFormResponse {
   public let message: String
   public let status: AltinnReceiptStatus
    
    public init(updateFormDataResult: AEXMLElement){
        var tempStatus = AltinnReceiptStatus(rawValue: updateFormDataResult["a:ReceiptStatusCode"].value ?? "unknown") ?? AltinnReceiptStatus.unExpectedError
        var tempMessage = updateFormDataResult["a:ReceiptText"].value ?? ""
        
        //look for sub receipt status; if not found keep the main status
        let subReceipt = updateFormDataResult["a:SubReceipts"]["a:ReceiptExternal"]
        if(subReceipt.exists() && subReceipt["a:ReceiptStatusCode"].value != nil){
            tempStatus = AltinnReceiptStatus(rawValue: subReceipt["a:ReceiptStatusCode"].value ?? "unknown") ?? AltinnReceiptStatus.unExpectedError
            tempMessage = subReceipt["a:ReceiptText"].value ?? ""
        }
        
        self.status = tempStatus
        self.message = tempMessage
    }
}

public enum AltinnLoginStatus: String {
    case invalidPinType = "InvalidPinType" //when auth method was invalid (not AltinnPin, SMSPin or TaxPin)
    case invalidCredentials = "InvalidCredentials"
    case ok = "Ok"
    case noPhoneNumber = "NoPhoneNumber"
    
}

public enum AltinnReceiptStatus: String {
    case rejected = "Rejected" //rejected because of an outer error rather than an error within the form.
    case validationFailed = "ValidationFailed" //applies to inner form rf1189 validation errors
    case notSet = "NotSet" //Specifies that the receipt status is unknown. We use it on our end when we can't find any status
    case unExpectedError = "UnExpectedError" //Specifies that there was an unexpected error during processing of a request.
    case ok = "OK"
}

public enum AltinnSubreceiptStatus: String {
    case validationFailed = "ValidationFailed"
    case ok = "OK"
}
