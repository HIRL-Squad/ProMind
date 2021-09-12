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

class Subject {
    enum SubjectType: String {
        case TRIAL, TEST
    }
    
    enum Gender: String {
        case Male, Female
    }
    
    enum DominantHand: String {
        case Left, Right
    }
    
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
