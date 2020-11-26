//
//  File.swift
//  
//
//  Created by Faizan Abid on 31/3/20.
//

import Foundation
import AEXML

public struct RF1189FormData {
    let intro: RF1189Intro
    let address: RF1189Address
    
    //revenue section
    let tenantInfo: [RF1189TenantInfo]
    let tenantRefund: Int?
    let otherIncome: Int?
    //let samlet: Int? //total income calculated from tenant info total. This is auto calculated so not using for now
    
    //costs
    let rentCost: RF1189RentCost
    let municipalTaxesCost: RF1189MunicipalTaxesCost
    let wagesCost: RF1189WagesCost
    let maintenanceInfo: [RF1189MaintenanceInfo]
    let otherCostInfo: [RF1189OtherCostInfo]
    let ownCost: Int? //own housing, electricity etc.; this gets deducated from total whel calc sum but that is auto
    
    //net income related stuff. Most fields are auto calculated
    let spouseIncomeTransferred: Int? //we assume this as nil for now
    
    //control questions. All set to no by default
    let haveTaxOnWealthIncome: Bool
    let haveRenumeration: Bool
    let haveAssociationFee: Bool
    
    //<Eiendom-grp-2168 gruppeid="2168"> property info
    //throws AEXMLDocument
    public init(intro: RF1189Intro, address: RF1189Address,
                tenantInfo: [RF1189TenantInfo], tenantRefund: Int? = nil, otherIncome: Int? = nil,
                rentCost: RF1189RentCost, municipalTaxesCost: RF1189MunicipalTaxesCost, wagesCost: RF1189WagesCost,
                maintenanceInfo: [RF1189MaintenanceInfo], otherCostInfo: [RF1189OtherCostInfo], ownCost: Int? = nil){
        self.intro = intro
        self.address = address
        
        //revenue
        self.tenantInfo = tenantInfo
        self.tenantRefund = tenantRefund
        self.otherIncome = otherIncome
        //self.samlet = samlet
        
        //costs
        self.rentCost = rentCost
        self.municipalTaxesCost = municipalTaxesCost
        self.wagesCost = wagesCost
        self.maintenanceInfo = maintenanceInfo
        self.otherCostInfo = otherCostInfo
        self.ownCost = ownCost
        
        //assumed fields
        self.spouseIncomeTransferred = nil
        haveTaxOnWealthIncome = false
        haveRenumeration = false
        haveAssociationFee = false
    }
    
