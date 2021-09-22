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
    func subject(_ subject: Subject, didUpdateCharlestonComorbidity charlestonComorbidity: [String])
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
    var charlestonComorbidity = [String]() {
        didSet {
            delegate?.subject(self, didUpdateCharlestonComorbidity: charlestonComorbidity)
        }
    }
    var bloodPressure = [Int?](repeating: 0, count: 2) // Need to fix being instantiated as nil
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
        
        case medicationHistory
        case charlestonComorbidity
        case bloodPressure
        case bloodGlucose
        case cholesterolLDL
        case mmseScore
        case mocaScore
        case diagnosis
        case generalNote
    }
    
    init() {
        self.birthDate = 946684800 // 01-01-2000 00:00:00 +0800
    }
    
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
            "\(educationLevelText)"
    }
}

extension Subject {
    subscript(key: String) -> AnyObject? {
        get {
            // If return nil as AnyObject, it will be casted to <null>
            switch key {
            case K.SubjectProfile.subjectType:
                return subjectType as AnyObject // <null> if nil
            case K.SubjectProfile.site:
                return site as AnyObject // <null> if nil
            case K.SubjectProfile.isPatient:
                return isPatient as AnyObject // <null> if nil
            case K.SubjectProfile.birthDate:
                return birthDate as AnyObject // <null> if nil
            case K.SubjectProfile.mobileNumber:
                return mobileNumber as AnyObject // <null> if nil
            case K.SubjectProfile.occupation:
                return occupation as AnyObject // <null> if nil
            case K.SubjectProfile.gender:
                return gender as AnyObject // <null> if nil
            case K.SubjectProfile.educationLevel:
                return educationLevel as AnyObject // <null> if nil
            case K.SubjectProfile.ethnicity:
                return ethnicity as AnyObject // <null> if nil
            case K.SubjectProfile.dominantHand:
                return dominantHand as AnyObject // <null> if nil
            case K.SubjectProfile.annualIncome:
                return annualIncome as AnyObject // <null> if nil
            case K.SubjectProfile.housingType:
                return housingType as AnyObject // <null> if nil
            case K.SubjectProfile.livingArrangement:
                return livingArrangement as AnyObject // <null> if nil
            case K.SubjectProfile.question1, K.SubjectProfile.question2, K.SubjectProfile.question3, K.SubjectProfile.question4, K.SubjectProfile.question5:
                let optionSelected = getSarcfScore(question: key)
                
                // If unselected, return <null>. Else, get the option in String representation, e.g., None (0 point)
                return optionSelected == -1 ? NSNull() : K.SubjectProfile.Master.questions[key]?[optionSelected] as AnyObject
            case K.SubjectProfile.charlestonComorbidity:
                return charlestonComorbidity as AnyObject
            case K.SubjectProfile.diagnosis:
                return diagnosis == nil ? nil : diagnosis as AnyObject // NSNull is different from nil
            default:
                return nil // nil
            }
        }        
        set(newValue) {
            switch key {
            case K.SubjectProfile.subjectType:
                subjectType = newValue as? String
            case K.SubjectProfile.site:
                site = newValue as? String
            case K.SubjectProfile.isPatient:
                isPatient = newValue as? Bool
            case K.SubjectProfile.birthDate:
                birthDate = newValue as? Int64
            case K.SubjectProfile.mobileNumber:
                mobileNumber = newValue as? String
            case K.SubjectProfile.occupation:
                occupation = newValue as? String
            case K.SubjectProfile.gender:
                gender = Gender(rawValue: newValue as! String)
            case K.SubjectProfile.educationLevel:
                educationLevel = newValue as? String
            case K.SubjectProfile.ethnicity:
                ethnicity = newValue as? String
            case K.SubjectProfile.dominantHand:
                dominantHand = newValue as? String
            case K.SubjectProfile.annualIncome:
                annualIncome = newValue as? String
            case K.SubjectProfile.housingType:
                housingType = newValue as? String
            case K.SubjectProfile.livingArrangement:
                livingArrangement = newValue as? String
            case K.SubjectProfile.question1, K.SubjectProfile.question2, K.SubjectProfile.question3, K.SubjectProfile.question4, K.SubjectProfile.question5:
                guard let value = newValue as? String else { return }
                setSarcfScore(question: key, value: value)
            case K.SubjectProfile.charlestonComorbidity:
                charlestonComorbidity = newValue as! [String]
            case K.SubjectProfile.diagnosis:
                diagnosis = newValue as? String
            default:
                break
            }
        }
    }
}
