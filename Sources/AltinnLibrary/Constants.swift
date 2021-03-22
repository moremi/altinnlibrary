//
//  File.swift
//  
//
//  Created by Faizan Abid on 17/3/20.
//

import Foundation

//IMPORTANT: Have all urls with https

struct Constants {
    
    static let baseAltinnUrl = "https://www.altinn.no/"
    static let testAltinnUrl = "https://tt02.altinn.no/"
    
    //get forms status we are looking for
    static let filterFormStatusBy = [ReporteeElementStatus.FillIn.rawValue]
    
    //these are fixed for now and defined by the forms in altinn. Service edition and format versions can change
    static let rf1030ServiceCodes = ["3348", "3349"] //for rf-1030 forms this stays the same
    static let rf1189dataFormatId = "738"
    
    //this may change per year
    static let supportedYear = 2021 //this is always tax year + 1
    static let rf1030serviceEditionVersion = ["180141", "180143"] //for 2019 tax year, 2020 submission
    static let rf1189dataFormatVersion = "12456"
}

struct EndPoints {
    static let authentication = "AuthenticationExternal/SystemAuthentication.svc"
    static let getForms = "ServiceEngineExternal/ReporteeElementListExternalBasic.svc"
    static let updateForms = "IntermediaryExternal/IntermediaryInboundBasic.svc"
}

struct Actions {
    static let loginAction = "http://www.altinn.no/services/Authentication/SystemAuthentication/2009/10/ISystemAuthenticationExternal/GetAuthenticationChallenge"
    static let getFormsAction = "http://www.altinn.no/services/ServiceEngine/ReporteeElementList/2009/10/IReporteeElementListExternalBasic/GetReporteeElementListBasicV2"
    static let updateFormsAction = "http://www.altinn.no/services/Intermediary/Shipment/IntermediaryInbound/2009/10/IIntermediaryInboundExternalBasic/UpdateFormDataBasic"
}

struct XmlTemplates {
    static let login = "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:ns='http://www.altinn.no/services/Authentication/SystemAuthentication/2009/10' xmlns:ns1='http://schemas.altinn.no/services/Authentication/2009/10'><soapenv:Header/>       <soapenv:Body><ns:GetAuthenticationChallenge><ns:challengeRequest>                <ns1:AuthMethod></ns1:AuthMethod><ns1:SystemUserName></ns1:SystemUserName><ns1:UserPassword></ns1:UserPassword><ns1:UserSSN></ns1:UserSSN></ns:challengeRequest></ns:GetAuthenticationChallenge></soapenv:Body></soapenv:Envelope>"
    
    static let getReporteeElementList = "<soapenv:Envelope  xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/'  xmlns:ns='http://www.altinn.no/services/ServiceEngine/ReporteeElementList/2009/10'  xmlns:ns1='http://schemas.altinn.no/services/Archive/ReporteeArchive/2009/10'  xmlns:arr='http://schemas.microsoft.com/2003/10/Serialization/Arrays'><soapenv:Header/><soapenv:Body>   <ns:GetReporteeElementListBasicV2></ns:GetReporteeElementListBasicV2></soapenv:Body></soapenv:Envelope>"
    
    static let updateFormData = "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:ns='http://www.altinn.no/services/Intermediary/Shipment/IntermediaryInbound/2009/10' xmlns:ns1='http://schemas.altinn.no/services/Intermediary/Shipment/IntermediaryInbound/2018/06'><soapenv:Header/> <soapenv:Body><ns:UpdateFormDataBasic><ns:formTaskUpdate><ns1:ExternalShipmentReference>EXT_REF${=(int)(Math.random()*100000)}</ns1:ExternalShipmentReference><ns1:FormUpdateList></ns1:FormUpdateList><ns1:ReporteeElementId></ns1:ReporteeElementId></ns:formTaskUpdate></ns:UpdateFormDataBasic></soapenv:Body></soapenv:Envelope>"
    
    static let rf1189FormBase = "<Skjema xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' skjemanummer='738' spesifikasjonsnummer='12292' blankettnummer='RF-1189' tittel='Årsoppgjør for utleie av fast eiendom' gruppeid='230' etatid='NoAgency' xsi:noNamespaceSchemaLocation='schema%20(1).xsd'></Skjema>"
    
}

