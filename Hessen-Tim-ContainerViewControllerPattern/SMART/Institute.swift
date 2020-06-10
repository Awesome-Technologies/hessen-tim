//
//  InstituteConnect.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 27.11.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import Foundation
import SMART

extension String {
//: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }

//: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

class Institute {
    enum InstituteError: Error {
        case runtimeError(String)
    }
    
    static let shared = Institute()
    
    private init(){}
    
    private (set) var client: Client?
    
    public var photoName = 0
    
    var galleryVC:GalleryViewController?
    var serviceRequestID = ""
    var serviceRequestDraftObject: ServiceRequest? = nil
    var sereviceRequestObject: ServiceRequest? = nil
    var patientObject: Patient? = nil
    var observationWeight: Observation? = nil
    var observationHeight: Observation? = nil
    var coverageObject:Coverage? = nil
    var images:Dictionary<String, Media> = [:]
    
    
    //let serverUrl = "http://hapi.fhir.org/baseR4"
    let serverUrl = "https://tim.amp.institute/hapi-fhir-jpaserver/fhir/"
    
    func connect(callback: @escaping (InstituteError?) -> ()) {
        guard client?.server == nil else {
            callback(nil)
            return
        }
        
        if let url = URL(string: serverUrl) {
            let server = Server(baseURL: url)
            client = Client(server: server)
            client?.ready(callback: { (error) in
                if let error = error as? FHIRError {
                    let institureError = InstituteError.runtimeError("Error connecting to server. \(error.description)")
                    callback(institureError)
                } else {
                    print("Success!")
                    callback(nil)
                }
            })
        } else {
            let institureError = InstituteError.runtimeError("Server URL couldn't be parsed")
            callback(institureError)
        }
    }
    
    
    func createPatient(firstName: String, familyName: String, gender: String, birthday: String, weight: String, height: String, coverageName: String, clinicName: String,  doctorName: String, contactNumber: String, completion:@escaping (() -> Void)) {
        print("createPatient")
        
        DispatchQueue.global(qos: .background).async {
            
            var patient = Patient()
            patient._server = self.client?.server
            patient.active = true
            patient.gender = AdministrativeGender(rawValue: gender)
            
            var patientName = HumanName()
            patientName.family = FHIRString(familyName)
            patientName.given = [FHIRString(firstName)]
            
            patient.name = [HumanName()]
            patient.name?.append(patientName)
            patient.birthDate = FHIRDate(string: birthday)
            
            patient.contact = [PatientContact()]
            
            var pc = PatientContact()
            pc.telecom = [ContactPoint()]
            
            var docName = HumanName()
            docName.family = FHIRString(doctorName)
            
            pc.name = docName
            
            var doctorNumber = ContactPoint()
            doctorNumber.value = FHIRString(contactNumber)
            
            pc.telecom?.append(doctorNumber)
            
            var adress = Address()
            adress.use = AddressUse(rawValue: "work")
            adress.text = FHIRString(clinicName)
            pc.address = adress
            
            patient.contact?.append(pc)
            
            if let client = Institute.shared.client {
                patient.createAndReturn(client.server) { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        self.patientObject = patient
                        print("PatientCreationSucceded")
                        self.createWeightVitalSigns(weight: weight, height: height, coverage: coverageName, completion: completion)
                    }
                }
                
            }
        }
        
    }
    
