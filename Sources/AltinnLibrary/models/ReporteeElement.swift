//
//  File.swift
//  
//
//  Created by Faizan Abid on 29/3/20.
//

import Foundation
import AEXML

public struct ReporteeElement {
    
    public let id: String //reportee element id
    public let title: String?
    public let externalServiceCode: String //3348 or 3349 for our scenarios
    public let serviceEditionVersion: String //180141 or 180143 for 2019; 164387 or 164393 for 2018 for our scenarios
    public let reporteeElementStatus: String //might change this to enum later. It has to be fillin for our scenario
    
    //other helpful info
    public let reporteeName: String? //owner name
    public let lastChangedBy: String?
    public let lastChangedDate: Date?
    
    public init(xmlData: AEXMLElement) throws {
        //print("xmlData: \(xmlData["a:ReporteeElementId"].value)")
        //the required stuff is but behind guard. Rest can be defaults
        guard
            let id = xmlData["a:ReporteeElementId"].value,
            let externalServiceCode = xmlData["a:ExternalServiceCode"].value,
            let serviceEditionVersion = xmlData["a:ServiceEditionVersion"].value,
            let reporteeElementStatus = xmlData["a:Status"].value
        else {
            throw AltinnLibraryError.elementNotFound("a:ReporteeElementId,a:ExternalServiceCode,a:ServiceEditionVersion,a:Status")
        }
        
        self.id = id
        self.externalServiceCode = externalServiceCode
        self.serviceEditionVersion = serviceEditionVersion
        self.reporteeElementStatus = reporteeElementStatus
        
        self.title = xmlData["a:Title"].value
        
        self.reporteeName = xmlData["a:ReporteeName"].value
        self.lastChangedBy = xmlData["a:LastChangedBy"].value
        
        self.lastChangedDate = xmlData["a:LastChangedDate"].value?.asAltinnDateSimple()
    }
    
}

//not using for now. Or only use for direct comparison later
public enum ReporteeElementStatus: String {
    case FillIn = "FillIn"
    case Archive = "Archive"
//All statuses:    NotOpenedNoConfirmationReq, NotOpenedConfirmationReq, OpenedNoConfirmedReq, OpenedNotConfirmed, Confirmed, FillIn, SignIn, Archive, SendIn, Active, Finished
}