struct Samples {
    static let rf1189Sample = "<Skjema xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' skjemanummer='738' spesifikasjonsnummer='12292' blankettnummer='RF-1189' tittel='Årsoppgjør for utleie av fast eiendom' gruppeid='230' etatid='NoAgency' xsi:noNamespaceSchemaLocation='schema%20(1).xsd'><Kostnader-grp-236 gruppeid='236'> <Festeavgift-grp-5281 gruppeid='5281'>   <Festeavgift-datadef-7885 orid='7885'>0</Festeavgift-datadef-7885>   <FesteavgiftFradragsbrettiget-datadef-23634 orid='23634'>0</FesteavgiftFradragsbrettiget-datadef-23634> </Festeavgift-grp-5281> <KommunaleAvgifter-grp-5282 gruppeid='5282'>   <AvgifterEiendomKommunale-datadef-7886 orid='7886'>0</AvgifterEiendomKommunale-datadef-7886>   <AvgifterEiendomKommunaleFradragsberretiget-datadef-23635 orid='23635'>0</AvgifterEiendomKommunaleFradragsberretiget-datadef-23635> </KommunaleAvgifter-grp-5282> <Lonnskostnader-grp-5283 gruppeid='5283'>   <LonnsoppgaveInnsendt-datadef-7908 orid='7908'>Nei</LonnsoppgaveInnsendt-datadef-7908>   <DriftsutgifterVaktmesterBestyrerDisponentForretningsforer-datadef-7889 orid='7889'>0</DriftsutgifterVaktmesterBestyrerDisponentForretningsforer-datadef-7889>   <DriftsutgifterVaktmesterBestyrerDisponentMvFradragsberretiget-datadef-23636 orid='23636'>0</DriftsutgifterVaktmesterBestyrerDisponentMvFradragsberretiget-datadef-23636> </Lonnskostnader-grp-5283> <DriftsutgifterEiendomAvgifterLonnSkattemessig-datadef-23637 orid='23637'>0</DriftsutgifterEiendomAvgifterLonnSkattemessig-datadef-23637> <VedlikeholdPakostningerForandringerMv-grp-3488 gruppeid='3488'>   <VedlikeholdMv-grp-237 gruppeid='237'>     <EiendomVedlikeholdBeskrivelseSpesifisert-datadef-7898 orid='7898'>a</EiendomVedlikeholdBeskrivelseSpesifisert-datadef-7898>     <OppdragstakerNavnSpesifisertVedlikehold-datadef-7899 orid='7899'>a</OppdragstakerNavnSpesifisertVedlikehold-datadef-7899>     <OppdragstakerAdresseSpesifisertVedlikehold-datadef-7900 orid='7900'>a</OppdragstakerAdresseSpesifisertVedlikehold-datadef-7900>     <OppdragstakerPostnummerSpesifisertVedlikehold-datadef-7901 orid='7901'>String</OppdragstakerPostnummerSpesifisertVedlikehold-datadef-7901>     <OppdragstakerPoststedSpesifisertVedlikehold-datadef-7902 orid='7902'>a</OppdragstakerPoststedSpesifisertVedlikehold-datadef-7902>     <EiendomVedlikeholdDatoSpesifisert-datadef-7903 orid='7903'>1957-08-13</EiendomVedlikeholdDatoSpesifisert-datadef-7903>     <DriftsutgifterEiendomSpesifisertVedlikeholdPakostningerMv-datadef-7904 orid='7904'>0</DriftsutgifterEiendomSpesifisertVedlikeholdPakostningerMv-datadef-7904>     <DriftsutgifterEiendomVedlikeholdFradragsberettigetSpesifisert-datadef-7905 orid='7905'>0</DriftsutgifterEiendomVedlikeholdFradragsberettigetSpesifisert-datadef-7905>   </VedlikeholdMv-grp-237>   <DriftsutgifterEiendomVedlikeholdFradragsberettiget-datadef-7906 orid='7906'>0</DriftsutgifterEiendomVedlikeholdFradragsberettiget-datadef-7906>   <DriftsutgifterEiendomVedlikeholdReduksjon-datadef-7907 orid='7907'>2</DriftsutgifterEiendomVedlikeholdReduksjon-datadef-7907>   <DriftsutgifterEiendomVedlikeholdSkattemessig-datadef-7890 orid='7890'>0</DriftsutgifterEiendomVedlikeholdSkattemessig-datadef-7890> </VedlikeholdPakostningerForandringerMv-grp-3488> <DriftsutgifterUtleieTap-datadef-7892 orid='7892'>0</DriftsutgifterUtleieTap-datadef-7892> <BygningUtleieAvskrivningBelop-datadef-22034 orid='22034'>0</BygningUtleieAvskrivningBelop-datadef-22034> <AndreKostnader-grp-971 gruppeid='971'>   <AndreKostnaderSpesifisert-grp-4944 gruppeid='4944'>     <DriftsutgifterAndreBeskrivelseSpesifisert-datadef-7894 orid='7894'>a</DriftsutgifterAndreBeskrivelseSpesifisert-datadef-7894>     <DriftsutgifterAndreSpesifisert-datadef-10069 orid='10069'>0</DriftsutgifterAndreSpesifisert-datadef-10069>   </AndreKostnaderSpesifisert-grp-4944>   <DriftsutgifterLysBrenselRenholdEgenBoligdel-datadef-7896 orid='7896'>0</DriftsutgifterLysBrenselRenholdEgenBoligdel-datadef-7896>   <DriftsutgifterEgenBoligdel-datadef-22102 orid='22102'>0</DriftsutgifterEgenBoligdel-datadef-22102> </AndreKostnader-grp-971> <UtgifterFastEiendom-datadef-7918 orid='7918'>0</UtgifterFastEiendom-datadef-7918></Kostnader-grp-236><Nettoinntekt-grp-4945 gruppeid='4945'> <InntektNetto-datadef-28169 orid='28169'>0</InntektNetto-datadef-28169> <InntektOverfortEktefelle-datadef-28170 orid='28170'>0</InntektOverfortEktefelle-datadef-28170> <LeieinntekterNettoOverskudd-datadef-7897 orid='7897'>0</LeieinntekterNettoOverskudd-datadef-7897> <LeieinntekterNettoUnderskudd-datadef-14188 orid='14188'>0</LeieinntekterNettoUnderskudd-datadef-14188></Nettoinntekt-grp-4945><Kontrollsporsmal-grp-239 gruppeid='239'> <OmfatterKostnadeneNoeAvFolgende-grp-2330 gruppeid='2330'>   <UtgifterSkattFormueInntekt-datadef-7911 orid='7911'>Nei</UtgifterSkattFormueInntekt-datadef-7911>   <UtgifterSkatterFormueInntektBelop-datadef-7912 orid='7912'>0</UtgifterSkatterFormueInntektBelop-datadef-7912>   <UtgifterGodtgjoringHuseierMv-datadef-7913 orid='7913'>Ja</UtgifterGodtgjoringHuseierMv-datadef-7913>   <UtgifterGodtgjoringHuseierMvBelop-datadef-7914 orid='7914'>0</UtgifterGodtgjoringHuseierMvBelop-datadef-7914>   <UtgifterKontingentHuseierforeninger-datadef-7915 orid='7915'>Nei</UtgifterKontingentHuseierforeninger-datadef-7915>   <UtgifterKontingentHuseierforeningerBelop-datadef-7916 orid='7916'>0</UtgifterKontingentHuseierforeningerBelop-datadef-7916> </OmfatterKostnadeneNoeAvFolgende-grp-2330></Kontrollsporsmal-grp-239></Skjema>"
    