    public func getXml() throws -> AEXMLDocument {

        guard let xmlDoc = try? AEXMLDocument(xml: XmlTemplates.rf1189FormBase) else { throw AltinnLibraryError.xmlParseError }
        let xml = xmlDoc.root
        
        //top level elements
        let introElement = AEXMLElement(name: "GenerellInformasjon-grp-959", attributes: ["gruppeid": "959"])
        let addressElement = AEXMLElement(name: "Eiendom-grp-2168", attributes: ["gruppeid": "2168"])
        let revenueElement = AEXMLElement(name: "InntekterUtleieverdi-grp-960", attributes: ["gruppeid": "960"])
        let expensesElement = AEXMLElement(name: "Kostnader-grp-236", attributes: ["gruppeid": "236"])
        let netIncomeElement = AEXMLElement(name: "Nettoinntekt-grp-4945", attributes: ["gruppeid": "4945"])
        let controlQuestionsElement = AEXMLElement(name: "Kontrollsporsmal-grp-239", attributes: ["gruppeid": "239"])

        
        introElement.addChild(intro.getXml())
        addressElement.addChild(address.getXml())
        
        //revenue section
        for tenantInfoItem in tenantInfo {
            revenueElement.addChild(tenantInfoItem.getXml())
        }
        
        revenueElement.addChild(name: "VedlikeholdskostnaderMvLeietakere-datadef-22032", value: tenantRefund == nil ? nil : "\(tenantRefund!)", attributes: ["orid": "22032", "xsi:nil": tenantRefund == nil ? "true" : "false"])
        revenueElement.addChild(name: "InntekterAndre-datadef-22101", value: otherIncome == nil ? nil : "\(otherIncome!)", attributes: ["orid": "22101", "xsi:nil": otherIncome == nil ? "true" : "false"])
        
        //samlet is auto generated
        
        //costs section
        //rental, municipal and wages costs
        expensesElement.addChild(rentCost.getXml())
        expensesElement.addChild(municipalTaxesCost.getXml())
        expensesElement.addChild(wagesCost.getXml())
        
        //maintenance costs
        let expensesMaintenanceElement = AEXMLElement(name: "VedlikeholdPakostningerForandringerMv-grp-3488", attributes: ["gruppeid": "3488"])
        for maintenanceInfoItem in maintenanceInfo {
            expensesMaintenanceElement.addChild(maintenanceInfoItem.getXml())
        }
        //add this point we might wanna add total and deductions to maintenance element but altin calculates it automatically so not adding for now. There is also a reduction if housing has been exempt before which we are not setting
        expensesElement.addChild(expensesMaintenanceElement)
        
        //at this point we can also add 'established loss of income' and 'depreciation cost' to expenses element but not setting for now
        
        //other costs
        let expensesOtherElement = AEXMLElement(name: "AndreKostnader-grp-971", attributes: ["gruppeid": "971"])
        for otherCostInfoItem in otherCostInfo {
            expensesOtherElement.addChild(otherCostInfoItem.getXml())
        }
        expensesOtherElement.addChild(name: "DriftsutgifterLysBrenselRenholdEgenBoligdel-datadef-7896", value: ownCost == nil ? nil : "\(ownCost!)", attributes: ["orid": "7896", "xsi:nil": ownCost == nil ? "true" : "false"])
        
        expensesElement.addChild(expensesOtherElement)
        
        //net income related
        netIncomeElement.addChild(name: "InntektOverfortEktefelle-datadef-28170", value: spouseIncomeTransferred == nil ? nil : "\(spouseIncomeTransferred!)", attributes: ["orid": "28170", "xsi:nil": spouseIncomeTransferred == nil ? "true" : "false"])
        
        //control questions
        let controlQuestionsSubElement = AEXMLElement(name: "OmfatterKostnadeneNoeAvFolgende-grp-2330", attributes: ["gruppeid": "2330"])
        controlQuestionsSubElement.addChild(name: "UtgifterSkattFormueInntekt-datadef-7911", value: haveTaxOnWealthIncome ? "Ja" : "Nei", attributes: ["orid": "7911"])
        controlQuestionsSubElement.addChild(name: "UtgifterGodtgjoringHuseierMv-datadef-7913", value: haveRenumeration ? "Ja" : "Nei", attributes: ["orid": "7913"])
        controlQuestionsSubElement.addChild(name: "UtgifterKontingentHuseierforeninger-datadef-7915", value: haveAssociationFee ? "Ja" : "Nei", attributes: ["orid": "7915"])
        controlQuestionsElement.addChild(controlQuestionsSubElement)
        
        
        xml.addChildren([introElement, addressElement, revenueElement, expensesElement, netIncomeElement, controlQuestionsElement])
        
        return xmlDoc

    }
}

public struct RF1189Intro {
    let id: String //Fødselsnummer
    let name: String
    let orgNr: String
    
    public init(id: String, name: String = "000", orgNr: String = ""){
        self.id = id
        self.name = name
        self.orgNr = orgNr
    }
    
    public func getXml() -> AEXMLElement {
        let xml = AEXMLElement(name: "Avgiver-grp-231", attributes: ["gruppeid": "231"])
        xml.addChild(name: "OppgavegiverNavn-datadef-68", value: name, attributes: ["orid": "68"])
        xml.addChild(name: "OppgavegiverFodselsnummer-datadef-26", value: id, attributes: ["orid": "26"])
        xml.addChild(name: "EnhetOrganisasjonsnummer-datadef-18", value: orgNr, attributes: ["orid": "18"])
        
        return xml
    }
}

