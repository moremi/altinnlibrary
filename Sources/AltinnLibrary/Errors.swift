//
//  File.swift
//  
//
//  Created by Faizan Abid on 18/3/20.
//

import Foundation
import AEXML

enum AltinnLibraryError: Error {
    
    // MARK: errors that users must take action to fix**/
    //Following can occur on login
    case loginInvalidCredentials(String) //user's SSN/password was invalid. Corresponds to InvalidCredentials from Altinn in login response
    case loginInvalidPinType(String)
    case noPhoneNumber(String)
    
    //Following can occur when getting or update forms. Users needs to fix these errors
    case pinSessionTimedOut(String) //989, Pin session time has time out for user. Request new
    case invalidUserCredentials(String) //989, Incorrect username/password/pin given for user
    case invalidSystemCredentials(String) //5, Wrong username/password supplied.
    
    case yearNotSupported(String) //occurs when submitting a form in a year that this library does not support. For now, only 2020 is supported
    
    // MARK: errors that users cant do anything about and just get a general error saying something occurred and they can contact us*/
    
    //valid responses received but we are unable create proper response
    case elementNotFound(String) //an element we were looking for in the xml was not found after parsing
    case invalidStatusText(String) //if a certain expected status doesnt conform to a type
    
    //Response from Altinn has fault object
    case unknownAltinnError(String) //0, Your request suffered from a non-functional error. If this persist, please report it to the system administrator. Please include the id concerning this speciffic error [1e4e9931-cad9-49dc-b176-e0b42109cad9].
    case unknownUserAuthenticationError(String)
    case altinnFault
    
    
    case nilResponse //unlikely but when response is nil
    case notXmlResponse //for cases where we don't get a XML response (it is html or something. Like when it returns html page. Alternatively, when XML does not have s:Envelope->s:Body
    case notSoapResponse //for cases where we don't get a valid soap response e.g. its html
     //some fault in Altinn response. The return is s:Envelope->s:Body->s:Fault
    case xmlParseError //parse error from AEXML library
    case unableToParseDateString(String) //in cases where a date string from altinn couldnt be parsed
    case objectWasNil(String) //if an object that was not expected to be nil is nil esp when working on date objects
    
}

//parse errors in case we received a fault object
func getAltinnError(xml: AEXMLElement) -> AltinnLibraryError {
    
    //check if detail and AltinnFault exists
    let fault = xml["detail"]["AltinnFault"]
    if !fault.exists() {
        return .unknownAltinnError("An unknown error from Altinn occurred")
    }
    
    guard let errorId = fault["ErrorID"].value,
        let errorMessage = fault["AltinnErrorMessage"].value
        else {
           return .unknownAltinnError("An unknown error from Altinn occurred")
            
    }
    
    //if both found parse further
    switch errorId {
    case "989":
        switch errorMessage {
        case "Pin session time has time out for user. Request new":
            return .pinSessionTimedOut(errorMessage)
        case "Incorrect username/password/pin given for user":
            return .invalidUserCredentials(errorMessage)
        default:
            return .unknownUserAuthenticationError(errorMessage)
        }
    case "5":
        return .invalidSystemCredentials(errorMessage)
    default:
        return .unknownAltinnError(errorMessage)
    }
}