    static let rf1189SampleOrig = "<Skjema xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' skjemanummer='738' spesifikasjonsnummer='1229' blankettnummer='RF-1189' tittel='Årsoppgjør for utleie av fast eiendom' gruppeid='230' etatid='NoAgency' xsi:noNamespaceSchemaLocation='schema%20(1).xsd'><GenerellInformasjon-grp-959 gruppeid='959'> <Avgiver-grp-231 gruppeid='231'>   <OppgavegiverNavn-datadef-68 orid='68'>a</OppgavegiverNavn-datadef-68>   <OppgavegiverFodselsnummer-datadef-26 orid='26'>String</OppgavegiverFodselsnummer-datadef-26>   <EnhetOrganisasjonsnummer-datadef-18 orid='18'>String</EnhetOrganisasjonsnummer-datadef-18> </Avgiver-grp-231></GenerellInformasjon-grp-959><Eiendom-grp-2168 gruppeid='2168'> <OpplysningerOmEiendomen-grp-5333 gruppeid='5333'>   <OppgavegiverLand-datadef-34071 orid='34071'>a</OppgavegiverLand-datadef-34071>   <EiendomAdresse-datadef-2019 orid='2019'>ABBBCCC</EiendomAdresse-datadef-2019>   <EiendomGardsnummer-datadef-30514 orid='30514'>0</EiendomGardsnummer-datadef-30514>   <EiendomBruksnummer-datadef-30515 orid='30515'>0</EiendomBruksnummer-datadef-30515>   <EiendomSeksjonsnummer-datadef-30516 orid='30516'>0</EiendomSeksjonsnummer-datadef-30516>   <EiendomAndelsnummer-datadef-37196 orid='37196'>0</EiendomAndelsnummer-datadef-37196>   <BoligselskapNavnSpesifisert-datadef-6829 orid='6829'>a</BoligselskapNavnSpesifisert-datadef-6829>   <BoligselskapOrgansisasjonsnummer-datadef-37197 orid='37197'>String</BoligselskapOrgansisasjonsnummer-datadef-37197>   <EiendomKommuneNummer-datadef-23 orid='23'>String</EiendomKommuneNummer-datadef-23>   <EierSameieAndel-datadef-28168 orid='28168'>0</EierSameieAndel-datadef-28168> </OpplysningerOmEiendomen-grp-5333></Eiendom-grp-2168><InntekterUtleieverdi-grp-960 gruppeid='960'> <Utleie-grp-4939 gruppeid='4939'>   <EiendomUtleieTypeSpesifisertEiendom-datadef-22008 orid='22008'>forretning</EiendomUtleieTypeSpesifisertEiendom-datadef-22008>   <LeietakerNavnSpesifisertLeietaker-datadef-22009 orid='22009'>a</LeietakerNavnSpesifisertLeietaker-datadef-22009>   <UtleieEtasjeSpesifisertEiendom-datadef-22010 orid='22010'>a</UtleieEtasjeSpesifisertEiendom-datadef-22010>   <UtleieArealSpesifisertEiendom-datadef-22011 orid='22011'>a</UtleieArealSpesifisertEiendom-datadef-22011>   <UtleieFraDatoSpesifisertEiendom-datadef-22012 orid='22012'>1957-08-13</UtleieFraDatoSpesifisertEiendom-datadef-22012>   <UtleieTilDatoSpesifisertEiendom-datadef-22013 orid='22013'>1957-08-13</UtleieTilDatoSpesifisertEiendom-datadef-22013>   <UtleieInntektSpesifisertEiendom-datadef-22014 orid='22014'>0</UtleieInntektSpesifisertEiendom-datadef-22014> </Utleie-grp-4939> <Kar-grp-4942 gruppeid='4942'>   <EgenleieKarNavn-datadef-22021 orid='22021'>a</EgenleieKarNavn-datadef-22021>   <KarboligStorrelse-datadef-31749 orid='31749'>Under_60</KarboligStorrelse-datadef-31749>   <KarboligManglerBadDusjWc-datadef-31750 orid='31750'>Nei</KarboligManglerBadDusjWc-datadef-31750>   <KontaktVilkarEndret-datadef-32925 orid='32925'>Ja</KontaktVilkarEndret-datadef-32925>   <EgenleieKarInntekt-datadef-22026 orid='22026'>0</EgenleieKarInntekt-datadef-22026> </Kar-grp-4942> <VedlikeholdskostnaderMvLeietakere-datadef-22032 orid='22032'>0</VedlikeholdskostnaderMvLeietakere-datadef-22032> <InntekterAndre-datadef-22101 orid='22101'>0</InntekterAndre-datadef-22101> <BruttoinntektUtleieMv-datadef-22033 orid='22033'>0</BruttoinntektUtleieMv-datadef-22033></InntekterUtleieverdi-grp-960><Kostnader-grp-236 gruppeid='236'> <Festeavgift-grp-5281 gruppeid='5281'>   <Festeavgift-datadef-7885 orid='7885'>0</Festeavgift-datadef-7885>   <FesteavgiftFradragsbrettiget-datadef-23634 orid='23634'>0</FesteavgiftFradragsbrettiget-datadef-23634> </Festeavgift-grp-5281> <KommunaleAvgifter-grp-5282 gruppeid='5282'>   <AvgifterEiendomKommunale-datadef-7886 orid='7886'>0</AvgifterEiendomKommunale-datadef-7886>   <AvgifterEiendomKommunaleFradragsberretiget-datadef-23635 orid='23635'>0</AvgifterEiendomKommunaleFradragsberretiget-datadef-23635> </KommunaleAvgifter-grp-5282> <Lonnskostnader-grp-5283 gruppeid='5283'>   <LonnsoppgaveInnsendt-datadef-7908 orid='7908'>Nei</LonnsoppgaveInnsendt-datadef-7908>   <DriftsutgifterVaktmesterBestyrerDisponentForretningsforer-datadef-7889 orid='7889'>0</DriftsutgifterVaktmesterBestyrerDisponentForretningsforer-datadef-7889>   <DriftsutgifterVaktmesterBestyrerDisponentMvFradragsberretiget-datadef-23636 orid='23636'>0</DriftsutgifterVaktmesterBestyrerDisponentMvFradragsberretiget-datadef-23636> </Lonnskostnader-grp-5283> <DriftsutgifterEiendomAvgifterLonnSkattemessig-datadef-23637 orid='23637'>0</DriftsutgifterEiendomAvgifterLonnSkattemessig-datadef-23637> <VedlikeholdPakostningerForandringerMv-grp-3488 gruppeid='3488'>   <VedlikeholdMv-grp-237 gruppeid='237'>     <EiendomVedlikeholdBeskrivelseSpesifisert-datadef-7898 orid='7898'>a</EiendomVedlikeholdBeskrivelseSpesifisert-datadef-7898>     <OppdragstakerNavnSpesifisertVedlikehold-datadef-7899 orid='7899'>a</OppdragstakerNavnSpesifisertVedlikehold-datadef-7899>     <OppdragstakerAdresseSpesifisertVedlikehold-datadef-7900 orid='7900'>a</OppdragstakerAdresseSpesifisertVedlikehold-datadef-7900>     <OppdragstakerPostnummerSpesifisertVedlikehold-datadef-7901 orid='7901'>String</OppdragstakerPostnummerSpesifisertVedlikehold-datadef-7901>     <OppdragstakerPoststedSpesifisertVedlikehold-datadef-7902 orid='7902'>a</OppdragstakerPoststedSpesifisertVedlikehold-datadef-7902>     <EiendomVedlikeholdDatoSpesifisert-datadef-7903 orid='7903'>1957-08-13</EiendomVedlikeholdDatoSpesifisert-datadef-7903>     <DriftsutgifterEiendomSpesifisertVedlikeholdPakostningerMv-datadef-7904 orid='7904'>0</DriftsutgifterEiendomSpesifisertVedlikeholdPakostningerMv-datadef-7904>     <DriftsutgifterEiendomVedlikeholdFradragsberettigetSpesifisert-datadef-7905 orid='7905'>0</DriftsutgifterEiendomVedlikeholdFradragsberettigetSpesifisert-datadef-7905>   </VedlikeholdMv-grp-237>   <DriftsutgifterEiendomVedlikeholdFradragsberettiget-datadef-7906 orid='7906'>0</DriftsutgifterEiendomVedlikeholdFradragsberettiget-datadef-7906>   <DriftsutgifterEiendomVedlikeholdReduksjon-datadef-7907 orid='7907'>2</DriftsutgifterEiendomVedlikeholdReduksjon-datadef-7907>   <DriftsutgifterEiendomVedlikeholdSkattemessig-datadef-7890 orid='7890'>0</DriftsutgifterEiendomVedlikeholdSkattemessig-datadef-7890> </VedlikeholdPakostningerForandringerMv-grp-3488> <DriftsutgifterUtleieTap-datadef-7892 orid='7892'>0</DriftsutgifterUtleieTap-datadef-7892> <BygningUtleieAvskrivningBelop-datadef-22034 orid='22034'>0</BygningUtleieAvskrivningBelop-datadef-22034> <AndreKostnader-grp-971 gruppeid='971'>   <AndreKostnaderSpesifisert-grp-4944 gruppeid='4944'>     <DriftsutgifterAndreBeskrivelseSpesifisert-datadef-7894 orid='7894'>a</DriftsutgifterAndreBeskrivelseSpesifisert-datadef-7894>     <DriftsutgifterAndreSpesifisert-datadef-10069 orid='10069'>0</DriftsutgifterAndreSpesifisert-datadef-10069>   </AndreKostnaderSpesifisert-grp-4944>   <DriftsutgifterLysBrenselRenholdEgenBoligdel-datadef-7896 orid='7896'>0</DriftsutgifterLysBrenselRenholdEgenBoligdel-datadef-7896>   <DriftsutgifterEgenBoligdel-datadef-22102 orid='22102'>0</DriftsutgifterEgenBoligdel-datadef-22102> </AndreKostnader-grp-971> <UtgifterFastEiendom-datadef-7918 orid='7918'>0</UtgifterFastEiendom-datadef-7918></Kostnader-grp-236><Nettoinntekt-grp-4945 gruppeid='4945'> <InntektNetto-datadef-28169 orid='28169'>0</InntektNetto-datadef-28169> <InntektOverfortEktefelle-datadef-28170 orid='28170'>0</InntektOverfortEktefelle-datadef-28170> <LeieinntekterNettoOverskudd-datadef-7897 orid='7897'>0</LeieinntekterNettoOverskudd-datadef-7897> <LeieinntekterNettoUnderskudd-datadef-14188 orid='14188'>0</LeieinntekterNettoUnderskudd-datadef-14188></Nettoinntekt-grp-4945><Kontrollsporsmal-grp-239 gruppeid='239'> <OmfatterKostnadeneNoeAvFolgende-grp-2330 gruppeid='2330'>   <UtgifterSkattFormueInntekt-datadef-7911 orid='7911'>Nei</UtgifterSkattFormueInntekt-datadef-7911>   <UtgifterSkatterFormueInntektBelop-datadef-7912 orid='7912'>0</UtgifterSkatterFormueInntektBelop-datadef-7912>   <UtgifterGodtgjoringHuseierMv-datadef-7913 orid='7913'>Ja</UtgifterGodtgjoringHuseierMv-datadef-7913>   <UtgifterGodtgjoringHuseierMvBelop-datadef-7914 orid='7914'>0</UtgifterGodtgjoringHuseierMvBelop-datadef-7914>   <UtgifterKontingentHuseierforeninger-datadef-7915 orid='7915'>Nei</UtgifterKontingentHuseierforeninger-datadef-7915>   <UtgifterKontingentHuseierforeningerBelop-datadef-7916 orid='7916'>0</UtgifterKontingentHuseierforeningerBelop-datadef-7916> </OmfatterKostnadeneNoeAvFolgende-grp-2330></Kontrollsporsmal-grp-239></Skjema>"
}