public struct RF1189Address {
    let countryCode: String //default is 000 which is norway
    let streetAddress: String
    
    let kommuneNr: String //Community number. Vadso is 2003. A list can be found here: https://en.wikipedia.org/wiki/List_of_municipality_numbers_of_Norway
    let gardsNr: String //Gårdsnr, courtyard number
    let bruksNr: String //Bruksnr
    let seksjonsNr: String //Seksjonsnr
    let andelsNr: String  //Andelsnr
    let boligselskapetsNavn: String //Boligselskapets navn, housing organization
    let boligselskapetsOrgNr: String //Boligselskapets org.nr., housing org number
    let prosent: Double //percentage share in property. Default is 100%
    
    public init(streetAddress: String, countryCode: String = "000",
                kommuneNr: String = "", gardsNr: String = "", bruksNr: String = "",
                seksjonsNr: String = "", andelsNr: String = "", boligselskapetsNavn: String = "",
                boligselskapetsOrgNr: String = "", prosent: Double = 100){
        self.streetAddress = streetAddress
        self.countryCode = countryCode
        self.kommuneNr = kommuneNr
        self.gardsNr = gardsNr
        self.bruksNr = bruksNr
        self.seksjonsNr = seksjonsNr
        self.andelsNr = andelsNr
        self.boligselskapetsNavn = boligselskapetsNavn
        self.boligselskapetsOrgNr = boligselskapetsOrgNr
        self.prosent = prosent
    }
    
    public func getXml() -> AEXMLElement {
        let xml = AEXMLElement(name: "OpplysningerOmEiendomen-grp-5333", attributes: ["gruppeid": "5333"])
        xml.addChild(name: "OppgavegiverLand-datadef-34071", value: countryCode, attributes: ["orid": "34071"])
        xml.addChild(name: "EiendomAdresse-datadef-2019", value: streetAddress, attributes: ["orid": "2019"])
        xml.addChild(name: "EiendomGardsnummer-datadef-30514", value: gardsNr, attributes: ["orid": "30514"])
        xml.addChild(name: "EiendomBruksnummer-datadef-30515", value: bruksNr, attributes: ["orid": "30515"])
        xml.addChild(name: "EiendomSeksjonsnummer-datadef-30516", value: seksjonsNr, attributes: ["orid": "30516"])
        xml.addChild(name: "EiendomAndelsnummer-datadef-37196", value: andelsNr, attributes: ["orid": "37196"])
        xml.addChild(name: "BoligselskapNavnSpesifisert-datadef-6829", value: boligselskapetsNavn, attributes: ["orid": "6829"])
        xml.addChild(name: "BoligselskapOrgansisasjonsnummer-datadef-37197", value: boligselskapetsOrgNr, attributes: ["orid": "37197"])
        xml.addChild(name: "EiendomKommuneNummer-datadef-23", value: kommuneNr, attributes: ["orid": "23"])
        xml.addChild(name: "EierSameieAndel-datadef-28168", value: prosent.format(f: ".3"), attributes: ["orid": "28168"])
        
        return xml
    }
}

public struct RF1189TenantInfo {
    
    let name: String
    let type: PropertyType
    let etasje: Int?
    let antallKvm: Int?
    let fraDato: Date?
    let tilDato: Date?
    let belop: Int?
    
    public init(name: String, type: PropertyType = .bolig, etasje: Int? = nil, antallKvm: Int? = nil, fraDato: Date? = nil, tilDato: Date? = nil, belop: Int? = nil){
        self.name = name
        self.type = type
        self.etasje = etasje
        self.antallKvm = antallKvm
        self.fraDato = fraDato
        self.tilDato = tilDato
        self.belop = belop
    }
    
