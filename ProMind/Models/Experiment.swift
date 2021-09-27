//
//  Subject.swift
//  ProMind
//
//  Created by Tan Wee Keat on 30/8/21.
//

import UIKit
import CryptoKit

enum ExperimentType: String, Codable {
    case Trial, Test
}

enum Gender: String, Codable {
    case Male, Female
}

class Experiment: Codable {
    static var shared = Experiment()
        
    var experimentType: ExperimentType?

    // Consider profession also
    var age: Int?
    var gender: Gender?
    var educationLevel: String?
    var ethnicity: String?
    var annualIncome: String?
    
    var remarks: String?
    
    enum CodingKeys: String, CodingKey {
        case experimentType
        case age
        case gender
        case educationLevel
        case ethnicity
        case annualIncome
        case remarks
    }
    
    func getExperimentBody() -> [String: Any] {
        var body: [String: Any] = [:]
        
        guard let experimentType = self.experimentType else {
            fatalError("Experiment Type is nil")
        }
        
        body["experimentType"] = experimentType.rawValue
        body["experimentDate"] = Int64(Date.init().timeIntervalSince1970)

        if experimentType == .Trial {
            return body
        }
        
        if let age = self.age {
            body["subjectAge"] = age
        }
        
        if let gender = self.gender {
            body["subjectGender"] = gender.rawValue
        }
        
        if let educationLevel = self.educationLevel {
            body["subjectEducationLevel"] = educationLevel
        }
        
        if let ethnicity = self.ethnicity {
            body["subjectEthnicity"] = ethnicity
        }
        
        if let annualIncome = self.annualIncome {
            body["subjectAnnualIncome"] = annualIncome
        }
        
        if let remarks = self.remarks {
            body["remarks"] = remarks
        }
        
        return body
    }
    
    func toString() -> String {
        let experimentTypeText = "Experiment Type:\n\(experimentType?.rawValue ?? "N.A.")"
        let ageText = "Age:\n\(age != nil ? "\(age!)" : "N.A.")"
        let genderText = "Gender:\n\(gender?.rawValue ?? "N.A.")"
        let educationLevelText = "Education Level:\n\(educationLevel ?? "N.A.")"
        let ethnicityText = "Ethnicity:\n\(ethnicity ?? "N.A.")"
        let annualIncomeText = "Annual Income:\n\(annualIncome ?? "N.A.")"
        let remarksText = "Remarks:\n\(remarks ?? "N.A")"
        
        return "" +
            "\(experimentTypeText)\n\n" +
            "\(ageText)\n\n" +
            "\(genderText)\n\n" +
            "\(educationLevelText)\n\n" +
            "\(ethnicityText)\n\n" +
            "\(annualIncomeText)\n\n" +
            "\(remarksText)"
    }
}

extension Experiment {
    subscript(key: String) -> AnyObject? {
        get {
            // If return nil as AnyObject, it will be casted to <null>
            switch key {
            case K.ExperimentProfile.experimentType:
                return experimentType?.rawValue as AnyObject // <null> if nil
            case K.ExperimentProfile.age:
                return age as AnyObject // <null> if nil
            case K.ExperimentProfile.gender:
                return gender?.rawValue as AnyObject // <null> if nil
            case K.ExperimentProfile.educationLevel:
                return educationLevel as AnyObject // <null> if nil
            case K.ExperimentProfile.ethnicity:
                return ethnicity as AnyObject // <null> if nil
            case K.ExperimentProfile.annualIncome:
                return annualIncome as AnyObject // <null> if nil
            default:
                return nil // nil
            }
        }        
        set(newValue) {
            switch key {
            case K.ExperimentProfile.experimentType:
                experimentType = ExperimentType(rawValue: newValue as! String)
            case K.ExperimentProfile.age:
                age = newValue as? Int
            case K.ExperimentProfile.gender:
                gender = Gender(rawValue: newValue as! String)
            case K.ExperimentProfile.educationLevel:
                educationLevel = newValue as? String
            case K.ExperimentProfile.ethnicity:
                ethnicity = newValue as? String
            case K.ExperimentProfile.annualIncome:
                annualIncome = newValue as? String
            default:
                break
            }
        }
    }
}
