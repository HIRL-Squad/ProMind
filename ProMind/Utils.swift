//
//  Utils.swift
//  ProMind
//
//  Created by Tan Wee Keat on 27/9/21.
//

import Foundation

class Utils {
    static func sendHttpRequest() {
//        // If successful, load the information
//        guard let textField = alertMobileNumberTextField,
//              let mobileNumber = textField.text,
//              let datePicker = alertBirthDatePicker else {
//            print("Mobile Number or Birth Date not selected.")
//            self.dismiss(animated: true, completion: nil)
//            return
//        }
//                        
//        let birthDate = Int64(datePicker.date.timeIntervalSince1970)
//        let subjectId = "\(mobileNumber)@\(birthDate)"
//        print("subjectId: \(subjectId)")
//        
//        let url = URL(string: "\(K.URL.getSubject)/\(subjectId)")
//        guard let requestUrl = url else { fatalError() }
//        var request = URLRequest(url: requestUrl)
//        request.httpMethod = "GET"
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data,
//                  let response = response as? HTTPURLResponse,
//                  error == nil else {
//                print("Error occurred when sending a GET request: \(error?.localizedDescription ?? "Unknown Error")")
//                
//                DispatchQueue.main.async {
//                    self.displayAlert(
//                        title: "Subject Not Found",
//                        message: "The subject that you are looking for does not exist. Please create a new subject instead.\nError:\n\(error?.localizedDescription ?? "Unknown Error")",
//                        action: UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
//                            DispatchQueue.main.async {
//                                self.dismiss(animated: true, completion: nil)
//                            }
//                        }),
//                        dismissalTime: nil
//                    )
//                }
//                
//                return
//            }
//            
//            guard (200 ... 299) ~= response.statusCode else {
//                print("Status Code should be 2xx, but is \(response.statusCode)")
//                print("Response = \(response)")
//                
//                DispatchQueue.main.async {
//                    self.displayAlert(
//                        title: "Subject Not Found",
//                        message: "The subject that you are looking for does not exist. Please create a new subject instead.\nResponse:\n\(response)",
//                        action: UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
//                            DispatchQueue.main.async {
//                                self.dismiss(animated: true, completion: nil)
//                            }
//                        }),
//                        dismissalTime: nil
//                    )
//                }
//                
//                return
//            }
//                        
//            let responseString = String(data: data, encoding: .utf8)
//            print("subject:\n\(responseString ?? "Unable to decode response")")
//            
//            do {
//                let decoder = JSONDecoder()
//                let subject = try decoder.decode(Subject.self, from: data)
//                
//                Subject.shared = subject
//                
//                DispatchQueue.main.async {
//                    self.displayAlert(
//                        title: "Subject Loaded",
//                        message: "\(subject.toString())",
//                        action: UIAlertAction(title: "Begin", style: .default, handler: { _ in
//                            self.enterFromLoadSubjectOption = false
//                            self.performSegue(withIdentifier: K.goToTestSelectionSegue, sender: self)
//                        }),
//                        dismissalTime: nil
//                    )
//                }
//            } catch {
//                print("Error occurred while decoding Subject")
//            }
//
//
//        }
//            
//        task.resume()
//        // Else, let the user know and prompt them to return to main screen to create new subject.
    }
}
