//
//  Utils.swift
//  ProMind
//
//  Created by Tan Wee Keat on 27/9/21.
//

import Foundation

enum ProMindTestType: String {
    case trialMakingTest
    case digitSpanTest
}

class Utils {
    static func postRequest(url: URL?, httpBody: Data?) {
        guard let jsonBody = httpBody else {
            print("Failed to get HTTP body in JSON")
            return
        }

        guard let requestUrl = url else {
            fatalError("Failed to get request URL")
        }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.httpBody = jsonBody
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  error == nil else {
                print("Error occurred when sending a POST request: \(error?.localizedDescription ?? "Unknown Error")")
                
                // Possible connection error
                // Save to cache for persistent later
                
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("Status Code should be 2xx, but is \(response.statusCode)")
                print("Response = \(response)")
                return
            }

            print("Response Code: \(response.statusCode)")
            
            let responseString = String(data: data, encoding: .utf8)
            print("Response String = \(responseString ?? "Unable to decode response")")
        }

        task.resume()
    }
}