    public func getXml() -> AEXMLElement {
        let xml = AEXMLElement(name: "Utleie-grp-4939", attributes: ["gruppeid": "4939"])
        xml.addChild(name: "EiendomUtleieTypeSpesifisertEiendom-datadef-22008", value: type.rawValue, attributes: ["orid": "22008"])
        xml.addChild(name: "LeietakerNavnSpesifisertLeietaker-datadef-22009", value: name, attributes: ["orid": "22009"])
        xml.addChild(name: "UtleieEtasjeSpesifisertEiendom-datadef-22010", value: etasje == nil ? nil : "\(etasje!)", attributes: ["orid": "22010", "xsi:nil": etasje == nil ? "true" : "false"])
        xml.addChild(name: "UtleieArealSpesifisertEiendom-datadef-22011", value: antallKvm == nil ? nil : "\(antallKvm!)", attributes: ["orid": "22011", "xsi:nil": antallKvm == nil ? "true" : "false"])
        xml.addChild(name: "UtleieFraDatoSpesifisertEiendom-datadef-22012", value: fraDato == nil ? nil : "\(fraDato!.toSimpleString())", attributes: ["orid": "22012", "xsi:nil": fraDato == nil ? "true" : "false"])
        xml.addChild(name: "UtleieTilDatoSpesifisertEiendom-datadef-22013", value: tilDato == nil ? nil : "\(tilDato!.toSimpleString())", attributes: ["orid": "22013", "xsi:nil": tilDato == nil ? "true" : "false"])
        xml.addChild(name: "UtleieInntektSpesifisertEiendom-datadef-22014", value: belop == nil ? nil : "\(belop!)", attributes: ["orid": "22014", "xsi:nil": belop == nil ? "true" : "false"])
        
        return xml
    }
}

public enum PropertyType : String {
    case bolig = "bolig"
    case fritidseiendom = "fritidseiendom"
    case industri = "industri"
    case forretning = "forretning"
    case tomt = "tomt"
    case annet = "annet"
}

public struct RF1189RentCost {
    let belop: Int?
    let kostnad: Int?
    
    public init(belop: Int? = nil, kostnad: Int? = nil){
        self.belop = belop
        self.kostnad = kostnad
    }
    
    public func getXml() -> AEXMLElement {
        let xml = AEXMLElement(name: "Festeavgift-grp-5281", attributes: ["gruppeid": "5281"])
        xml.addChild(name: "Festeavgift-datadef-7885", value: belop == nil ? nil : "\(belop!)", attributes: ["orid": "7885", "xsi:nil": belop == nil ? "true" : "false"])
        xml.addChild(name: "FesteavgiftFradragsbrettiget-datadef-23634", value: kostnad == nil ? nil : "\(kostnad!)", attributes: ["orid": "23634", "xsi:nil": kostnad == nil ? "true" : "false"])
        
        return xml
    }
}

public struct RF1189MunicipalTaxesCost {
    let belop: Int?
    let kostnad: Int?
    
    public init(belop: Int? = nil, kostnad: Int? = nil){
        self.belop = belop
        self.kostnad = kostnad
    }
    
    public func getXml() -> AEXMLElement {
        let xml = AEXMLElement(name: "KommunaleAvgifter-grp-5282", attributes: ["gruppeid": "5282"])
        xml.addChild(name: "AvgifterEiendomKommunale-datadef-7886", value: belop == nil ? nil : "\(belop!)", attributes: ["orid": "7886", "xsi:nil": belop == nil ? "true" : "false"])
        xml.addChild(name: "AvgifterEiendomKommunaleFradragsberretiget-datadef-23635", value: kostnad == nil ? nil : "\(kostnad!)", attributes: ["orid": "23635", "xsi:nil": kostnad == nil ? "true" : "false"])
        
        return xml
    }
}

public struct RF1189WagesCost {
    let reportedToTaxAgency: Bool
    let belop: Int?
    let kostnad: Int?
    
    public init(belop: Int? = nil, kostnad: Int? = nil, reportedToTaxAgency: Bool = false){
        self.reportedToTaxAgency = reportedToTaxAgency
        self.belop = belop
        self.kostnad = kostnad
    }
    
