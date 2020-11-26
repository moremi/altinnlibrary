//
//  File.swift
//  
//
//  Created by Faizan Abid on 17/3/20.
//

import Foundation
import Alamofire
import AEXML

public class SoapManager {
    
    struct SoapManagerResponse {
        let data: String?
        let error: Error?
    }
    
    static func send(toEndPoint endpoint: URL, withAction soapAction: String, withEnvelope inputEnvelop: String, completion: @escaping (SoapManagerResponse) -> ()){
        print("SoapManager send called")
        
        let headers: HTTPHeaders = [
            "Content-Type":"text/xml;charset=utf-8",
            "Content-Length": String(inputEnvelop.count),
            "SOAPAction": "\"\(soapAction)\"",
            //"Host": "tt02.altinn.no", //adding this overrides the host
            "Accept-Encoding": "gzip,deflate"
        ]
        
        AF.request(endpoint, method: .post, parameters: [:], encoding: inputEnvelop, headers: headers)
            .responseString { (response) in
                print("SoapManager response received")
                switch(response.result){
                case .success(let resultString):
                    //print("SoapManager result: \n \(resultString)")
                    completion(SoapManagerResponse(data: resultString, error: nil))
                    break
                case .failure(let error):
                    print("SoapManager error: \(error)")
                    completion(SoapManagerResponse(data: nil, error: error))

                }

        }
    }
}

extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
    
}