    func updateExistingPatient(firstName: String, familyName: String, gender: String, birthday: String, weight: String, height: String, insuranceName: String, clinicName: String,  doctorName: String, contactNumber: String, completion:@escaping (() -> Void)) {
        print("createPatient")
        
        
            
            self.patientObject!.gender = AdministrativeGender(rawValue: gender)
            
            var patientName = HumanName()
            patientName.family = FHIRString(familyName)
            patientName.given = [FHIRString(firstName)]
            
            self.patientObject!.name = [HumanName()]
            self.patientObject!.name?[0] = patientName
            self.patientObject!.birthDate = FHIRDate(string: birthday)
            
            self.patientObject!.contact = [PatientContact()]
            
            var pc = PatientContact()
            pc.telecom = [ContactPoint()]
            
            var docName = HumanName()
            docName.family = FHIRString(doctorName)
            
            pc.name = docName
            
            var doctorNumber = ContactPoint()
            doctorNumber.value = FHIRString(contactNumber)
            
            pc.telecom?[0] = doctorNumber
            
            var adress = Address()
            adress.use = AddressUse(rawValue: "work")
            adress.text = FHIRString(clinicName)
            pc.address = adress
            
            self.patientObject!.contact?[0] = pc
            
            DispatchQueue.global(qos: .background).async {
                self.patientObject!.update() { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("PatientResourceUpdateSucceded")
                        self.updateWeightVitalSigns(weight: weight)
                        self.updateHeightVitalSigns(height: height)
                        self.updateCoverage(name: insuranceName)
                        completion()
                    }
                }
                
            }
        
    }
    
    
    func createWeightVitalSigns(weight: String, height: String, coverage: String, completion: @escaping ()->Void) {
        
        var weightObserv = Observation()
        weightObserv.status = ObservationStatus(rawValue: "preliminary")
        var category = [CodeableConcept()]
        
        var ccVital = CodeableConcept()
        ccVital.text = FHIRString("vital-signs")
        ccVital.coding = [Coding()]
        
        var codeVital = Coding()
        codeVital.system = FHIRURL("http://terminology.hl7.org/CodeSystem/observation-category")
        codeVital.code = "vital-signs"
        codeVital.display = "Vital Signs"
        
        ccVital.coding?.append(codeVital)
        category.append(ccVital)
        weightObserv.category = category
        
        var ccCode = CodeableConcept()
        ccCode.coding = [Coding()]
        
        var codeCode = Coding()
        codeCode.system = FHIRURL("http://loinc.org")
        codeCode.code = "29463-7"
        codeCode.display = "Body Weight"
        
        ccCode.coding?.append(codeCode)
        weightObserv.code = ccCode
        
        do {
            try weightObserv.subject = weightObserv.reference(resource: self.patientObject!)
        } catch {
            print(error)
        }
        
        weightObserv.effectiveDateTime = DateTime.now
        //weightObserv.valueQuantity
        
        var valQuant = Quantity()
        valQuant.value = FHIRDecimal(weight)
        valQuant.unit = "kg"
        
        weightObserv.valueQuantity = valQuant
        
        if let client = Institute.shared.client {
            weightObserv.createAndReturn(client.server) { error in
                if let error = error as? FHIRError {
                    print(error)
                } else {
                    print("WeightObservationCreationSucceded")
                    
                    DispatchQueue.global(qos: .background).async {
                        weightObserv.update() { error in
                            if let error = error as? FHIRError {
                                print(error)
                            } else {
                                print("WeightResourceUpdateSucceded")
                                self.observationWeight = weightObserv
                                self.createHeightVitalSigns(height: height, coverage: coverage, completion: completion)
                            }
                        }
                    }
                    
                }
            }
            
            // check error
        }
    
    }
    
    func updateWeightVitalSigns(weight: String) {
        
        self.observationWeight!.effectiveDateTime = DateTime.now
        //weightObserv.valueQuantity
        
        var valQuant = Quantity()
        valQuant.value = FHIRDecimal(weight)
        valQuant.unit = "kg"
        
        self.observationWeight!.valueQuantity = valQuant
    
        DispatchQueue.global(qos: .background).async {
            self.observationWeight!.update() { error in
                if let error = error as? FHIRError {
                    print(error)
                } else {
                    print("WeightResourceUpdateSucceded")
                }
            }
        }
    
    }
    
    
    
    func createHeightVitalSigns(height: String, coverage: String, completion: @escaping()->Void) {
        
        var heightObserv = Observation()
        heightObserv.status = ObservationStatus(rawValue: "final")
        var category = [CodeableConcept()]
        
        var ccVital = CodeableConcept()
        ccVital.text = FHIRString("vital-signs")
        ccVital.coding = [Coding()]
        
        var codeVital = Coding()
        codeVital.system = FHIRURL("http://terminology.hl7.org/CodeSystem/observation-category")
        codeVital.code = "vital-signs"
        codeVital.display = "Vital Signs"
        
        ccVital.coding?.append(codeVital)
        category.append(ccVital)
        heightObserv.category = category
        
        var ccCode = CodeableConcept()
        ccCode.coding = [Coding()]
        
        var codeCode = Coding()
        codeCode.system = FHIRURL("http://loinc.org")
        codeCode.code = "8302-2"
        codeCode.display = "Body Height"
        
        ccCode.coding?.append(codeCode)
        heightObserv.code = ccCode
        
        do {
            try heightObserv.subject = heightObserv.reference(resource: self.patientObject!)
        } catch {
            print(error)
        }
        
        heightObserv.effectiveDateTime = DateTime.now
        //weightObserv.valueQuantity
        
        var valQuant = Quantity()
        valQuant.value = FHIRDecimal(height)
        valQuant.unit = "cm"
        
        heightObserv.valueQuantity = valQuant
        
        if let client = Institute.shared.client {
            heightObserv.createAndReturn(client.server) { error in
                if let error = error as? FHIRError {
                    print(error)
                } else {
                    print("HeightObservationCreationSucceded")
                    DispatchQueue.global(qos: .background).async {
                        heightObserv.update() { error in
                            if let error = error as? FHIRError {
                                print(error)
                            } else {
                                print("HeightResourceUpdateSucceded")
                                self.observationHeight = heightObserv
                                self.createCoverage(name: coverage, completion:completion)
                            }
                        }
                    }
                    
                }
            }
            
            // check error
        }
    
    }
    
    func updateHeightVitalSigns(height: String) {
        
        self.observationHeight!.effectiveDateTime = DateTime.now
        //weightObserv.valueQuantity
        
        var valQuant = Quantity()
        valQuant.value = FHIRDecimal(height)
        valQuant.unit = "cm"
        
        self.observationHeight!.valueQuantity = valQuant
        
        DispatchQueue.global(qos: .background).async {
            self.observationHeight!.update() { error in
                if let error = error as? FHIRError {
                    print(error)
                } else {
                    print("HeightResourceUpdateSucceded")
                }
            }
        }
    
    }
    
    func createCoverage(name: String, completion: @escaping()->Void){
        
        DispatchQueue.global(qos: .background).async {
            var cover = Coverage()
            cover.status = FinancialResourceStatusCodes(rawValue: "active")
            //cover.type = CodeableConcept()
            //cover.type?.text = FHIRString("Insurance")
            cover.class = [CoverageClass()]
            cover.class![0].name = FHIRString(name)
            cover.class![0].type = CodeableConcept()
            cover.class![0].type?.text = FHIRString("Insurance")
            cover.class![0].value = FHIRString("Insurance")
            cover.policyHolder = Reference()
            do {
                try cover.policyHolder = cover.reference(resource: self.patientObject!)
            } catch {
                print(error)
            }
            
            cover.beneficiary = Reference()
            do {
                try cover.beneficiary = cover.reference(resource: self.patientObject!)
            } catch {
                print(error)
            }
            
            cover.payor = [Reference()]
            do {
                var ref = Reference()
                try ref = cover.reference(resource: self.patientObject!)
                cover.payor?.append(ref)
            } catch {
                print(error)
            }
            
            if let client = Institute.shared.client {
                cover.createAndReturn(client.server) { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("CoverageCreationSucceded")
                        DispatchQueue.global(qos: .background).async {
                            cover.update() { error in
                                if let error = error as? FHIRError {
                                    print(error)
                                } else {
                                    print("CoverageUpdateSucceded")
                                    self.coverageObject = cover
                                    completion()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateCoverage(name: String) {
        
        self.coverageObject!.class![0].name = FHIRString(name)
        
        DispatchQueue.global(qos: .background).async {
            self.coverageObject!.update() { error in
                if let error = error as? FHIRError {
                    print(error)
                } else {
                    print("CoverageUpdateSucceded")
                }
            }
        }
    
    }
    
    
    func createServiceRequest(category: String, completion:@escaping (() -> Void)){
        
        DispatchQueue.global(qos: .background).async {
            
            var serv = ServiceRequest()
            serv._server = self.client?.server
            serv.status = RequestStatus(rawValue: "draft")
            serv.intent = RequestIntent(rawValue: "proposal")
            serv.category = [CodeableConcept()]
            
            var cc = CodeableConcept()
            cc.text = FHIRString(category)
            
            serv.category?.append(cc)
            serv.priority = RequestPriority(rawValue: "asap")
            serv.subject = Reference()
            
            print(self.patientObject?._server?.baseURL)
            do {
                try serv.subject = serv.reference(resource: self.patientObject!)
            } catch {
                print(error)
            }
            serv.authoredOn = DateTime.now
            serv.requester = Reference()
            
            do {
                try serv.requester = serv.reference(resource: UserLoginCredentials.shared.organizationProfile!)
            } catch {
                print(error)
            }
            
            serv.performer = [Reference()]
            
            do {
                var ref = Reference()
                try ref = serv.reference(resource: UserLoginCredentials.shared.performerOrganizationProfile!)
                serv.performer?.append(ref)
            } catch {
                print(error)
            }
            
            serv.reasonReference = [Reference()]
            
            serv.note = [Annotation()]
            serv.note![0].text = FHIRString("")
            
            if let client = Institute.shared.client {
                serv.createAndReturn(client.server) { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("ServiceRequestCreationSucceded")
                        self.sereviceRequestObject = serv
                        self.serviceRequestDraftObject = serv
                        completion()
                        //print("I have created the ServiceRewuest with the ID:")
                        //print(serv.id)
                        self.serviceRequestID = serv.id?.string ?? "noID"
                    }
                }
                
                // check error
            }
        }
    }
    
    func updateExistingServiceRequest(status: String, intent: String, category: String, priority: String, patientID: String, organizationID: String, completion:@escaping (() -> Void)){
        self.sereviceRequestObject!.subject = Reference()
        
        print(self.patientObject?._server?.baseURL)
        do {
            try self.sereviceRequestObject!.subject = self.sereviceRequestObject!.reference(resource: self.patientObject!)
        } catch {
            print(error)
        }
        self.sereviceRequestObject!.authoredOn = DateTime.now
        
        DispatchQueue.global(qos: .background).async {
            self.sereviceRequestObject!.update() { error in
                if let error = error as? FHIRError {
                    print(error)
                } else {
                    print("ServiceRequestUpdateSucceded")
                    completion()
                }
            }
        }
    }
    
    

    func changeAllMediaStatus(){
        getAllObservationsForPatient(completion: { (observations) in
            for observation in observations {
                self.getAllImagesFromObservastion(observation: observation, completion: { (imageIDs) in
                    self.changeMediaStatus(allMedia: imageIDs)
                    
                })
            }
        })
    }
    
    func getAllObservationsForPatient(completion: @escaping (([Observation]) -> Void)) {
        print("getAllObservationsForPatient")
        
        let search = Observation.search(["based-on": ["$type": "ServiceRequest", "subject":["$type": "Patient", "_id":self.patientObject?.id?.description]]]  )
        
        search.perform(self.client!.server) { bundle, error in
            if nil != error {
                // there was an error
            }
            else {
                let obs = bundle?.entry?
                    .filter() { return $0.resource is Observation }
                    .map() { return $0.resource as! Observation }
                
                print("We found some Observations:")
                print(obs?.count)
                
                if obs != nil {
                    if(!obs!.isEmpty){
                        completion(obs!)
                        for observation in obs! {
                            print(observation.id)
                            //self.searchObservationTypeInServiceRequestWithID(id: sRequest.id!.string, type: type, completion: completion)
                        }

                    }
                }
                
            }
        }
        
    }
    
    
    func getAllImagesOfTypeForPatient(type: String, completion: @escaping (([Media]) -> Void)) {
           print("getAllObservationsOfTypeForPatient")
        
            //DispatchQueue.global(qos: .background).async {
            
        let search = Media.search(["based-on": ["$type": "ServiceRequest", "subject":["$type": "Patient", "_id":self.patientObject?.id?.description]], "modality":["$text": type], "_summary": "data"])

                DispatchQueue.global(qos: .background).async {
                    search.perform(self.client!.server) { bundle, error in
                               if nil != error {
                                   print("ERROR")
                                   print(error)
                               }
                               else {
                                   let med = bundle?.entry?
                                       .filter() { return $0.resource is Media }
                                       .map() { return $0.resource as! Media }
                                   
                                   print("We found some Media:")
                                   print(med?.count)
                                   
                                   if med != nil {
                                       if(!med!.isEmpty){
                                           completion(med!)
                                           
                                       }
                                   }
                                   
                               }
                           }
                }
            //}

           
           
           
       }
    
    
    func getAllPreviewImagesOfTypeForPatient(filterDate: String,type: String, completion: @escaping (([Media]) -> Void)) {
        print("getAllPreviewImagesOfTypeForPatient")
        
        DispatchQueue.global(qos: .background).async {
            
            let search = Media.search(["based-on": ["$type": "ServiceRequest", "subject":["$type": "Patient", "_id":self.patientObject?.id?.description],"status":"active"], "modality":["$text": type], "_summary":"true", "_sort":"-created", "created":"le" + filterDate])
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                search.perform(self.client!.server) { bundle, error in
                    if nil != error {
                        print("ERROR")
                        print(error)
                    }
                    else {
                        let med = bundle?.entry?
                            .filter() { return $0.resource is Media }
                            .map() { return $0.resource as! Media }
                        
                        print("We found some Preview:")
                        print(med?.count)
                        
                        if med != nil {
                            if(!med!.isEmpty){
                                completion(med!)
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func getAllImagesFromObservastion(observation: Observation, completion: @escaping (([String]) -> Void)) {
        print("getAllImagesFromObservastion")
        
        
        print("I have the Observation:")
        var imageIDs = [String]()
        for id in observation.derivedFrom! {
            var stringReference = id.reference?.string
            if let range = stringReference!.range(of: "/") {
                let newID = stringReference![range.upperBound...]
                print(newID) // prints "123.456.7891"
                if (newID != "" && newID != "replace_mediaID") {
                    imageIDs.append(String(newID))
                }
            }
        }
        completion(imageIDs)
        
    }
    
    
    func changeMediaStatus(allMedia:[String]){
        print("changeMediaStatus")
        var mediaIDs = allMedia
        
        for id in allMedia {
            Media.read(String(id), server: self.client!.server){ resource, error in
                if let error = error as? FHIRError {
                    print(error)
                    //completion!(id, true)
                } else if resource != nil {
                    var testMedia:Media = resource as! Media
                    testMedia.status = EventStatus(rawValue: "preparation")
                    
                     testMedia.update() { error in
                        if let error = error as? FHIRError {
                            print(error)
                        } else {
                            print("MediaUpdateSucceded")
                        }
                    }
            
                    
                }
            }
            
        }
        
    }
    
    /*
    func getAllImagesFromID(allMedia:[String],completion: ((String, Bool) -> Void)? = nil){
        print("mediaCall")
            var mediaIDs = allMedia
            
            for id in allMedia {
                Media.read(String(id), server: self.client!.server){ resource, error in
                    if let error = error as? FHIRError {
                        print(error)
                        //completion!(id, true)
                    } else if resource != nil {
                        var testMedia:Media = resource as! Media
                        let imageData = testMedia.content?.data
                        let decodedData = Data(base64Encoded: imageData!.value)!
                        self.saveImageInDirectory(imageData: decodedData, name:String(id))
                        if(testMedia.status!.rawValue == "completed"){
                            completion!(id, true)
                        }else {
                            completion!(id, false)
                        }
                        
                    }
                }
                
            }
            
        }
    */
    
    
    
    
    func updateServiceRequest(id: String, status: String, intent: String, category: String, priority: String, authoredOn: String, patientID: String, organizationID: String){
        
        var replaced = ""
        if let filepath = Bundle.main.path(forResource: "updateServiceRequest", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                replaced = contents.replacingOccurrences(of: "replace_ID", with: id)
                replaced = replaced.replacingOccurrences(of: "replace_status", with: status)
                replaced = replaced.replacingOccurrences(of: "replace_intent", with: intent)
                replaced = replaced.replacingOccurrences(of: "replace_category", with: category)
                replaced = replaced.replacingOccurrences(of: "replace_priority", with: priority)
                replaced = replaced.replacingOccurrences(of: "replace_authoredOn", with: authoredOn)
                replaced = replaced.replacingOccurrences(of: "replace_patientID", with: patientID)
                replaced = replaced.replacingOccurrences(of: "replace_organizationID", with: organizationID)
                replaced = replaced.replacingOccurrences(of: "replace_observationID", with: "TextUpdate")
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        
        let servRequestURL = writeNewFile(replacedText: replaced, filename: "updateServiceRequest")
        updateResource(createdFile: servRequestURL, resourceType: "serviceRequest")
        
        var sr = ServiceRequest()
        sr.reasonReference = [Reference()]
        var ref = Reference()
        ref.reference?.string = "blablubb"
        sr.reasonReference?.append(ref)
        
    }
    
    
    func createOrganization(organizationName: String, contactName: String, contactNumber: String){
        
        var replaced = ""
        if let filepath = Bundle.main.path(forResource: "createOrganization", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                replaced = contents.replacingOccurrences(of: "replace_organizationName", with: organizationName)
                replaced = replaced.replacingOccurrences(of: "replace_contactName", with: contactName)
                replaced = replaced.replacingOccurrences(of: "replace_contactNumber", with: contactNumber)
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        
        let organizationURL = writeNewFile(replacedText: replaced, filename: "createOrganization")
        createResource(createdFile: organizationURL, resourceType: "organization", reference: nil)
        
    }
    
    func saveImage(imageData: Data,observationType: ObservationType, completion: @escaping (String) -> Void){
        
        print("saveImage")
        
        var observID = ""
        var obsType = ""
        
        //var servRequest = searchServiceRequestWithID(id: "61")
        
        //1. Rausfinden, ob dieser Service Request schon eine Observation mit dem gegebenen Typ hat
        
        
        
        switch observationType {
        case .Anamnesis:
            obsType = "Anamnese"
        case .MedicalLetter:
            obsType = "Arztbriefe"
        case .Haemodynamics:
            obsType = "Haemodynamik"
        case .Respiration:
            obsType = "Beatmung"
        case .BloodGasAnalysis:
            obsType = "Blutgasanalyse"
        case .Perfusors:
            obsType = "Perfusoren"
        case .InfectiousDisease:
            obsType = "Infektiologie"
        case .Radeology:
            obsType = "Radiologie"
        case .Lab:
            obsType = "Labor"
        case .Others:
            obsType = "Sonstige"
        case .NONE:
            obsType = "NONE"
        default:
            obsType = ""
        }
        
        self.createImageMedia(imageData: imageData,category: obsType, completion: { media in
            //completion(media.id!.description)
            completion("test")
        })
        
    }
    
    func updateImageMedia(name: String, imageData: Data, completion: @escaping (String) -> Void){
        print("updateImageMedia")
        var media = images[name]
        let base64Encoded = imageData.base64EncodedString()
        if media != nil {
            media?.content?.data = Base64Binary(value:base64Encoded)
            images[name] = media
            self.updateImage(media: media!)
            completion(name)
        }else{
            /**
             The Medie thet we are working on got replaced with an image from the server, and we are still working on the old one
             So we try to update the new Image instead
             */
            let replacedMedia =  images.filter{ $0.value.note![1].text!.description == name }
            if let med = replacedMedia.first?.value{
                var medKey = replacedMedia.first?.key
                med.content?.data = Base64Binary(value:base64Encoded)
                images[medKey!] = med
                self.updateImage(media: med)
                completion(medKey!)
            }else{
                print("error: No media file presen for update")
            }
        }
    }
    
    func updateImageNote(name: String, imageNote: String, completion: @escaping () -> Void){
        print("updateImageNote")
        var media = images[name]
        if media != nil {
            media?.note![0].text = FHIRString(imageNote)
            images[name] = media
            self.updateImage(media: media!)
            completion()
        }else{
            /**
             The Medie thet we are working on got replaced with an image from the server, and we are still working on the old one
             So we try to update the new Image instead
             */
            let replacedMedia =  images.filter{ $0.value.note![1].text!.description == name }
            if let med = replacedMedia.first?.value{
                var medKey = replacedMedia.first?.key
                med.note![0].text = FHIRString(imageNote)
                images[medKey!] = med
                self.updateImage(media: med)
                completion()
            }else{
                print("error: No media file presen for update")
            }
            
        }
        
    }
    
    func createImageMedia(imageData: Data, category: String, completion: @escaping (Media) -> Void){
    print("createImageMedia")
    
    DispatchQueue.global(qos: .background).async {
        
        var med = Media()
        med.status = EventStatus(rawValue: "preparation")
        
        var cc = CodeableConcept()
        cc.text = FHIRString(category)
        
        med.modality = cc
        med.createdDateTime = DateTime.now
        
        var image = Attachment()
        image.contentType = "image/jpeg"
        //image.data = Base64Binary(imageData.base64EncodedString() as Base64Binary
        //let str = String(decoding: data, as: UTF8.self)
        let base64Encoded = imageData.base64EncodedString()
        image.data = Base64Binary(value:base64Encoded)
        
        med.content = image
        
        if(self.sereviceRequestObject != nil){
            do {
                med.basedOn = [Reference()]
                try med.basedOn?.append(med.reference(resource: self.sereviceRequestObject!))
            } catch {
                print(error)
            }
        }
        
        med.note = [Annotation()]
        med.note![0].text = FHIRString("test")

        //Create a UUID as a local ID, to replace this image with the image, that is processed througt the server
        let uuid = UUID().uuidString
        print("uuid: " + uuid )
        //We create a new Note and save the uuid there
        var annotation = Annotation()
        annotation.text = FHIRString(uuid)
        
        med.note?.append(annotation)
        //We add the local image to the dict
        self.images[uuid] = med
        //We display the local image in the gallery
        completion(med)
        
            if let client = Institute.shared.client {
                med.createAndReturn(client.server) { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("MediaCreationSucceded")
                        print(med.id)
                        //When the server finishes saving the image, the new image is loaded in the dict
                        self.replaceMediaInCache(media: med)
                        self.updateImage(media: med)
                    }
                }
                
                // check error
            }
        }
    }
    
    func replaceMediaInCache(media: Media){
        //The old image gets deleted
        if let entry = images.removeValue(forKey: media.note![1].text!.description) {
            //The new image is added
            self.images[media.id!.description] = media
            reloadImage(newImageName: media.id!.description)
        }
    }
    
    func updateImage(media: Media){
        DispatchQueue.global(qos: .background).async {
            media.update() { error in
                if let error = error as? FHIRError {
                    print(error)
                } else {
                    print("MediaUpdateSucceded")
                }
                /**
                 Check if the Service Request was already deleted
                 Wich means, that we already left te MedicalDataView and there are still unfinished background processes
                 */
                if let sr = self.sereviceRequestObject {
                    sr.update() { error in
                        if let error = error as? FHIRError {
                            print(error)
                        } else {
                            print("ServicerequestUpdateSucceded")
                        }
                    }
                    
                }
                
            }
        }
        /*
        Media.read(String(self.mediaObject!.id!.description), server: self.client!.server){ resource, error in
            if let error = error as? FHIRError {
                print(error)
                //completion!(id, true)
            } else if resource != nil {
                var testMedia:Media = resource as! Media
                //testMedia.status = EventStatus(rawValue: "preparation")
                
                 testMedia.update() { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("MediaUpdateSucceded")
                    }
                }
        
                
            }
        }
        */
    }
    
    func getMediaWithID(id: String, completion: @escaping (String) -> Void){
        DispatchQueue.global(qos: .background).async {
            Media.read(id, server: self.client!.server){ resource, error in
                if let error = error as? FHIRError {
                    print(error)
                    //completion!(id, true)
                } else if resource != nil {
                    var med:Media = resource as! Media
                    //testMedia.status = EventStatus(rawValue: "preparation")
                    self.images[med.id!.description] = med
                    completion(med.id!.description)
                    
                }
            }
        }
        
    }
    
    /**
     Creates a new JSON file with the replacedText content in the documentDirectory, so a new ressource can be instantiated from it
     */
    private func writeNewFile(replacedText: String, filename: String) -> URL{
        let fileName = filename
        let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        var url = URL(string:"")
        
        // If the directory was found, we write a file to it and read it back
        if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("json") {
            
            // Write to the file named Test
            //let outString = "Write this text to the file"
            do {
                try replacedText.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
            
            // Then reading it back from the file
            var inString = ""
            do {
                inString = try String(contentsOf: fileURL)
            } catch {
                print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            }
            //print("Read from the file: \(inString)")
            url = fileURL
            
        }
        return url!
    }
    
    
    private func createResource(createdFile: URL, resourceType: String, reference: DomainResource?, completion: (() -> Void)? = nil){
        print("createResource")
        
        let data = NSData(contentsOf: createdFile)!
        var returnID = ""
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data as Data, options: []) as? FHIRJSON {
                
                switch resourceType {
                case "patient":
                    var newPatient = try Patient(json: json)
                    if let client = Institute.shared.client {
                        newPatient.create(client.server) { error in
                            if let error = error as? FHIRError {
                                print(error)
                            } else {
                                print("PatientCreationSucceded")
                                
                                if let name = newPatient.name?[0] {
                                    print(name.family?.string)
                                    print(name.given?[0].string)
                                    print(newPatient.gender)
                                    print("---")
                                    
                                }
                            }
                        }
                        
                        // check error
                    }
                case "serviceRequest":
                    var newServRequest = try ServiceRequest(json: json)
                    if let client = Institute.shared.client {
                        newServRequest.create(client.server) { error in
                            if let error = error as? FHIRError {
                                print(error)
                            } else {
                                self.serviceRequestID = newServRequest.id?.string ?? "noID"
                                print(self.serviceRequestID)
                                print("ServiceRequestCreationSucceded")
                            }
                        }
                        
                        // check error
                    }
                case "imageMedia":
                    print("asyne")
                    var newMedia = try Media(json: json)
                    if let client = Institute.shared.client {
                        newMedia.createAndReturn(client.server) { error in
                            if let error = error as? FHIRError {
                                print(error)
                            } else {
                                print("MediaCreationSucceded")
                                if(reference != nil){
                                    var observation:Observation = reference as! Observation
                                    
                                    do {
                                        try observation.derivedFrom?.append(observation.reference(resource: newMedia))
                                    } catch {
                                        print(error)
                                    }
                                    
                                    //print("Added the refference")
                                    //print(observation.derivedFrom)
                                    
                                    observation.update() { error in
                                        if let error = error as? FHIRError {
                                            print(error)
                                        } else {
                                            print("ObservationUpdateSucceded")
                                        }
                                    }
                                }
                            }
                        }
                        
                        // check error
                    }
                case "organization":
                var newOrganization = try Organization(json: json)
                if let client = Institute.shared.client {
                    newOrganization.createAndReturn(client.server) { error in
                        if let error = error as? FHIRError {
                            print(error)
                        } else {
                            print("OrganizationCreationSucceded")
                            returnID = newOrganization.id?.string ?? "noID"
                            print("I have created the organization with the ID:")
                            print(returnID)
                        }
                    }
                    
                    // check error
                }
                default:
                    print("Error in ResourceCreation")
                }
                
            }
        } catch{
            print(error)
        }

    }
    
    private func updateResource(createdFile: URL, resourceType: String) -> String{
        
        let data = NSData(contentsOf: createdFile)!
        var returnID = ""
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data as Data, options: []) as? FHIRJSON {
                
                switch resourceType {
                case "serviceRequest":
                    var newServRequest = try ServiceRequest(json: json)
                    newServRequest._server = client?.server
                        newServRequest.update() { error in
                            if let error = error as? FHIRError {
                                print(error)
                            } else {
                                print("ServiceRequestCreationSucceded")
                            }
                        }
                        
                        // check error
            
                default:
                    print("Error in ResourceUpdate")
                }
                
            }
        } catch{
            print(error)
        }
        
        return returnID

    }
    
    
    func searchAllServiceRequests(){
        let search = ServiceRequest.search([])
        
        search.perform(client!.server) { bundle, error in
            if nil != error {
                // there was an error
            }
            else {
                let servReq = bundle?.entry?
                    .filter() { return $0.resource is ServiceRequest }
                    .map() { return $0.resource as! ServiceRequest }
                    
                    // now `bruces` holds all known Patient resources
                    // named Bruce and born earlier than 1970
                
                print(servReq)
            }
        }
    }
    
    func searchServiceRequestWithID(id: String, completion:@escaping (() -> Void)) {
        print("searchServiceRequestWithID")
            
        DispatchQueue.global(qos: .background).async {
            ServiceRequest.read(id, server: self.client!.server){ resource, error in
                if let error = error as? FHIRError {
                    print(error)
                } else if resource != nil {
                    self.sereviceRequestObject = resource as! ServiceRequest
                    print("searchServiceRequestWithID: Wir finden den ServiceRequest mit der ID:")
                    print(self.sereviceRequestObject!.id)
                    completion()
                }
            }
        }
    }
    
    
    func searchObservationWithID(id: String, completion:@escaping ((Observation) -> Void)) {
        print("searchObservationWithID:")
        DispatchQueue.global(qos: .background).async {
            //self.loadAllMediaResource(completion: completion)
            let search = Observation.search(["_id": id])
            var returnObserve = Observation()
            
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    // there was an error
                }
                else {
                    let observ = bundle?.entry?
                        .filter() { return $0.resource is Observation }
                        .map() { return $0.resource as! Observation }
                    
                    if observ != nil {
                        if(!observ!.isEmpty){
                            returnObserve =  observ!.first!
                            returnObserve = observ!.first!
                            //print("Testbullshit:")
                            //print(returnObserve.id)
                            completion(returnObserve)


                        }
                    }
                        
                    
                }
            }
        }
        
        //let search = ServiceRequest.search(["subject": "3"])
        
    }
    
    func searchPatientWithID(id: String) {
        print("searchPatientWithID")
        self.patientObject = nil
            //self.loadAllMediaResource(completion: completion)
        Patient.read(id, server: self.client!.server){ resource, error in
            if let error = error as? FHIRError {
                print(error)
            } else if resource != nil {
                self.patientObject = resource as! Patient
                print("Wir finden den Patienten mit der ID")
                print(self.patientObject?.id)
            }
        }

        
    }
    
    
    func searchAllPatientRequests(){
        let search = Patient.search([])
        
        search.perform(client!.server) { bundle, error in
            if nil != error {
                // there was an error
            }
            else {
                let allPatients = bundle?.entry?
                    .filter() { return $0.resource is Patient }
                    .map() { return $0.resource as! Patient }
                    
                    // now `bruces` holds all known Patient resources
                    // named Bruce and born earlier than 1970
                
                print(allPatients)
            }
        }
    }
    
    func searchOnePatient(){
        let search = Patient.search(["_id" : "7"])
        
        search.perform(client!.server) { bundle, error in
            if nil != error {
                // there was an error
            }
            else {
                let allPatients = bundle?.entry?
                    .filter() { return $0.resource is Patient }
                    .map() { return $0.resource as! Patient }
                    
                    // now `bruces` holds all known Patient resources
                    // named Bruce and born earlier than 1970
                
                print(allPatients)
            }
        }
    }
    
    
    func mediaCall(allMedia:[Media],completion: ((String, Bool) -> Void)? = nil){
        print("mediaCall")
        var mediaIDs = allMedia
        
        for med in allMedia {
            
            if med != nil {
                print(med.id?.description)
                let imageData = med.content?.data
                let decodedData = Data(base64Encoded: imageData!.value)!
                self.saveImageInDirectory(imageData: med, name:String(med.id!.description))
                /*
                testMedia.update() { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("MediaUpdateSucceded")
                    }
                }
                */
                if(med.status!.rawValue == "completed"){
                    completion!(med.id!.description, true)
                }else {
                    completion!(med.id!.description, false)
                }
                
            }
            
            /*
            Media.read(med.id!.description, server: self.client!.server){ resource, error in
                if let error = error as? FHIRError {
                    print(error)
                    //completion!(id, true)
                } else if resource != nil {
                    var testMedia:Media = resource as! Media
                    let imageData = testMedia.content?.data
                    let decodedData = Data(base64Encoded: imageData!.value)!
                    self.saveImageInDirectory(imageData: decodedData, name:String(med.id!.description))
                    /*
                    testMedia.update() { error in
                        if let error = error as? FHIRError {
                            print(error)
                        } else {
                            print("MediaUpdateSucceded")
                        }
                    }
                    */
                    if(testMedia.status!.rawValue == "completed"){
                        completion!(med.id!.description, true)
                    }else {
                        completion!(med.id!.description, false)
                    }
                    
                }
                
            }
            */
            
        }
        
    }
    
    func previewMediaCall(allMedia:[Media],completion: (() -> Void)? = nil){
        print("previewMediaCall")
        var mediaIDs = allMedia
        
        for med in allMedia {
            
            if med != nil {
                self.saveImageInDirectory(imageData: med, name:String(med.id!.description))
                
            }
            
        }
        completion!()
    }
    
    func saveImageInDirectory(imageData: Media, name: String){
        
        if(images[name] != nil){
            if(imageData.content?.data == nil && images[name]!.content?.data != nil){
                //When we habe a preview Image, we dont want it to override images in the cache
            }
            
        }else{
            images[name] = imageData
        }
    }
    
    func deleteAllImageMedia(){
        DispatchQueue.global(qos: .background).async {
            let search = Media.search([])
            
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    // there was an error
                }
                else {
                    let allMedia = bundle?.entry?
                        .filter() { return $0.resource is Media }
                        .map() { return $0.resource as! Media }
                        
                        // now `bruces` holds all known Patient resources
                        // named Bruce and born earlier than 1970
                        if allMedia != nil {
                            //print(allMedia)
                            for imageMedia in allMedia! {
                                imageMedia.delete {error in
                                    if nil != error {
                                        print(error)
                                    }
                                }
                            }
                        }
                }
            }
        }
        
    }
    
    
    func deleteAllImageMediaForServicerequest(serviceRequest: ServiceRequest){
        let search = Media.search(["based-on": ["$type": "ServiceRequest", "_id": serviceRequest.id?.description]]  )
        DispatchQueue.global(qos: .background).async {
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    // there was an error
                }
                else {
                    let allMedia = bundle?.entry?
                        .filter() { return $0.resource is Media }
                        .map() { return $0.resource as! Media }
                        
                        // now `bruces` holds all known Patient resources
                        // named Bruce and born earlier than 1970
                        if allMedia != nil {
                            //print(allMedia)
                            for imageMedia in allMedia! {
                                imageMedia.delete {error in
                                    if nil != error {
                                        print(error)
                                    }
                                }
                            }
                        }
                        
                }
            }
            
        }
    }
    
    func deleteAllServiceRequests(){
        print("deleteAllServiceRequests")
        
        DispatchQueue.global(qos: .background).async {
            let search = ServiceRequest.search([])
            
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    print("Something went wrong")
                    print(error)
                }
                else {
                    let allServReq = bundle?.entry?
                        .filter() { return $0.resource is ServiceRequest }
                        .map() { return $0.resource as! ServiceRequest }
                    
                        print("I have found count ServRequests:")
                    print(allServReq?.count)
                        
                        // now `bruces` holds all known Patient resources
                        // named Bruce and born earlier than 1970
                        if allServReq != nil {
                            //print(allMedia)
                            for sr in allServReq! {
                                print("Server of ServiceRequest")
                                print(sr._server)
                                
                                sr.delete {error in
                                    if nil != error {
                                        print(error)
                                    }
                                }
                            }
                        }
                        
                }
            }
        }
    }
    
    func deleteServiceRequestWithID(serviceRequest: ServiceRequest){
        
        DispatchQueue.global(qos: .background).async {
            ServiceRequest.read(serviceRequest.id!.description, server: self.client!.server){ resource, error in
                if let error = error as? FHIRError {
                    print(error)
                    //completion!(id, true)
                } else if resource != nil {
                    var request:ServiceRequest = resource as! ServiceRequest
                    request.delete {error in
                        if nil != error {
                            print(error)
                        }else{
                            print("deletedServicerequest")
                        }
                    }
                }
            }
        }
    }
    
    func deleteAllObservations(){
        let search = Observation.search([])
        
        search.perform(client!.server) { bundle, error in
            if nil != error {
                // there was an error
            }
            else {
                let allObserv = bundle?.entry?
                    .filter() { return $0.resource is Observation }
                    .map() { return $0.resource as! Observation }
                    
                    // now `bruces` holds all known Patient resources
                    // named Bruce and born earlier than 1970
                    if allObserv != nil {
                        //print(allMedia)
                        for obs in allObserv! {
                            obs.delete {error in
                                if nil != error {
                                    print(error)
                                }
                            }
                        }
                    }
                    
            }
        }
    }
    
    func deleteAllPatients(){
        let search = Patient.search([])
        
        search.perform(client!.server) { bundle, error in
            if nil != error {
                // there was an error
            }
            else {
                let allPatients = bundle?.entry?
                    .filter() { return $0.resource is Patient }
                    .map() { return $0.resource as! Patient }
                    
                    // now `bruces` holds all known Patient resources
                    // named Bruce and born earlier than 1970
                    if allPatients != nil {
                        //print(allMedia)
                        for patient in allPatients! {
                            patient.delete {error in
                                if nil != error {
                                    print(error)
                                }
                            }
                        }
                    }
                    
            }
        }
    }
    
    func deleteAllDiagnosticReports(){
        DispatchQueue.global(qos: .background).async {
            let search = DiagnosticReport.search([])
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    // there was an error
                }
                else {
                    let allReports = bundle?.entry?
                        .filter() { return $0.resource is DiagnosticReport }
                        .map() { return $0.resource as! DiagnosticReport }
                        
                        // now `bruces` holds all known Patient resources
                        // named Bruce and born earlier than 1970
                        if allReports != nil {
                            //print(allMedia)
                            for report in allReports! {
                                report.delete {error in
                                    if nil != error {
                                        print(error)
                                    }
                                }
                            }
                        }
                }
            }
        }
  
    }
    
    
    func clearAllFile() {
        let fileManager = FileManager.default

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!

        print("Directory: \(paths)")

        do
        {
            let fileName = try fileManager.contentsOfDirectory(atPath: paths)

            for file in fileName {
                // For each file in the directory, create full path and delete the file
                let filePath = URL(fileURLWithPath: paths).appendingPathComponent(file).absoluteURL
                try fileManager.removeItem(at: filePath)
            }
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    
    func clearAllLocalImages() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for fileURL in fileURLs {
                if fileURL.pathExtension == "jpeg" {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch  { print(error) }
    }
    
    
    func loadPreviewImagesInBackground(type: String, completion: (() -> Void)? = nil){
        getAllPreviewImagesOfTypeForPatient(filterDate: (self.sereviceRequestObject?.authoredOn!.description)!, type: type, completion: { (medias) in
            self.previewMediaCall(allMedia: medias, completion: completion)
            
        })
    }
    
    /*
    func loadPreviewImagesInBackground(type: String, completion: (([Media]) -> Void)? = nil){
        getAllPreviewImagesOfTypeForPatient(type: type, completion: completion)
    }
    */
    
    
    
    func loadImagesInBackground(type: String, completion: ((String, Bool) -> Void)? = nil){
        getAllImagesOfTypeForPatient(type: type, completion: { (medias) in
            self.mediaCall(allMedia: medias, completion: completion)
            
        })
    }
    
    
    
    func getPatientByID(id : String, completion: @escaping ((Patient) -> Void)) {
        print("getPatientByID")
        
        var patient = Patient()
            
        DispatchQueue.global(qos: .background).async {
            Patient.read(id, server: self.client!.server){ resource, error in
                if let error = error as? FHIRError {
                    print(error)
                } else if resource != nil {
                    patient = resource as! Patient
                    print("Found Patient with the ID")
                    print(patient.id)
                    self.getWeightOfPatient(patient: patient, completion: completion)
                }
            }
        }
    }
    
    func getServiceRequestByID(id : String, completion: @escaping ((ServiceRequest) -> Void)) {
        print("getServiceRequestByID")
        
        var request = ServiceRequest()
            
        DispatchQueue.global(qos: .background).async {
            ServiceRequest.read(id, server: self.client!.server){ resource, error in
                if let error = error as? FHIRError {
                    print(error)
                } else if resource != nil {
                    request = resource as! ServiceRequest
                    print("Found Patient with the ID")
                    completion(request)
                }
            }
        }
    }
    
    
    func getWeightOfPatient(patient:Patient, completion: @escaping ((Patient) -> Void)) {
        print("getWeightOfPatient")
        
        DispatchQueue.global(qos: .background).async {
            let search = Observation.search(["patient":patient.id?.description,"category":"vital-signs","code": "29463-7"])
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    // there was an error
                }
                else {
                    let patientWeight = bundle?.entry?
                        .filter() { return $0.resource is Observation }
                        .map() { return $0.resource as! Observation }
                        
                    self.observationWeight = patientWeight?.first
                    self.getHeightOfPatient(patient: patient, completion: completion)
                    
                }
            }
        }
    }
    
    
    func getHeightOfPatient(patient:Patient, completion: @escaping ((Patient) -> Void)) {
        print("getHeightOfPatient")
        
        DispatchQueue.global(qos: .background).async {
            let search = Observation.search(["patient":patient.id?.description,"category":"vital-signs","code": "8302-2"])
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    // there was an error
                }
                else {
                    let patientHeight = bundle?.entry?
                        .filter() { return $0.resource is Observation }
                        .map() { return $0.resource as! Observation }
                        
                    self.observationHeight = patientHeight?.first
                    self.getCoverage(patient: patient, completion: completion)
                    //completion(patient)
                    
                }
            }
        }
    }
    
    func getCoverage(patient:Patient, completion: @escaping ((Patient) -> Void)) {
        print("getCoverageOfPatient")
        
        DispatchQueue.global(qos: .background).async {
            let search = Coverage.search(["policy-holder":patient.id?.description])
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    // there was an error
                }
                else {
                    let coverages = bundle?.entry?
                        .filter() { return $0.resource is Coverage }
                        .map() { return $0.resource as! Coverage }
                        
                    self.coverageObject = coverages?.first
                    completion(patient)
                }
            }
        }
    }
    
    
    
    func getWeight(patient:Patient, completion: @escaping ((Coverage,Observation, Observation) -> Void)) {
        print("getWeight")
        var weight: Observation?
        
        DispatchQueue.global(qos: .background).async {
            let search = Observation.search(["patient":patient.id?.description,"category":"vital-signs","code": "29463-7"])
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    // there was an error
                }
                else {
                    let patientWeight = bundle?.entry?
                        .filter() { return $0.resource is Observation }
                        .map() { return $0.resource as! Observation }
                    self.observationWeight = patientWeight?.first
                    weight = patientWeight?.first
                    self.getHeight(patient: patient, weight: weight!, completion: completion)
                    
                }
            }
        }
    }
    
    func getHeight(patient:Patient, weight: Observation, completion: @escaping ((Coverage, Observation, Observation) -> Void)) {
        print("getHeightOfPatient")
        var height: Observation?
        
        DispatchQueue.global(qos: .background).async {
            let search = Observation.search(["patient":patient.id?.description,"category":"vital-signs","code": "8302-2"])
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    // there was an error
                }
                else {
                    let patientHeight = bundle?.entry?
                        .filter() { return $0.resource is Observation }
                        .map() { return $0.resource as! Observation }
                    height = patientHeight?.first
                    self.observationHeight = patientHeight?.first
                    self.getInsurance(patient: patient, weight: weight, height: height, completion: completion)
                }
            }
        }
    }
    
    func getInsurance(patient:Patient, weight: Observation?, height: Observation?, completion: @escaping ((Coverage, Observation, Observation) -> Void)) {
        print("getCoverageOfPatient")
        
        DispatchQueue.global(qos: .background).async {
            let search = Coverage.search(["policy-holder":patient.id?.description])
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    // there was an error
                }
                else {
                    let coverages = bundle?.entry?
                        .filter() { return $0.resource is Coverage }
                        .map() { return $0.resource as! Coverage }
                        
                    self.coverageObject = coverages?.first
                    completion(self.coverageObject!, weight!, height!)
                }
            }
        }
    }
    
    func countImages(completion: @escaping ((ObservationType, Int) -> Void)){
        print("countImages")
        let date = self.sereviceRequestObject?.authoredOn?.description
        
        for type in ObservationType.allCases {
            switch type {
            case .Anamnesis:
                countImagesCustom(filterDate: date!,obsType: .Anamnesis, type: "Anamnese", completion: completion)
            case .MedicalLetter:
                countImagesCustom(filterDate: date!,obsType: .MedicalLetter, type: "Arztbriefe", completion: completion)
            case .Haemodynamics:
                countImagesCustom(filterDate: date!,obsType: .Haemodynamics, type: "Haemodynamik", completion: completion)
            case .Respiration:
                countImagesCustom(filterDate: date!,obsType: .Respiration, type: "Beatmung", completion: completion)
            case .BloodGasAnalysis:
                countImagesCustom(filterDate: date!,obsType: .BloodGasAnalysis, type: "Blutgasanalyse", completion: completion)
            case .Perfusors:
                countImagesCustom(filterDate: date!,obsType: .Perfusors, type: "Perfusoren", completion: completion)
            case .InfectiousDisease:
                countImagesCustom(filterDate: date!,obsType: .InfectiousDisease, type: "Infektiologie", completion: completion)
            case .Radeology:
                countImagesCustom(filterDate: date!,obsType: .Radeology, type: "Radiologie", completion: completion)
            case .Lab:
                countImagesCustom(filterDate: date!,obsType: .Lab, type: "Labor", completion: completion)
            case .Others:
                countImagesCustom(filterDate: date!,obsType: .Others, type: "Sonstige", completion: completion)
            case .NONE:
                print("case NONE")
                //countImagesCustom(obsType: .NONE, type: "NONE", completion: completion)
            
            
            }
            
        }
        
    }
    
    func countImagesCustom(filterDate: String, obsType: ObservationType, type: String, completion: @escaping ((ObservationType, Int) -> Void)){
        //print("countImagesCustom")
        DispatchQueue.global(qos: .background).async {
            var request = self.client!.server.handlerForRequest(withMethod: .GET, resource: nil)
            request?.options = [.lenient]
            if let request = request {
                var headers = FHIRRequestHeaders()
                headers.customHeaders = ["Cache-Control":"no-cache"]
                request.add(headers: headers)
                let expression1 = "Media?modality:text=" + type
                let expression2 = "&_summary=count&created=le" + filterDate
                let expression3 = "&based-on:ServiceRequest.status=active"
                let expression4 = "&based-on:ServiceRequest.subject:Patient._id=" + self.patientObject!.id!.description
                self.client!.server.performRequest(against: expression1 + expression2 + expression3 + expression4, handler: request) { (response) in

                    do {
                        let bundle = try response.responseResource(ofType: Bundle.self)
                        //print("Antwort: \(bundle.total ?? "Fehler!")")
                        if(self.sereviceRequestObject?.status == RequestStatus(rawValue: "draft")){
                            self.countImagesCustomDraftServiceRequest(count: Int(String(bundle.total!.description))!, obsType: obsType, type: type, completion: completion)
                        }else{
                           completion(obsType, Int(String(bundle.total!.description))! )
                        }
                        
                        
                        
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
    }
    
    func countImagesCustomDraftServiceRequest(count: Int, obsType: ObservationType, type: String, completion: @escaping ((ObservationType, Int) -> Void)){
        //print("countImagesCustom")
        DispatchQueue.global(qos: .background).async {
            var request = self.client!.server.handlerForRequest(withMethod: .GET, resource: nil)
            request?.options = [.lenient]
            if let request = request {
                var headers = FHIRRequestHeaders()
                headers.customHeaders = ["Cache-Control":"no-cache"]
                request.add(headers: headers)
                let expression1 = "Media?modality:text=" + type
                let expression2 = "&based-on:ServiceRequest._id=" + self.sereviceRequestObject!.id!.description
                self.client!.server.performRequest(against: expression1 + expression2 , handler: request) { (response) in
                    do {
                        let bundle = try response.responseResource(ofType: Bundle.self)
                        
                        let newcount = Int(String(bundle.total!.description))!
                        completion(obsType, count+newcount)
                        
                        
                        
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
    }
    
    func saveDiagnosticReport(text: String, completion: @escaping ()->Void){
        self.createDiagnosticReport(reportText: text, completion: { report in
            self.updateDiagnosticReport(report: report, completion:{
                self.setServiceRequestActive(completion:{
                    completion()
                })
            })
            
        })
    }
    
    
    func createDiagnosticReport(reportText: String, completion: @escaping (DiagnosticReport) -> Void){
        print("createDiagnosticReport")
        DispatchQueue.global(qos: .background).async {
            var report = DiagnosticReport()
            report.status = DiagnosticReportStatus(rawValue: "final")
            report.conclusion = FHIRString(reportText)
            report.code = CodeableConcept()
            report.code?.coding = [Coding()]
            var coding = Coding()
            coding.system = FHIRURL("http://loinc.org")
            coding.code = FHIRString("12345")
            coding.display = FHIRString("Diagnostic Report")
            report.code?.coding?.append(coding)
            print("DateTimeNOWW:")
            print(DateTime.now.description)
            report.issued = Instant(string: DateTime.now.description)
            report.basedOn = [Reference()]
            do {
                var ref = try report.reference(resource: self.sereviceRequestObject!)
                report.basedOn?.append(ref)
            } catch {
                print(error)
            }
            
            if let client = Institute.shared.client {
                report.createAndReturn(client.server) { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("DiagnosticReportCreationSucceded")
                        completion(report)
                    }
                }
                
                // check error
            }
        }
    }
    
    func updateDiagnosticReport(report: DiagnosticReport, completion: @escaping ()->Void){
        DispatchQueue.global(qos: .background).async {
            report.update() { error in
                if let error = error as? FHIRError {
                    print(error)
                } else {
                    print("ReportUpdateSucceded")
                    completion()
                }
            }
        }
    }
    
    func setServiceRequestActive(completion: @escaping ()->Void){
        if(self.sereviceRequestObject != nil){
            self.sereviceRequestObject?.authoredOn = DateTime.now
            self.sereviceRequestObject?.status = RequestStatus(rawValue: "active")
            DispatchQueue.global(qos: .background).async {
                self.sereviceRequestObject!.update() { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("ServicerequestUpdateSucceded")
                        completion()
                    }
                    
                }
                
            }
        }
    }
    
    func getAllDiagnosticReportsForPatient(patient: Patient, completion: @escaping (([DiagnosticReport]?) -> Void)) {
        print("--- getAllDiagnosticReportsForPatient")
        
        let search = DiagnosticReport.search(["based-on": ["$type": "ServiceRequest", "subject":["$type": "Patient", "_id":patient.id?.description]], "_sort": "-issued"])
        print(search.construct())
        
        search.perform(self.client!.server) { bundle, error in
            if nil != error {
                // there was an error
            }
            else {
                let reports = bundle?.entry?
                    .filter() { return $0.resource is DiagnosticReport }
                    .map() { return $0.resource as! DiagnosticReport }
                
                print("We found some Reports:")
                print(reports?.count)
                completion(reports)
                
            }
        }
        
    }
    
    func getAllServiceRequestsForPatient(patient: Patient, completion: @escaping (([ServiceRequest]?) -> Void)) {
        print("--- getAllServiceRequestsForPatient")
        
        //ServiceRequest?subject:Patient._id=122&_sort=-authored&status=active
        let search = ServiceRequest.search(["subject":["$type": "Patient", "_id":patient.id?.description], "_sort": "-authored", "status": "active"])
        print(search.construct())
        
        search.perform(self.client!.server) { bundle, error in
            if nil != error {
                // there was an error
            }
            else {
                let sRequests = bundle?.entry?
                    .filter() { return $0.resource is ServiceRequest }
                    .map() { return $0.resource as! ServiceRequest }
                
                print("We found some ServiceRequests:")
                print(sRequests?.count)
                completion(sRequests)
                if sRequests != nil {
                    if(!sRequests!.isEmpty){
                        //completion(sRequests!)
                        /*
                        for observation in sRequests! {
                            print(observation.id)
                            //self.searchObservationTypeInServiceRequestWithID(id: sRequest.id!.string, type: type, completion: completion)
                        }
                        */

                    }
                }
            }
        }
        
    }
    
    func getAllServiceRequestsForPatientCustom(patient: Patient, completion: @escaping (([ServiceRequest]?) -> Void)) {
        print("--- getAllServiceRequestsForPatient")
        
        DispatchQueue.global(qos: .background).async {
            var request = self.client!.server.handlerForRequest(withMethod: .GET, resource: nil)
            request?.options = [.lenient]
            if let request = request {
                var headers = FHIRRequestHeaders()
                headers.customHeaders = ["Cache-Control":"no-cache"]
                request.add(headers: headers)
                //ServiceRequest?subject:Patient._id=122&_sort=-authored&status=active
                let expression1 = "ServiceRequest?subject:Patient._id=" + patient.id!.description
                let expression2 = "&_sort=-authored&status=active"
                self.client!.server.performRequest(against: expression1 + expression2, handler: request) { (response) in
                    
                    do {
                        let bundle = try response.responseResource(ofType: Bundle.self)
                        if bundle != nil{
                            let sRequests = bundle.entry?
                                .filter() { return $0.resource is ServiceRequest }
                                .map() { return $0.resource as! ServiceRequest }
                            
                            print("We found some ServiceRequests:")
                            print(sRequests?.count)
                            completion(sRequests)
                        }
                    }catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func getAllDiagnosticReportsForPatientCustom(patient: Patient, completion: @escaping (([DiagnosticReport]?) -> Void)) {
        print("getDiagnosticReportsForPatientCustom")
        
        DispatchQueue.global(qos: .background).async {
            var request = self.client!.server.handlerForRequest(withMethod: .GET, resource: nil)
            request?.options = [.lenient]
            if let request = request {
                var headers = FHIRRequestHeaders()
                headers.customHeaders = ["Cache-Control":"no-cache"]
                request.add(headers: headers)
                //DiagnosticReport?_sort=-issued&based-on:ServiceRequest.subject:Patient._id=554
                let expression1 = "DiagnosticReport?based-on:ServiceRequest.subject:Patient._id=" + patient.id!.description
                let expression2 = "&_sort=-issued"
                self.client!.server.performRequest(against: expression1 + expression2, handler: request) { (response) in
                    
                    do {
                        let bundle = try response.responseResource(ofType: Bundle.self)
                        if bundle != nil{
                            let report = bundle.entry?
                                .filter() { return $0.resource is DiagnosticReport }
                                .map() { return $0.resource as! DiagnosticReport }
                            
                            print("We found some Reports:")
                            print(report?.count)
                            completion(report)
                        }
                    }catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func getHistoryForPatient(patient: Patient, completion: @escaping (([DomainResource]?) -> Void)) {
    print("getHistoryForPatient")
        //Create Array for the communication history
        var patientHistory = [DomainResource]()
        //Put every Service Request in the history
        self.getAllServiceRequestsForPatientCustom(patient: patient, completion: { (requests) in
            if(requests != nil){
                for request in requests!{
                patientHistory.append(request)
                }
            
            }
            //Get all DiagnosticReports
            self.getAllDiagnosticReportsForPatientCustom(patient: patient, completion: { (reports) in
                if (reports != nil){
                    for rep in reports!{
                        //Get the String of the Service request, that its based on
                        var stringReference = rep.basedOn![0].reference?.string
                        if let range = stringReference!.range(of: "/") {
                            let newID = stringReference![range.upperBound...]
                            //Replace every ServiceRequest, that a DiagnosticReport is based on with the DiagnosticReport
                            patientHistory = patientHistory.map({
                                if let sr = $0 as? ServiceRequest{
                                    if (newID != "" && newID == String(sr.id!.description)) {
                                        return rep
                                    }
                                }
                            return $0 })
                        }
                    }
                }
                //Insert the current ServiceRequest(draft) to fitst place in history
                if(self.serviceRequestDraftObject != nil){
                    patientHistory.insert(self.serviceRequestDraftObject!, at:0)
                }
                completion(patientHistory)
            })
        })
        
    }
    
    
    func sendServiceRequest(){
        print("sendServiceRequest")
        if(self.sereviceRequestObject != nil){
            self.sereviceRequestObject?.authoredOn = DateTime.now
            self.sereviceRequestObject?.status = RequestStatus(rawValue: "active")
            DispatchQueue.global(qos: .background).async {
                self.sereviceRequestObject!.update() { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("ServicerequestUpdateSucceded")
                        
                    }
                    
                }
                
            }
        }
    }
    
    func clearData(){
        print("clearData")
        self.sereviceRequestObject = nil
        self.serviceRequestDraftObject = nil
        self.patientObject = nil
        self.observationWeight = nil
        self.observationHeight = nil
        self.coverageObject = nil
    }
    
    func deleteAllDataForServiceRequest(){
        if(self.sereviceRequestObject != nil){
            deleteAllImageMediaForServicerequest(serviceRequest: self.sereviceRequestObject!)
            deleteServiceRequestWithID(serviceRequest: self.sereviceRequestObject!)
            clearData()
        }
        
    }
    /**
     Usually a collection view needs an array of Elements, that represent all the items that should be displayed in the collection
     So instead of having a separate array in the GalleryVC we return a subset of the cache, that holds all the items to be displayed
     */
    func getOrderedImageSubset(category: String) -> [String]{
        //create a subset of the dictionary, that only containes images of the category
        let filteredByCategory = images.filter { $0.value.modality?.text?.description == category }
        //create a subset of the dictionary, that only containes images that are taken bevor the currently selected Servicerequest
        var filteredForDate = filteredByCategory.filter{ $0.value.createdDateTime?.nsDate.compare((Institute.shared.sereviceRequestObject?.authoredOn!.nsDate)!) == ComparisonResult.orderedAscending}
        //If we are in the draft section add all the Images to the subset, that are created after the draft serviceRequest was created
        if(self.sereviceRequestObject?.status == RequestStatus(rawValue: "draft")){
            let filteredForDraftPictures = filteredByCategory.filter{ $0.value.createdDateTime?.nsDate.compare((Institute.shared.sereviceRequestObject?.authoredOn!.nsDate)!) == ComparisonResult.orderedDescending
            }
            let merge = filteredForDraftPictures.merging(filteredForDate, uniquingKeysWith: { (first, _) in first })
            filteredForDate = merge
        }
        /**
         Workaround for the bug: we use our own extention to get the correct formatted date for the comparison
         */
        let sortedDict = filteredForDate.sorted{$0.value.createdDateTime!.fixedNSDate(date: $0.value.createdDateTime!.description) > $1.value.createdDateTime!.fixedNSDate(date: $1.value.createdDateTime!.description)}
        let keys = sortedDict.flatMap(){ $0.0 as? String }
        return Array(keys)
        
    }
    

    func openMedicalDataFromNotification(notification: [AnyHashable : Any], completion: @escaping (() -> Void)) {
        print("openMedicalDataFromNotification")
        print(notification)
        print("_____")
        if let sound = notification["sound"] as? String{
            print("sound")
            print(sound)
            if let patientID = notification["patientID"] as? Int{
                print("patientID")
                print(patientID)
                if let serviceRequestID = notification["serviceRequestID"] as? Int{
                    print("serviceRequestID")
                    print(serviceRequestID)
                    self.getServiceRequestByID(id: String(serviceRequestID), completion: { (request) in
                        self.getPatientByID(id: String(patientID), completion: { (patient) in
                            self.patientObject = patient
                            //login
                            Institute.shared.connect { error in
                                if error == nil {
                                    //get my Organization Profile
                                    self.checkOrganizationsForLogin(completion: { login in
                                        if(login != .NONE){
                                            UserLoginCredentials.shared.selectedProfile = login
                                            print("Login data complete")
                                            //createDraftServiceRequest
                                            Institute.shared.createServiceRequest(category: "Intensivmedizin", completion: {
                                                self.sereviceRequestObject = request
                                                completion()
                                            })
                                        }
                                    })
                                }
                            }
                            
                        })
                    })
                }else{
                    print("no serviceRequest")
                }
            }else{
                print("no patient")
            }
        }else{
            print("no Sound")
        }
    }
    
    func createPatientListData(list: PatientList, completion: @escaping ((Dictionary<String,[DomainResource]>)) -> Void){
        var historyData: Dictionary<String,[DomainResource]> = [:]
        for patient in list.patients!{
            getHistoryForPatient(patient: patient, completion: { history in
                historyData[patient.id!.description] = history
            })
            
        }
        
    }
    
    func registerProfile(profileType: ProfileType, completion: @escaping (() -> Void)) {
        var clinicType = ""
        var performerClinicType = ""
        if(profileType == .ConsultationClinic){
            clinicType = "consultationClinic"
            performerClinicType = "peripheralClinic"
        }else {
            clinicType = "peripheralClinic"
            performerClinicType = "consultationClinic"
        }
        getOrganizationForProfile(profileType: clinicType, completion: { organization in
            UserLoginCredentials.shared.organizationProfile = organization
            self.getEndpointForProfile(organization: organization, completion: completion)
            self.getOrganizationForProfile(profileType: performerClinicType, completion: { organization in
                UserLoginCredentials.shared.performerOrganizationProfile = organization
                
            })
            
        })
    }
    
    func checkOrganizationsForLogin(completion: @escaping ((ProfileType) -> Void)){
        //We first check if our device is registered in a peripheral Clinic
        getOrganizationForProfile(profileType: "peripheralClinic", completion: { organization in
            self.searchEndpointForProfileCustom(organization: organization, completion: { endpoint in
                //When we find our Endpoint in the peripheral Clinic we wrap up the login
                if endpoint != nil{
                    print("We are registered in a peripheralClinic")
                    UserLoginCredentials.shared.organizationProfile = organization
                    self.getOrganizationForProfile(profileType: "consultationClinic", completion: { organization in
                        UserLoginCredentials.shared.performerOrganizationProfile = organization
                        completion(.PeripheralClinic)
                        
                    })
                }else{
                    //Wen we failed first, we try to check if we are registered in a consultationClinic
                    self.getOrganizationForProfile(profileType: "consultationClinic", completion: { organization in
                        self.searchEndpointForProfileCustom(organization: organization, completion: { endpoint in
                            //When we find our Endpoint in the peripheral Clinic we wrap up the login
                            if endpoint != nil{
                                print("We are registered in a consultationClinic")
                                UserLoginCredentials.shared.organizationProfile = organization
                                self.getOrganizationForProfile(profileType: "peripheralClinic", completion: { organization in
                                    UserLoginCredentials.shared.performerOrganizationProfile = organization
                                    completion(.ConsultationClinic)
                                })
                            }else{
                                print("We have a token but are not logged in")
                                completion(.NONE)
                            }
                        })
                    })
                }
            })
        })
        
    }
    
    func getOrganizationForProfile(profileType: String, completion: @escaping ((Organization) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            
            //Get the Organizaition Profile for the Login
            let search = Organization.search(["type": ["$text": profileType]])
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    // there was an error
                }else {
                    let organization = bundle?.entry?
                        .filter() { return $0.resource is Organization }
                        .map() { return $0.resource as! Organization }
                    
                    //Save the Organization profile in the UserCredentials
                    completion((organization?.first)!)
                }
            }
        }
    }
    
    func getEndpointForProfile(organization: Organization, completion: @escaping (() -> Void)) {
        
        DispatchQueue.global(qos: .background).async {
            //Get the Endpoint for the Login
            var stringReference = organization.endpoint![0].reference?.string
            if let range = stringReference!.range(of: "/") {
                let newID = stringReference![range.upperBound...]
                DispatchQueue.global(qos: .background).async {
                    
                    Endpoint.read(String(newID), server: self.client!.server){ resource, error in
                        if let error = error as? FHIRError {
                            print(error)
                        } else if resource != nil {
                            var ep = resource as! Endpoint
                            
                            //Check if the current pushDeviceToken is already registered
                            if let currentToken = UserDefaults.standard.string(forKey: "current_device_token") {
                                let results = ep.contact?.filter { $0.value == FHIRString(currentToken) }
                                if(results!.isEmpty){
                                    //Our pushDeviceToken is not present and we have to add it to the Endpoint
                                    self.addContactPointToEndpoint(endpoint: ep, completion: completion)
                                } else{
                                    UserLoginCredentials.shared.endpointProfile = ep
                                    completion()
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func searchEndpointForProfile(organization: Organization, completion: @escaping ((Endpoint?) -> Void)) {
        
        DispatchQueue.global(qos: .background).async {
            //Get the Endpoint for the Login
            var stringReference = organization.endpoint![0].reference?.string
            if let range = stringReference!.range(of: "/") {
                let newID = stringReference![range.upperBound...]
                DispatchQueue.global(qos: .background).async {
                    
                    print("read: " + String(newID))
                    Endpoint.read(String(newID), server: self.client!.server){ resource, error in
                        if let error = error as? FHIRError {
                            print(error)
                        } else if resource != nil {
                            var ep = resource as! Endpoint
                            print("Endpoint")
                            print(ep)
                            
                            //Check if the current pushDeviceToken is already registered
                            if let currentToken = UserDefaults.standard.string(forKey: "current_device_token") {
                                print("---")
                                print(UserDefaults.standard.string(forKey: "current_device_token"))
                                print(ep.contact)
                                let results = ep.contact?.filter { $0.value == FHIRString(currentToken) }
                                print("---filter")
                                print(results)
                                if(results!.isEmpty){
                                    completion(nil)
                                } else{
                                    UserLoginCredentials.shared.endpointProfile = ep
                                    completion(ep)
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    /**
     A lenient call to get the Endpoints
     Because the normal read call still gets resources from the cache first, we ned a direct acess to the data
     */
    func searchEndpointForProfileCustom(organization: Organization, completion: @escaping ((Endpoint?) -> Void)) {
        //Get the Endpoint for the Login
        var stringReference = organization.endpoint![0].reference?.string
        if let range = stringReference!.range(of: "/") {
            let newID = stringReference![range.upperBound...]
            DispatchQueue.global(qos: .background).async {
                
                var request = self.client!.server.handlerForRequest(withMethod: .GET, resource: nil)
                request?.options = [.lenient]
                if let request = request {
                    var headers = FHIRRequestHeaders()
                    headers.customHeaders = ["Cache-Control":"no-cache"]
                    request.add(headers: headers)
                    let expression1 = "Endpoint?_id=" + newID
                    self.client!.server.performRequest(against: expression1 , handler: request) { (response) in

                        do {
                            let bundle = try response.responseResource(ofType: Bundle.self)
                            
                            let endpoints = bundle.entry?
                                .filter() { return $0.resource is Endpoint }
                                .map() { return $0.resource as! Endpoint }
                            
                            if let endpoint = endpoints?.first{
                                //Check if the current pushDeviceToken is already registered
                                if let currentToken = UserDefaults.standard.string(forKey: "current_device_token") {
                                    let results = endpoint.contact?.filter { $0.value == FHIRString(currentToken) }
                                    if(results!.isEmpty){
                                        completion(nil)
                                    } else{
                                        UserLoginCredentials.shared.endpointProfile = endpoint
                                        completion(endpoint)
                                    }
                                }
                            }
                        }
                        catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
                
            }
        }
        
        
            
            
            
            
        
        
        /*
        DispatchQueue.global(qos: .background).async {
            //Get the Endpoint for the Login
            var stringReference = organization.endpoint![0].reference?.string
            if let range = stringReference!.range(of: "/") {
                let newID = stringReference![range.upperBound...]
                DispatchQueue.global(qos: .background).async {
                    
                    print("read: " + String(newID))
                    Endpoint.read(String(newID), server: self.client!.server){ resource, error in
                        if let error = error as? FHIRError {
                            print(error)
                        } else if resource != nil {
                            var ep = resource as! Endpoint
                            print("Endpoint")
                            print(ep)
                            
                            //Check if the current pushDeviceToken is already registered
                            if let currentToken = UserDefaults.standard.string(forKey: "current_device_token") {
                                print("---")
                                print(UserDefaults.standard.string(forKey: "current_device_token"))
                                print(ep.contact)
                                let results = ep.contact?.filter { $0.value == FHIRString(currentToken) }
                                print("---filter")
                                print(results)
                                if(results!.isEmpty){
                                    completion(nil)
                                } else{
                                    UserLoginCredentials.shared.endpointProfile = ep
                                    completion(ep)
                                }
                            }
                        }
                    }
                }
            }
        }
        */
        
    }
    
    func addContactPointToEndpoint(endpoint: Endpoint, completion: @escaping (()->Void)){
        
        var cp = ContactPoint()
        cp.system = ContactPointSystem(rawValue: "other")
        cp.use = ContactPointUse(rawValue: "work")
        cp.value = FHIRString(UserDefaults.standard.string(forKey: "current_device_token")!)
        
        endpoint.contact?.append(cp)
        
        DispatchQueue.global(qos: .background).async {
            endpoint.update() { error in
                if let error = error as? FHIRError {
                    print(error)
                } else {
                    print("EndpointUpdateSucceded")
                    
                    //Save the Endpoint in the UserLoginCredentials
                    UserLoginCredentials.shared.endpointProfile = endpoint
                    completion()
                }
            }
        }
    }
    
    func removeContactPointFromEndpoint(completion: @escaping (()->Void)){
        print("removeContactPointFromEndpoint")
        
        var endpoint = UserLoginCredentials.shared.endpointProfile
        //We remove our pushDeviceToken from the endpoint
        let filteredContaktPoints = endpoint?.contact!.filter {$0.value != FHIRString(UserDefaults.standard.string(forKey: "current_device_token")!)}
        //We save the deminished list to the endpoint again
        endpoint?.contact = filteredContaktPoints
        /**
         We sometimes encounter an error, where the server instance is not set and the logout process gets in interupred
         If this error occurs, we manually set the server instance
         */
        if(endpoint?._server == nil){
            print("no server, manually adding")
            endpoint?._server = self.client?.server
        }
        
        DispatchQueue.global(qos: .background).async {
            endpoint!.update() { error in
                if let error = error as? FHIRError {
                    print("error")
                    print(error)
                } else {
                    print("EndpointUpdateSucceded")
                    
                    //Save the Endpoint in the UserLoginCredentials
                    UserLoginCredentials.shared.endpointProfile = nil
                    UserLoginCredentials.shared.organizationProfile = nil
                    UserLoginCredentials.shared.selectedProfile = .NONE
                    completion()
                }
            }
        }
    }
    
    func createProfileOrganization(profile: String, token: String){
        createEndpoint(token: token, completion:{ endpoint in
            self.createOrganziation(profile: profile, endpoint: endpoint, completion: { organization, endpoint in
                self.updateOrganizationAndEndpoint(org: organization, ep: endpoint)
            })
        })
    }
    
    func createEndpoint(token: String, completion: @escaping (Endpoint)->Void){
        DispatchQueue.global(qos: .background).async {
            
            var endpoint = Endpoint()
            endpoint.status = EndpointStatus(rawValue: "active")
            endpoint.contact = [ContactPoint()]
            
            var cp = ContactPoint()
            cp.system = ContactPointSystem(rawValue: "other")
            cp.use = ContactPointUse(rawValue: "work")
            cp.value = FHIRString(token)

            endpoint.contact?.append(cp)
            endpoint.connectionType = Coding()
            
            var coding = Coding()
            coding.system = FHIRURL("https://developer.apple.com/notifications/")
            
            endpoint.connectionType = coding
            
            endpoint.payloadType = [CodeableConcept()]
            
            var cc = CodeableConcept()
            cc.text = FHIRString("PushNotification")
            endpoint.payloadType?.append(cc)
            endpoint.address = FHIRURL("testAdress")
            
            if let client = Institute.shared.client {
                endpoint.createAndReturn(client.server) { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("EndpointCreationSucceded")
                        completion(endpoint)
                    }
                }
            }
        }
    }
    
    func createOrganziation(profile: String, endpoint: Endpoint, completion:@escaping (Organization, Endpoint)->Void){
        
        DispatchQueue.global(qos: .background).async {
            var org = Organization()
            org.active = true
            org.type = [CodeableConcept()]
            
            var cc = CodeableConcept()
            cc.text = FHIRString(profile)
            
            org.type?.append(cc)
            org.endpoint = [Reference()]
            
            var ref = Reference()
            print(self.patientObject?._server?.baseURL)
            do {
                try ref = org.reference(resource: endpoint)
            } catch {
                print(error)
            }
            org.endpoint?.append(ref)
            
            if let client = Institute.shared.client {
                org.createAndReturn(client.server) { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("profileOrganizationCreationSucceded")
                        //self.updateOrganizationAndEndpoint(org: org, ep: endpoint)
                        completion(org, endpoint)
                    }
                }
            }
        }
        
        
        
    }
    func updateOrganizationAndEndpoint(org: Organization, ep: Endpoint){
        DispatchQueue.global(qos: .background).async {
            org.update() { error in
                if let error = error as? FHIRError {
                    print(error)
                } else {
                    print("OrganizationUpdateSucceded")
                }
            }
            
            ep.update() { error in
                if let error = error as? FHIRError {
                    print(error)
                } else {
                    print("EndpointUpdateSucceded")
                }
            }
        }
    }
    
}

/**
 Makes the GalleryView reload after a new Image was returned from the server
 */
extension Institute: GalleryImageReloadDelegate {
    func reloadImage(newImageName: String) {
        if let gallery = galleryVC {
            print("reload gallery")
            gallery.reloadGalleryImages(newImage: newImageName)
        }else{
            print("gallery is nill")
        }
    }
    
}
