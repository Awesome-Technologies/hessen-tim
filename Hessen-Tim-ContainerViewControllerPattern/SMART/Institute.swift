//
//  InstituteConnect.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Marco Festini on 27.11.19.
//  Copyright © 2019 Michael Rojkov. All rights reserved.
//

import Foundation
import SMART

class Institute {
    enum InstituteError: Error {
        case runtimeError(String)
    }
    
    static let shared = Institute()
    
    private init(){}
    
    private (set) var client: Client?
    
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
}