    public func getXml() -> AEXMLElement {
        let xml = AEXMLElement(name: "Lonnskostnader-grp-5283", attributes: ["gruppeid": "5283"])
        xml.addChild(name: "LonnsoppgaveInnsendt-datadef-7908", value: reportedToTaxAgency ? "Ja" : "Nei", attributes: ["orid": "7908"])
        xml.addChild(name: "DriftsutgifterVaktmesterBestyrerDisponentForretningsforer-datadef-7889", value: belop == nil ? nil : "\(belop!)", attributes: ["orid": "7889", "xsi:nil": belop == nil ? "true" : "false"])
        xml.addChild(name: "DriftsutgifterVaktmesterBestyrerDisponentMvFradragsberretiget-datadef-23636", value: kostnad == nil ? nil : "\(kostnad!)", attributes: ["orid": "23636", "xsi:nil": kostnad == nil ? "true" : "false"])
        
        return xml
    }
}

public struct RF1189MaintenanceInfo {
    let beskrivelse: String
    let name: String //supplier name
    let address: String
    let postNummer: String
    let poststed: String
    let dato: Date?
    let belop: Int?
    let kostnad: Int? //deductible cost
    
    public init(beskrivelse: String, name: String = "", address: String = "", postNummer: String = "", poststed: String = "", dato: Date? = nil, belop: Int? = nil, kostnad: Int? = nil){
        self.beskrivelse = beskrivelse
        self.name = name
        self.address = address
        self.postNummer = postNummer
        self.poststed = poststed
        self.dato = dato
        self.belop = belop
        self.kostnad = kostnad
    }
    
    public func getXml() -> AEXMLElement {
        let xml = AEXMLElement(name: "VedlikeholdMv-grp-237", attributes: ["gruppeid": "237"])
        xml.addChild(name: "EiendomVedlikeholdBeskrivelseSpesifisert-datadef-7898", value: beskrivelse, attributes: ["orid": "7898"])
        xml.addChild(name: "OppdragstakerNavnSpesifisertVedlikehold-datadef-7899", value: name, attributes: ["orid": "7899"])
        xml.addChild(name: "OppdragstakerAdresseSpesifisertVedlikehold-datadef-7900", value: address, attributes: ["orid": "7900"])
        xml.addChild(name: "OppdragstakerPostnummerSpesifisertVedlikehold-datadef-7901", value: postNummer, attributes: ["orid": "7901"])
        xml.addChild(name: "OppdragstakerPoststedSpesifisertVedlikehold-datadef-7902", value: poststed, attributes: ["orid": "7902"])
        xml.addChild(name: "EiendomVedlikeholdDatoSpesifisert-datadef-7903", value: dato == nil ? nil : "\(dato!.toSimpleString())", attributes: ["orid": "7903", "xsi:nil": dato == nil ? "true" : "false"])
        xml.addChild(name: "DriftsutgifterEiendomSpesifisertVedlikeholdPakostningerMv-datadef-7904", value: belop == nil ? nil : "\(belop!)", attributes: ["orid": "7904", "xsi:nil": belop == nil ? "true" : "false"])
        xml.addChild(name: "DriftsutgifterEiendomVedlikeholdFradragsberettigetSpesifisert-datadef-7905", value: kostnad == nil ? nil : "\(kostnad!)", attributes: ["orid": "7905", "xsi:nil": kostnad == nil ? "true" : "false"])
        
        return xml
    }
}

public struct RF1189OtherCostInfo {
    let beskrivelse: String
    let belop: Int?
    
    public init(beskrivelse: String, belop: Int? = nil){
        self.beskrivelse = beskrivelse
        self.belop = belop
    }
    
    public func getXml() -> AEXMLElement {
        let xml = AEXMLElement(name: "AndreKostnaderSpesifisert-grp-4944", attributes: ["gruppeid": "4944"])
        xml.addChild(name: "DriftsutgifterAndreBeskrivelseSpesifisert-datadef-7894", value: beskrivelse, attributes: ["orid": "7894"])
        xml.addChild(name: "DriftsutgifterAndreSpesifisert-datadef-10069", value: belop == nil ? nil : "\(belop!)", attributes: ["orid": "10069", "xsi:nil": belop == nil ? "true" : "false"])
        
        return xml
    }
    
}
