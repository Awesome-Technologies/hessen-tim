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
    var observationObject: Observation? = nil
    var sereviceRequestObject: ServiceRequest? = nil
    
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
    
    
    func createPatientOnServer(firstName: String, familyName: String, gender: String, birthday: String){
        
        var replaced = ""
        if let filepath = Bundle.main.path(forResource: "createPatient", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                replaced = contents.replacingOccurrences(of: "replace_firstName", with: firstName)
                replaced = replaced.replacingOccurrences(of: "replace_familyName", with: familyName)
                replaced = replaced.replacingOccurrences(of: "replace_gender", with: gender)
                replaced = replaced.replacingOccurrences(of: "replace_birthday", with: birthday)
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        
        let fileName = "createPatient"
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask, appropriateFor: nil, create: true)
        
        // If the directory was found, we write a file to it and read it back
        if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("json") {
            
            // Write to the file named Test
            //let outString = "Write this text to the file"
            do {
                try replaced.write(to: fileURL, atomically: true, encoding: .utf8)
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
            print("Read from the file: \(inString)")
            
            //let url = Bundle.main.url(forResource:"Patient2", withExtension: "json")!
            let data = NSData(contentsOf: fileURL)!
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data as Data, options: []) as? FHIRJSON {
                    var newPatient = try Patient(json: json)
                    if let client = Institute.shared.client {
                        newPatient.create(client.server) { error in
                            if let error = error as? FHIRError {
                                print(error)
                            } else {
                                print("PatientCreationSucceded")
                            }
                        }
                        
                        // check error
                    }
                    
                    if let name = newPatient.name?[0] {
                        print(name.family?.string)
                        print(name.given?[0].string)
                        print(newPatient.gender)
                        print("---")
                        
                    }
                }
            } catch{
                print(error)
            }
        }
        
        
    }
    
    
    
    func createServiceRequest(status: String, intent: String, category: String, priority: String, authoredOn: String, patientID: String, organizationID: String){
        
        var replaced = ""
        if let filepath = Bundle.main.path(forResource: "createServiceRequest", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                replaced = contents.replacingOccurrences(of: "replace_status", with: status)
                replaced = replaced.replacingOccurrences(of: "replace_intent", with: intent)
                replaced = replaced.replacingOccurrences(of: "replace_category", with: category)
                replaced = replaced.replacingOccurrences(of: "replace_priority", with: priority)
                replaced = replaced.replacingOccurrences(of: "replace_authoredOn", with: authoredOn)
                replaced = replaced.replacingOccurrences(of: "replace_patientID", with: patientID)
                replaced = replaced.replacingOccurrences(of: "replace_organizationID", with: organizationID)
                replaced = replaced.replacingOccurrences(of: "replace_observationID", with: "")
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        
        let servRequestURL = writeNewFile(replacedText: replaced, filename: "createPatient")
        createResource(createdFile: servRequestURL, resourceType: "serviceRequest", reference: nil)
        
        //serviceRequestID = id
        print("ID of created ServiceRequest:")
        print(serviceRequestID)
        
        //return id
        
    }
    
    func createObservation(category: String, completion:@escaping (() -> Void)) {
        print("createObservation")
        
        DispatchQueue.global(qos: .background).async {
        
        
        var replaced = ""
        if let filepath = Bundle.main.path(forResource: "createObservation", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                replaced = contents.replacingOccurrences(of: "replace_category", with: category)
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        
            let observRequestURL = self.writeNewFile(replacedText: replaced, filename: "createObservation")
            let id = self.createResource(createdFile: observRequestURL, resourceType: "observation", reference: nil, completion: completion)
        
       }
    }
    
    func createAndReturnObservation(category: String) -> Observation{
        
        var replaced = ""
        if let filepath = Bundle.main.path(forResource: "createObservation", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                replaced = contents.replacingOccurrences(of: "replace_category", with: category)
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        
        let observRequestURL = writeNewFile(replacedText: replaced, filename: "createObservation")
        let observation = createObservationResource(createdFile: observRequestURL, resourceType: "observation")
        
        return observation
        
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
        
    }
    
    func addObservationToServiceRequest(){
        
        
        //print("I rty to update the servRequest")
        //print(observationObject!.id)
        //print(sereviceRequestObject!.id)
        
        do {
            try sereviceRequestObject!.reasonReference?.append(sereviceRequestObject!.reference(resource: observationObject!))
        } catch {
            print(error)
        }
        
        //print("Added the refference")
        //print(sereviceRequestObject!.reasonReference)
        
        sereviceRequestObject!.update() { error in
            if let error = error as? FHIRError {
                print(error)
            } else {
                print("ServiceRequestUpdateSucceded")
            }
        }
        
        
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
        
        
        
        if observationObject == nil {
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
            //erstelle neue Observation
            //hänge sie dem SeviceRequest als Refferenz an
            print("Wir haben als Observation nil und erstellen eine neue")
            createObservation(category: obsType, completion: {
                self.searchServiceRequestWithID(id: self.serviceRequestID, completion: {
                    self.addObservationToServiceRequest()
                })
                self.createImageMedia(imageData: imageData)
                
                
            })
            
        }else{
            print("haben die Observation")
            print(observationObject?.id)
            print("und arbeiten mit der")
            
            
            self.createImageMedia(imageData: imageData)
            
        }
        
        
        
    }
    
    func createImageMedia(imageData: Data){
        
        print("wir speichern ein Bild")
        
        print("createImageMedia")
        var replaced = ""
        let base64Encoded = imageData.base64EncodedString()
        //print("imageFIle")
        //print(base64Encoded)
        if let filepath = Bundle.main.path(forResource: "imageMedia", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                replaced = contents.replacingOccurrences(of: "replace_data", with: base64Encoded)
                replaced = replaced.replacingOccurrences(of: "replace_createdDateTime", with: "2020-02-23")
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        
        let imageMediaURL = writeNewFile(replacedText: replaced, filename: "imageMedia")
        createResource(createdFile: imageMediaURL, resourceType: "imageMedia", reference: observationObject)
        
        
        //Hänge die Media Ressource der Observation als Refferenz an

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
    
    private func createObservationResource(createdFile: URL, resourceType: String) -> Observation{
        
        let data = NSData(contentsOf: createdFile)!
        var ressource = Observation()
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data as Data, options: []) as? FHIRJSON {
                
                switch resourceType {
                case "observation":
                    var newObservation = try Observation(json: json)
                    if let client = Institute.shared.client {
                        newObservation.createAndReturn(client.server) { error in
                            if let error = error as? FHIRError {
                                print(error)
                            } else {
                                print("ObservationCreationSucceded")
                                ressource = newObservation
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
        
        return ressource
        
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
                case "observation":
                var newObservation = try Observation(json: json)
                if let client = Institute.shared.client {
                    newObservation.createAndReturn(client.server) { error in
                        if let error = error as? FHIRError {
                            print(error)
                        } else {
                            print("ObservationCreationSucceded")
                            self.observationObject = newObservation
                            print("I have created the Observation with the ID:")
                            print(newObservation.id)
                            completion?()
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
        //let search = ServiceRequest.search(["subject": "3"])
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
        
        let search = ServiceRequest.search(["_id": id])
        var sRequest = ServiceRequest()
        
        search.perform(self.client!.server) { bundle, error in
            if nil != error {
                // there was an error
            }
            else {
                let servReq = bundle?.entry?
                    .filter() { return $0.resource is ServiceRequest }
                    .map() { return $0.resource as! ServiceRequest }
                    
                
                if(!servReq!.isEmpty){
                    sRequest =  servReq!.first!
                    self.sereviceRequestObject = sRequest
                    print("searchServiceRequestWithID: Wir finden den ServiceRequest mit der ID:")
                    print(self.sereviceRequestObject!.id)
                    completion()
                    /*
                    for ref in sRequest.reasonReference! {
                        let obsID = ref.reference?.string.suffix(2)
                        
                        self.searchObservationWithID(id: String(obsID!), completion: {(value) in
                            
                            DispatchQueue.main.async {
                                value
                                //print("code Text")
                                //print(value.code?.text)
                            }
                            
                            
                            
                        })
                        
                    }
                    */
                }
            }
        }
        }
    }
    
    func searchObservationTypeInServiceRequestWithID(id: String, type: String, completion: (() -> Void)? = nil) {
        print("searchObservationTypeInServiceRequestWithID")
        
        self.searchServiceRequestWithID(id: id, completion: {
            
            print("In der COmpletion Methode")
            
            for ref in self.sereviceRequestObject!.reasonReference! {
                
                let obsRef = ref.reference?.string
                print("Check observation ID")
                print(ref.reference?.string)
                
                
                if let range = obsRef!.range(of: "/") {
                    let id = obsRef![range.upperBound...]
                    print(id) // prints "123.456.7891"
                    if (id != "") {
                        self.searchObservationWithIdAndType(id: String(id),type: type, completion: completion)
                    }
                    
                }
                
                
                
                
            }
        })
        
        DispatchQueue.global(qos: .background).async {
            //let search = ServiceRequest.search(["subject": "3"])
            let search = ServiceRequest.search(["_id": id])
            var sRequest = ServiceRequest()
            
            search.perform(self.client!.server) { bundle, error in
                if nil != error {
                    // there was an error
                }
                else {
                    let servReq = bundle?.entry?
                        .filter() { return $0.resource is ServiceRequest }
                        .map() { return $0.resource as! ServiceRequest }
                        
                        // now `bruces` holds all known Patient resources
                        // named Bruce and born earlier than 1970
                    //print("found service request")
                    //print(servReq?.first)
                    
                    if(!servReq!.isEmpty){
                        sRequest =  servReq!.first!
                        //print("test um die ID auszulesen!!")
                        //print(sRequest.id)
                        //print(sRequest.reasonReference)
                        
                        
                        
                    }
                }
            }
        }
        
    }
    
    /*
    
    func findObservationWithTypeInServiceRequest(id: String, type: String) -> Observation?{
        //let search = ServiceRequest.search(["subject": "3"])
        let search = ServiceRequest.search(["_id": id])
        var sRequest = ServiceRequest()
        
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
                print("found service request")
                print(servReq?.first)
                
                if(!servReq!.isEmpty){
                    sRequest =  servReq!.first!
                    print("test um die ID auszulesen!!")
                    print(sRequest.id)
                    
                    if (sRequest.reasonReference == nil) {
                        return nil
                    }else{
                        for reference in sRequest.reasonReference! {
                            <#code#>
                        }
                    }
                    
                }
            }
        }
        
        print("Das gebe ich zurück!!")
        print(sRequest.id)
        return sRequest
    }
    */
    
    
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
    
    
    func searchObservationWithIdAndType(id: String, type: String, completion: (() -> Void)? = nil) {
        print("searchObservationWithIdAndType")
        self.observationObject = nil
            //self.loadAllMediaResource(completion: completion)
        Observation.read(id, server: self.client!.server){ resource, error in
            if let error = error as? FHIRError {
                print(error)
            } else if resource != nil {
                var testObservation:Observation = resource as! Observation
                print("hier testen wir die read funktion:")
                print(testObservation.code?.text)
                if(testObservation.code!.text! == type){
                    print("Wir finden die Observation mit dem Typ")
                    print(id)
                    self.observationObject = testObservation
                    completion!()
                }
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
    
    func loadAllMediaResource(completion: (() -> Void)? = nil){
        
        print("loadAllMediaResource")
        
        
        print("I have the Observation:")
        print(observationObject!.id)
        
        var imageIDs = [String]()
        for id in observationObject!.derivedFrom! {
            var stringReference = id.reference?.string
            if let range = stringReference!.range(of: "/") {
                let newID = stringReference![range.upperBound...]
                print(newID) // prints "123.456.7891"
                if (newID != "" && newID != "replace_mediaID") {
                    imageIDs.append(String(newID))
                }
            }
        }
        //self.recursiveMediaCall(allMedia: imageIDs, completion: completion)
        self.mediaCall(allMedia: imageIDs, completion: completion)
        
        /*
        if (self.observationObject != nil){
             self.recursiveMediaCall(allMedia: self.observationObject!.derivedFrom!, completion: completion)
        }
        */
        /*
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
                
                print("I have folnd pictures:")
                print(allMedia?.count)
                
                if allMedia != nil {
                    
                    self.recursiveMediaCall(allMedia: allMedia!, completion: completion)
                    /*
                    for imageMedia in allMedia! {
                        print("ID of picture:")
                        print(imageMedia.id)
                        /*
                         let imageData = imageMedia.content?.data
                         //let data = Data(base64Encoded: imageData)
                         let decodedData = Data(base64Encoded: imageData!.value)!
                         //let data = imageData.base
                         //let decodedData = NSData(base64EncodedString: String(imageData!), options:NSData.Base64DecodingOptions.fromRaw(0)!)
                         //let decodedString = NSString(data: decodedData, encoding: NSUTF8StringEncoding)
                         //print(decodedString) // my plain data
                         //self.saveImageI(imageData: decodedData)
                         self.safeImageInDirectory(imageData: decodedData)
                         */
                        /*
                        Media.read(imageMedia.id!.string, server: self.client!.server){ resource, error in
                            if let error = error as? FHIRError {
                                print(error)
                            } else if resource != nil {
                                var testMedia:Media = resource as! Media
                                let imageData = testMedia.content?.data
                                let decodedData = Data(base64Encoded: imageData!.value)!
                                self.safeImageInDirectory(imageData: decodedData)
                                completion?()
                            }
                        }
                        */
                        
                        
                    }
                    */
                }
                //completion?()
                
                /*
                for imageItem in 0...self.photoName-1 {
                    print("I add the image:")
                    print(imageItem)
                    self.delegate?.addGalleryImage(imageName: "\(imageItem).jpg")
                }
                */
                
            }
        }
 */
        
    //}
        
    }
    
    func mediaCall(allMedia:[String],completion: (() -> Void)? = nil){
        print("mediaCall")
        var mediaIDs = allMedia
        while mediaIDs.count>1 {
            
            /*
            print("verbleibende Dateien:")
            print(allMedia.count)
            let obsRef = allMedia.last!
            print("Check MEDIA ID")
            print(obsRef)
            */
            self.MediaRead(id: mediaIDs.last!)
            /*
            Media.read(String(mediaIDs.last!), server: self.client!.server){ resource, error in
                print("readMedia")
                print(mediaIDs.last!)
                if let error = error as? FHIRError {
                    print(error)
                } else if resource != nil {
                    var testMedia:Media = resource as! Media
                    let imageData = testMedia.content?.data
                    let decodedData = Data(base64Encoded: imageData!.value)!
                    print("savveeeeeeeeee")
                    self.safeImageInDirectory(imageData: decodedData, name:String(mediaIDs.last!))
                    
                    mediaIDs.removeLast()
                    
                    print("MediaIDS innhalt:")
                    print(mediaIDs)
                    print("last:")
                    print(mediaIDs.last!)
                }
            }
            */
            
            
            
        }
        /*
        print("Letzte Datei:: Datei:")
        //print(allMedia.last!.id!.string)
        
        let obsRef = allMedia.last!
        print("Check MEDIA ID")
        print(obsRef)
        */
        self.MediaRead(id: mediaIDs.last!, completion: completion)
        /*
        Media.read(String(mediaIDs.last!), server: self.client!.server){ resource, error in
            print("readMedia")
            print(mediaIDs.last!)
            if let error = error as? FHIRError {
                print(error)
            } else if resource != nil {
                var testMedia:Media = resource as! Media
                let imageData = testMedia.content?.data
                let decodedData = Data(base64Encoded: imageData!.value)!
                print("savveeeeeeeeee LAST")
                self.safeImageInDirectory(imageData: decodedData, name:String(mediaIDs.last!))
                completion!()
            }
        }
        */
        
        
    }
    
    
    func MediaRead (id: String,completion: (() -> Void)? = nil){
        
        DispatchQueue.global(qos: .background).async {
            Media.read(String(id), server: self.client!.server){ resource, error in
                print("readMedia")
                print(id)
                if let error = error as? FHIRError {
                    print(error)
                } else if resource != nil {
                    var testMedia:Media = resource as! Media
                    let imageData = testMedia.content?.data
                    let decodedData = Data(base64Encoded: imageData!.value)!
                    print("savveeeeeeeeee")
                    self.safeImageInDirectory(imageData: decodedData, name:String(id))
                    
                    completion?()
                }
            }
            
        }
    
    }
    
 
    
    func recursiveMediaCall(allMedia:[String],completion: (() -> Void)? = nil){
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
                    completion!()
                } else if resource != nil {
                    var testMedia:Media = resource as! Media
                    let imageData = testMedia.content?.data
                    let decodedData = Data(base64Encoded: imageData!.value)!
                    self.safeImageInDirectory(imageData: decodedData, name:String(obsRef))
                    completion!()
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
                }
            }
            
            var newMedia = allMedia
            newMedia.removeLast()
            self.recursiveMediaCall(allMedia: newMedia, completion: completion)
            
        }
        
    }
    
    
    func recursiveMediaCall(allMedia:[Media],completion: (() -> Void)? = nil){
        print("recursiveMediaCall")
        if (allMedia.count == 1) {
            print("Letzte Datei:: Datei:")
            print(allMedia.last!.id!.string)
            
            Media.read(allMedia.first!.id!.string, server: self.client!.server){ resource, error in
                if let error = error as? FHIRError {
                    print(error)
                } else if resource != nil {
                    var testMedia:Media = resource as! Media
                    let imageData = testMedia.content?.data
                    let decodedData = Data(base64Encoded: imageData!.value)!
                    self.safeImageInDirectory(imageData: decodedData, name:allMedia.last!.id!.string)
                    completion?()
                }
            }
            
        }else{
            
            print("verbleibende Dateien:")
            print(allMedia.count)
            print("Ich speichere die Datei:")
            print(allMedia.last!.id!.string)
            Media.read(allMedia.last!.id!.string, server: self.client!.server){ resource, error in
                if let error = error as? FHIRError {
                    print(error)
                } else if resource != nil {
                    var testMedia:Media = resource as! Media
                    let imageData = testMedia.content?.data
                    let decodedData = Data(base64Encoded: imageData!.value)!
                    self.safeImageInDirectory(imageData: decodedData, name:allMedia.last!.id!.string)
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
    
    func deleteAllServiceRequests(){
        let search = ServiceRequest.search([])
        
        search.perform(client!.server) { bundle, error in
            if nil != error {
                // there was an error
            }
            else {
                let allServReq = bundle?.entry?
                    .filter() { return $0.resource is ServiceRequest }
                    .map() { return $0.resource as! ServiceRequest }
                    
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
    
    
    func loadImagesInBackground(type: String, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        print("loadImagesInBackground")
        DispatchQueue.global(qos: .background).async {
            Institute.shared.searchObservationTypeInServiceRequestWithID(id: self.serviceRequestID, type: type, completion: {
                self.loadAllMediaResource(completion: completion)
            })
            
        }
    }
    
    /*
    func backgroundThread(_ delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0).async() {
            background?()

            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                completion?()
            }
        }
    }
    */
    
    
}