/*
 auth error:
 <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
    <s:Body>
       <s:Fault>
          <faultcode>s:Client</faultcode>
          <faultstring xml:lang="nb-NO">An errror occurred</faultstring>
          <detail>
             <AltinnFault xmlns="http://www.altinn.no/services/common/fault/2009/10" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
                <AltinnErrorMessage>Incorrect username/password/pin given for user</AltinnErrorMessage>
                <AltinnExtendedErrorMessage>No information available</AltinnExtendedErrorMessage>
                <AltinnLocalizedErrorMessage>Incorrect username/password/pin given for user</AltinnLocalizedErrorMessage>
                <ErrorGuid>b58ccf4c-4c51-43bc-8f0e-8fd055a799b3</ErrorGuid>
                <ErrorID>989</ErrorID>
                <UserGuid>-no value-</UserGuid>
                <UserId>62689</UserId>
             </AltinnFault>
          </detail>
       </s:Fault>
    </s:Body>
 </s:Envelope>
 
 other error:
 <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
    <s:Body>
       <s:Fault>
          <faultcode>s:Client</faultcode>
          <faultstring xml:lang="nb-NO">An error occurred</faultstring>
          <detail>
             <AltinnFault xmlns="http://www.altinn.no/services/common/fault/2009/10" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
                <AltinnErrorMessage>Your request suffered from a non-functional error. If this persist, please report it to the system administrator. Please include the id concerning this speciffic error [1e4e9931-cad9-49dc-b176-e0b42109cad9].</AltinnErrorMessage>
                <AltinnExtendedErrorMessage>No information available</AltinnExtendedErrorMessage>
                <AltinnLocalizedErrorMessage>An error occured: The formatter threw an exception while trying to deserialize the message: There was an error while trying to deserialize parameter http://www.altinn.no/services/ServiceEngine/ReporteeElementList/2009/10:languageID. The InnerException message was 'There was an error deserializing the object of type System.Int32. The value '' cannot be parsed as the type 'Int32'.'.  Please see InnerException for more details.</AltinnLocalizedErrorMessage>
                <ErrorGuid>1e4e9931-cad9-49dc-b176-e0b42109cad9</ErrorGuid>
                <ErrorID>0</ErrorID>
                <UserGuid>-no value-</UserGuid>
                <UserId>62689</UserId>
             </AltinnFault>
          </detail>
       </s:Fault>
    </s:Body>
 </s:Envelope>
 */


