import AEXML
import Foundation

public final class AltinnLibrary {
    
    let testMode:Bool
    
    public init(test: Bool = false){
        self.testMode = test
    }
    
    //userSsn: String, userPassword: String
    public func login(userLoginInput: UserLoginInput, systemLoginInput: SystemLoginInput, authenticationMethod: AuthenticationMethod, completion: @escaping (LoginResponse?, Error?) -> ()){
        guard let url = URL(string: "\(testMode ? Constants.testAltinnUrl : Constants.baseAltinnUrl)\(EndPoints.authentication)") else {
            print("Error occurred while parsing URL")
            return
        }
        let action = Actions.loginAction
        
        guard let envelope = try? AEXMLDocument(xml: XmlTemplates.login) else {
            print("Error occurred while parsing XML")
            return
        }
        
    envelope.root["soapenv:Body"]["ns:GetAuthenticationChallenge"]["ns:challengeRequest"]["ns1:UserSSN"].value = userLoginInput.userSsn
    envelope.root["soapenv:Body"]["ns:GetAuthenticationChallenge"]["ns:challengeRequest"]["ns1:UserPassword"].value = userLoginInput.userPassword
    envelope.root["soapenv:Body"]["ns:GetAuthenticationChallenge"]["ns:challengeRequest"]["ns1:AuthMethod"].value = authenticationMethod.rawValue
        envelope.root["soapenv:Body"]["ns:GetAuthenticationChallenge"]["ns:challengeRequest"]["ns1:SystemUserName"].value = systemLoginInput.systemUserName
        
        
        print("envelope is:\n\(envelope.xml)")
        
//        print("element value check: \(envelope.root["soapenv:Body"]["ns:GetAuthenticationChallenge"]["ns:challengeRequest"]["ns1:AuthMethod"].exists())")
        //print("contains tag check: \(envelope.root["soapenv:Body"].children.count)")
        
        //let bb = envelope.root["soapenv:Body"]["ns:GetAuthenticationChallenge"]["ns:challengeRequest"]["ns1:AuthMetho"]
        
        SoapManager.send(toEndPoint: url, withAction: action, withEnvelope: envelope.xml) { (response) in
            //print("AltinnLibrary response received: \(response)")
            if(response.error != nil){
                print("Error from network library: \(response.error!)")
                completion(nil, response.error)
            }else{
                do {
                    let result = try parseStringToSoapResponse(data: response.data)
                    
                    //check for altinn faults
                    if result.hasFault() {
                        let error = getAltinnError(xml: result.getFault())
                        completion(nil, error)
                        return
                    }
                    
                    //get status, message and validTo date
                    guard let statusText = result.root["s:Body"]["GetAuthenticationChallengeResponse"]["GetAuthenticationChallengeResult"]["a:Status"].value,
                    let message = result.root["s:Body"]["GetAuthenticationChallengeResponse"]["GetAuthenticationChallengeResult"]["a:Message"].value,
                    let validTo = result.root["s:Body"]["GetAuthenticationChallengeResponse"]["GetAuthenticationChallengeResult"]["a:ValidTo"].value else {
                        
                        //showError(error: AltinnLibraryError.elementNotFound("a:Status,a:Message or a:ValidTo"))
                        completion(nil, AltinnLibraryError.elementNotFound("a:Status,a:Message or a:ValidTo"))
                        return
                    }
                    
                    do {
                        let status = try getLoginStatus(statusText: statusText)
                        //print("status:\(status)\nmessage:\(message)\nvalidTo\(validTo.asAltinnDate())")
                        var error: AltinnLibraryError? = nil
                        switch status {
                        case .invalidPinType:
                            error = AltinnLibraryError.loginInvalidPinType(message)
                            break
                        case .invalidCredentials:
                            error = AltinnLibraryError.loginInvalidCredentials(message)
                            break
                        case .noPhoneNumber:
                            error = AltinnLibraryError.noPhoneNumber(message)
                            break
                        case .ok:
                            error = nil
                            break
                        }
                        
                        if(error != nil){
                            completion(LoginResponse(message: message, validTo: nil, status: status),error)
                            return
                        }
                        
                        guard let validToDate = validTo.asAltinnDate() else {
                            //showError(error: AltinnLibraryError.unableToParseDateString(validTo))
                            completion(nil, AltinnLibraryError.unableToParseDateString(validTo))
                            return
                        }
                        
                        completion(LoginResponse(message: message, validTo: validToDate, status: status),nil)
                        
                    } catch {
                        //showError(error: error)
                        completion(nil, error)
                    }
                } catch {
                    //showError(error: error)
                    completion(nil, error)
                }
                
            }
        }
        
    }
    
}
