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
    
    var serviceRequestID = ""
    var sereviceRequestObject: ServiceRequest? = nil
    var patientObject: Patient? = nil
    var observationWeight: Observation? = nil
    var observationHeight: Observation? = nil
    
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
    
    
    func createPatient(firstName: String, familyName: String, gender: String, birthday: String, weight: String, height: String,clinicName: String,  doctorName: String, contactNumber: String, completion:@escaping (() -> Void)) {
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
                        self.createWeightVitalSigns(weight: weight)
                        self.createHeightVitalSigns(height: height)
                        completion()
                    }
                }
                
            }
        }
        
    }
    
    func updateExistingPatient(firstName: String, familyName: String, gender: String, birthday: String, weight: String, height: String,clinicName: String,  doctorName: String, contactNumber: String, completion:@escaping (() -> Void)) {
        print("createPatient")
        
        
            
            self.patientObject!.gender = AdministrativeGender(rawValue: gender)
            
            var patientName = HumanName()
            patientName.family = FHIRString(familyName)
            patientName.given = [FHIRString(firstName)]
            
            self.patientObject!.name = [HumanName()]
            self.patientObject!.name?.append(patientName)
            self.patientObject!.birthDate = FHIRDate(string: birthday)
            
            self.patientObject!.contact = [PatientContact()]
            
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
            
            self.patientObject!.contact?.append(pc)
            
            DispatchQueue.global(qos: .background).async {
                self.patientObject!.update() { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("PatientResourceUpdateSucceded")
                        self.updateWeightVitalSigns(weight: weight)
                        self.updateHeightVitalSigns(height: height)
                        completion()
                    }
                }
                
            }
        
    }
    
    
    func createWeightVitalSigns(weight: String) {
        
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
    
    
    
    func createHeightVitalSigns(height: String) {
        
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
    
    
    func createServiceRequest(status: String, intent: String, category: String, priority: String, patientID: String, organizationID: String, completion:@escaping (() -> Void)){
        
        DispatchQueue.global(qos: .background).async {
            
            var serv = ServiceRequest()
            serv._server = self.client?.server
            serv.status = RequestStatus(rawValue: status)
            serv.intent = RequestIntent(rawValue: intent)
            serv.category = [CodeableConcept()]
            
            var cc = CodeableConcept()
            cc.text = FHIRString(category)
            
            serv.category?.append(cc)
            serv.priority = RequestPriority(rawValue: priority)
            serv.subject = Reference()
            
            print(self.patientObject?._server?.baseURL)
            do {
                try serv.subject = serv.reference(resource: self.patientObject!)
            } catch {
                print(error)
            }
            serv.authoredOn = DateTime.now
            serv.requester = Reference()
            serv.reasonReference = [Reference()]
            
            if let client = Institute.shared.client {
                serv.createAndReturn(client.server) { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("ServiceRequestCreationSucceded")
                        self.sereviceRequestObject = serv
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
        
            DispatchQueue.global(qos: .background).async {
            
                let search = Media.search(["based-on": ["$type": "ServiceRequest", "subject":["$type": "Patient", "_id":self.patientObject?.id?.description]], "modality":["$text": type]])

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
                        self.safeImageInDirectory(imageData: decodedData, name:String(id))
                        if(testMedia.status!.rawValue == "completed"){
                            completion!(id, true)
                        }else {
                            completion!(id, false)
                        }
                        
                    }
                }
                
            }
            
        }
    
    
    
    
    
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
    
    func saveImage(imageData: Data,observationType: ObservationType){
        
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
            self.updateImage(media: media)
        })
        
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
            

            if let client = Institute.shared.client {
                med.createAndReturn(client.server) { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("MediaCreationSucceded")
                        print(med.id)
                        
                        completion(med)
                        
                        
                    }
                }
                
                // check error
            }
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
                
                self.sereviceRequestObject!.update() { error in
                    if let error = error as? FHIRError {
                        print(error)
                    } else {
                        print("ServicerequestUpdateSucceded")
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
                    print("createImage")
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
                let imageData = med.content?.data
                let decodedData = Data(base64Encoded: imageData!.value)!
                self.safeImageInDirectory(imageData: decodedData, name:String(med.id!.description))
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
                    self.safeImageInDirectory(imageData: decodedData, name:String(med.id!.description))
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
     
    
    func recursiveMediaCall(allMedia:[String],completion: ((String) -> Void)? = nil){
        print("recursiveMediaCall")
        if (allMedia.count == 1) {
            print("Letzte Datei:: Datei:")
            //print(allMedia.last!.id!.string)
            
            let obsRef = allMedia.last!
            print("Check MEDIA ID")
            print(obsRef)
            
            Media.read(String(obsRef), server: self.client!.server){ resource, error in
                if let error = error as? FHIRError {
                    print(error)
                    completion!(obsRef)
                } else if resource != nil {
                    var testMedia:Media = resource as! Media
                    let imageData = testMedia.content?.data
                    let decodedData = Data(base64Encoded: imageData!.value)!
                    self.safeImageInDirectory(imageData: decodedData, name:String(obsRef))
                    completion!(obsRef)
                }
            }
            
            
        }else{
            
            print("verbleibende Dateien:")
            print(allMedia.count)
            //print("Ich speichere die Datei:")
            //print(allMedia.last!.id!.string)
            
            let obsRef = allMedia.last!
            print("Check MEDIA ID")
            print(obsRef)
            
            Media.read(String(obsRef), server: self.client!.server){ resource, error in
                if let error = error as? FHIRError {
                    print(error)
                } else if resource != nil {
                    var testMedia:Media = resource as! Media
                    let imageData = testMedia.content?.data
                    let decodedData = Data(base64Encoded: imageData!.value)!
                    self.safeImageInDirectory(imageData: decodedData, name:String(obsRef))
                    completion!(obsRef)
                }
            }
            
            var newMedia = allMedia
            newMedia.removeLast()
            self.recursiveMediaCall(allMedia: newMedia, completion: completion)
            
        }
        
    }
    
    
    func safeImageInDirectory(imageData: Data, name: String){
        //create an instance of the FileManager
        let fileManager = FileManager.default
        var imageName = "\(name).jpg"
        //get the image path
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        //store it in the document directory
        fileManager.createFile(atPath: imagePath as String, contents: imageData, attributes: nil)
        print("Saved Photo with name:")
        print(name)
        //delegate?.addGalleryImage(imageName: "\(photoName).jpg")
        photoName = photoName+1
    }
    
    func deleteAllImageMedia(){
        let search = Media.search([])
        
        search.perform(client!.server) { bundle, error in
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
        let search = ServiceRequest.search([])
        
        search.perform(client!.server) { bundle, error in
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
        let search = DiagnosticReport.search([])
        
        search.perform(client!.server) { bundle, error in
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
                    completion(patient)
                    
                }
            }
        }
    }
    
    
    func countImages(completion: @escaping ((ObservationType, Int) -> Void)){
        print("countImages")
        
        for type in ObservationType.allCases {
            switch type {
            case .Anamnesis:
                countImagesCustom(obsType: .Anamnesis, type: "Anamnese", completion: completion)
            case .MedicalLetter:
                countImagesCustom(obsType: .MedicalLetter, type: "Arztbriefe", completion: completion)
            case .Haemodynamics:
                countImagesCustom(obsType: .Haemodynamics, type: "Haemodynamik", completion: completion)
            case .Respiration:
                countImagesCustom(obsType: .Respiration, type: "Beatmung", completion: completion)
            case .BloodGasAnalysis:
                countImagesCustom(obsType: .BloodGasAnalysis, type: "Blutgasanalyse", completion: completion)
            case .Perfusors:
                countImagesCustom(obsType: .Perfusors, type: "Perfusoren", completion: completion)
            case .InfectiousDisease:
                countImagesCustom(obsType: .InfectiousDisease, type: "Infektiologie", completion: completion)
            case .Radeology:
                countImagesCustom(obsType: .Radeology, type: "Radiologie", completion: completion)
            case .Lab:
                countImagesCustom(obsType: .Lab, type: "Labor", completion: completion)
            case .Others:
                countImagesCustom(obsType: .Others, type: "Sonstige", completion: completion)
            case .NONE:
                print("case NONE")
                //countImagesCustom(obsType: .NONE, type: "NONE", completion: completion)
            
            
            }
            
        }
        
    }
    
    func countImagesCustom(obsType: ObservationType, type: String, completion: @escaping ((ObservationType, Int) -> Void)){
        
        DispatchQueue.global(qos: .background).async {
            var request = self.client!.server.handlerForRequest(withMethod: .GET, resource: nil)
            request?.options = [.lenient]
            if let request = request {
                var headers = FHIRRequestHeaders()
                headers.customHeaders = ["Cache-Control":"no-cache"]
                request.add(headers: headers)
                self.client!.server.performRequest(against: "Media?modality:text=" + type + "&_summary=count", handler: request) { (response) in
                    do {
                        let bundle = try response.responseResource(ofType: Bundle.self)
                        print("Antwort: \(bundle.total ?? "Fehler!")")
                        completion(obsType, Int(String(bundle.total!.description))! )
                        
                        
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
    }
    
    func saveDiagnosticReport(text: String){
        self.createDiagnosticReport(reportText: text, completion: { report in
            self.updateDiagnosticReport(report: report)
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
    
    func updateDiagnosticReport(report: DiagnosticReport){
        DispatchQueue.global(qos: .background).async {
            report.update() { error in
                if let error = error as? FHIRError {
                    print(error)
                } else {
                    print("ReportUpdateSucceded")
                }
            }
        }
    }
    
    func getAllDiagnosticReportsForPatient(completion: @escaping (([DiagnosticReport]) -> Void)) {
        print("getAllDiagnosticReportsForPatient")
        
        let search = DiagnosticReport.search(["based-on": ["$type": "ServiceRequest", "subject":["$type": "Patient", "_id":self.patientObject?.id?.description]], "_sort": "-issued"])
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
                
                if reports != nil {
                    if(!reports!.isEmpty){
                        completion(reports!)
                        for observation in reports! {
                            print(observation.id)
                            //self.searchObservationTypeInServiceRequestWithID(id: sRequest.id!.string, type: type, completion: completion)
                        }

                    }
                }
                
            }
        }
        
    }
    
    func sendServiceRequest(){
        print("sendServiceRequest")
        if(self.sereviceRequestObject != nil){
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
        self.sereviceRequestObject = nil
        self.patientObject = nil
        self.observationWeight = nil
        self.observationHeight = nil
    }
    
    func deleteAllDataForServiceRequest(){
        if(self.sereviceRequestObject != nil){
            deleteAllImageMediaForServicerequest(serviceRequest: self.sereviceRequestObject!)
            deleteServiceRequestWithID(serviceRequest: self.sereviceRequestObject!)
            clearData()
        }
        
    }
    
    
    
}
