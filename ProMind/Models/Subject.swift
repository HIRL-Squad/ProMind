//
//  Subject.swift
//  ProMind
//
//  Created by Tan Wee Keat on 30/8/21.
//

import UIKit
import CryptoKit

protocol SubjectDelegate: AnyObject {
    func subject(_ subject: Subject, didSetSubjectId subjectId: String?)
    func subject(_ subject: Subject, didUpdateSarcfScores scores: [Int])
}

enum SubjectType: String {
    case TRIAL, TEST
}

enum Gender: String, Codable {
    case Male, Female, Private
}

enum DominantHand: String {
    case Left, Right
}

class Subject: Codable {
    static var shared = Subject()
    
    weak var delegate: SubjectDelegate?
    
    var subjectType: String?
    var site: String?
    var birthDate: Int64? {
        didSet {
            setSubjectId()
        }
    }
    var mobileNumber: String? {
        didSet {
            setSubjectId()
        }
    }
    var subjectId: String?
    var isPatient: Bool?
    
    var occupation: String?
    var gender: Gender?
    var educationLevel: String?
    var ethnicity: String?
    var dominantHand: String?
    var annualIncome: String?
    var housingType: String?
    var livingArrangement: String?
    
    var sarcfScores = [Int](repeating: -1, count: 5)
    
    var medicationHistory: String?
    var charlestonComorbidity: [String]?
    var bloodPressure: [Int]?
    var cholesterolLDL: Double?
    var bloodGlucose: Double?
    var mmseScore: Int?
    var mocaScore: Int?
    var diagnosis: String?
    var generalNote: String?
    
    enum CodingKeys: String, CodingKey {
        case subjectType
        case site
        case birthDate
        case subjectId
        case isPatient
        
        case occupation
        case gender
        case educationLevel
        case ethnicity
        case dominantHand
        case annualIncome
        case housingType
        case livingArrangement
        
        case sarcfScores
    }
    
    init() {
        self.birthDate = 946684800 // 01-01-2000 00:00:00 +0800
    }
    
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        indexPath = try values.decode([Int].self, forKey: .indexPath)
//        locationInText = try values.decode(Int.self, forKey: .locationInText)
//    }
    
    private func setSubjectId() {
        if let birthDate = self.birthDate, let mobileNumber = self.mobileNumber {
            if mobileNumber.count == 4 {
                subjectId = "\(mobileNumber)@\(birthDate)"
            } else {
                subjectId = nil
            }
        } else {
            subjectId = nil
        }
        
        delegate?.subject(self, didSetSubjectId: subjectId)
    }
    
    private func getSarcfScore(question: String) -> Int {
        // question -> "question1", "question2", ...
        let index = Int(String(question.last!))! // Question Index
        let optionSelected = sarcfScores[index-1]
        return optionSelected
    }
    
    private func setSarcfScore(question: String, value: String) {
        let index = Int(String(question.last!))!

        if value.contains("(0") {
            sarcfScores[index-1] = 0
        } else if value.contains("(1") {
            sarcfScores[index-1] = 1
        } else {
            sarcfScores[index-1] = 2
        }

        delegate?.subject(self, didUpdateSarcfScores: sarcfScores)
    }
    
    func MD5(string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    func toString() -> String {
        let subjectIdText = "Subject ID: \(subjectId ?? "N.A.")"
        let subjectTypeText = "Subject Type: \(subjectType ?? "N.A.")"
        let siteText = "Site: \(site ?? "N.A.")"
        
        let birthDate = Date(timeIntervalSince1970: Double(birthDate!))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        let birthDateText = "Birth Date: \(dateFormatter.string(from: birthDate))"
        
        let genderText = "Gender: \(gender ?? Gender.Private)"
        let educationLevelText = "Education Level: \(educationLevel ?? "N.A.")"
        let ethnicityText = "Ethnicity: \(ethnicity ?? "N.A.")"
        
        return "" +
            "\(subjectIdText)\n" +
            "\(subjectTypeText)\n" +
            "\(siteText)\n" +
            "\(birthDateText)\n" +
            "\(genderText)\n" +
            "\(ethnicityText)\n" +
            "\(educationLevelText)\n"
    }
}

extension Subject {
    subscript(key: String) -> AnyObject? {
        get {
            // If return nil as AnyObject, it will be casted to <null>
            switch key {
            case "subjectType":
                return subjectType as AnyObject // <null> if nil
            case "site":
                return site as AnyObject // <null> if nil
            case "isPatient":
                return isPatient as AnyObject // <null> if nil
            case "birthDate":
                return birthDate as AnyObject // <null> if nil
            case "mobileNumber":
                return mobileNumber as AnyObject // <null> if nil
            case "occupation":
                return occupation as AnyObject // <null> if nil
            case "gender":
                return gender as AnyObject // <null> if nil
            case "educationLevel":
                return educationLevel as AnyObject // <null> if nil
            case "ethnicity":
                return ethnicity as AnyObject // <null> if nil
            case "dominantHand":
                return dominantHand as AnyObject // <null> if nil
            case "annualIncome":
                return annualIncome as AnyObject // <null> if nil
            case "housingType":
                return housingType as AnyObject // <null> if nil
            case "livingArrangement":
                return livingArrangement as AnyObject // <null> if nil
            case "question1", "question2", "question3", "question4", "question5":
                let optionSelected = getSarcfScore(question: key)
                
                // If unselected, return <null>. Else, get the option in String representation, e.g., None (0 point)
                return optionSelected == -1 ? NSNull() : K.SubjectProfile.Master.questions[key]?[optionSelected] as AnyObject
            default:
                return nil // nil
            }
        }
        set(newValue) {
            switch key {
            case "subjectType":
                subjectType = newValue as? String
            case "site":
                site = newValue as? String
            case "isPatient":
                isPatient = newValue as? Bool
            case "birthDate":
                birthDate = newValue as? Int64
            case "mobileNumber":
                mobileNumber = newValue as? String
            case "occupation":
                occupation = newValue as? String
            case "gender":
                gender = Gender(rawValue: newValue as! String)
            case "educationLevel":
                educationLevel = newValue as? String
            case "ethnicity":
                ethnicity = newValue as? String
            case "dominantHand":
                dominantHand = newValue as? String
            case "annualIncome":
                annualIncome = newValue as? String
            case "housingType":
                housingType = newValue as? String
            case "livingArrangement":
                livingArrangement = newValue as? String
            case "question1", "question2", "question3", "question4", "question5":
                guard let value = newValue as? String else { return }
                setSarcfScore(question: key, value: value)
            default:
                break
            }
        }
    }
}
