//
//  TMTRecordCoreDataModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 31/3/23.
//

import Foundation
import UIKit
import CoreData

class TMTRecordCoreDataModel {
    private let container: NSPersistentContainer
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    public static let shared = TMTRecordCoreDataModel()
    public var savedEntities: [TMTRecord] = []
    
    private init() {
        self.container = appDelegate.persistentContainer
    }
    
    public func fetchRecords() {
        let request = NSFetchRequest<TMTRecord>(entityName: "TMTRecord")
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error happened when fetch TMT records!")
            print(error.localizedDescription)
        }
    }
    
    public func addTestRecord(experimentDate: Int64, experimentType: String,
                              age: Int, gender: String, annualIncome: String, educationLevel: String, ethnicity: String, patientId: String, remarks: String,
                              tmtNumStartingCircles: Int,
                              tmtNumCirclesLeftTestA: Int, tmtNumErrorsTestA: Int, tmtNumLiftsTestA: Int, tmtTotalTimeTakenTestA: Int, tmtImagePathTestA: URL,
                              tmtNumCirclesLeftTestB: Int,  tmtNumErrorsTestB: Int,  tmtNumLiftsTestB: Int, tmtTotalTimeTakenTestB: Int, tmtImagePathTestB: URL) {
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "TMTRecord", in: container.viewContext)!
        let newTestRecord = TMTRecord(entity: entityDescription, insertInto: container.viewContext)
        newTestRecord.experimentDate = Int64(experimentDate)
        newTestRecord.experimentType = experimentType
        
        newTestRecord.age = Int16(age)
        newTestRecord.gender = gender
        newTestRecord.annualIncome = annualIncome
        newTestRecord.educationLevel = educationLevel
        newTestRecord.ethnicity = ethnicity
        newTestRecord.patientId = patientId
        newTestRecord.remarks = remarks
        
        newTestRecord.tmtNumStartingCircles = Int16(tmtNumStartingCircles)
        
        newTestRecord.tmtNumCirclesLeftTestA = Int16(tmtNumCirclesLeftTestA)
        newTestRecord.tmtNumErrorsTestA = Int16(tmtNumErrorsTestA)
        newTestRecord.tmtNumLiftsTestA = Int16(tmtNumLiftsTestA)
        newTestRecord.tmtTotalTimeTakenTestA = Int32(tmtTotalTimeTakenTestA)
        newTestRecord.tmtImagePathTestA = tmtImagePathTestA
        
        newTestRecord.tmtNumCirclesLeftTestB = Int16(tmtNumCirclesLeftTestB)
        newTestRecord.tmtNumErrorsTestB = Int16(tmtNumErrorsTestB)
        newTestRecord.tmtNumLiftsTestB = Int16(tmtNumLiftsTestB)
        newTestRecord.tmtTotalTimeTakenTestB = Int32(tmtTotalTimeTakenTestB)
        newTestRecord.tmtImagePathTestB = tmtImagePathTestB
        
        container.viewContext.insert(newTestRecord)
        
        print(container.viewContext.insertedObjects)
        
        saveTestRecord()
    }
    
    public func deleteTestRecord(at offsets: IndexSet) {
        for index in offsets {
            let testRecordToBeDeleted = savedEntities[index]
            container.viewContext.delete(testRecordToBeDeleted)
        }
        saveTestRecord()
    }
    
    public func saveTestRecord() {
        appDelegate.saveContext()
    }
    
    public func getNumberOfRecords() -> Int {
        fetchRecords()
        return savedEntities.count
    }
    
    public func exportToCSV() async -> String {
        fetchRecords()
        var csvContent: String = "Patient ID,Age,Annual Income,Education Level,Ethnicity,Experiment Date,Experiment Type,Gender,Remarks,Number of Starting Circles,Number of Circles Left Test A,Number of Circles Left Test B,Number of Errors Test A,Number of Errors Test B,Number of Lifts Test A,Number of Lifts Test B,Total Time Taken Test A,Total Time Taken Test B\n"
        
        for tmtRecord in savedEntities {
            let patientId: String = tmtRecord.patientId ?? "No Data"
            let age: String = String(tmtRecord.age)
            let annualIncome: String = tmtRecord.annualIncome ?? "No Data"
            let educationLevel: String = tmtRecord.educationLevel ?? "No Data"
            let ethnicity: String = tmtRecord.ethnicity ?? "No Data"
            
            let date = Date(timeIntervalSince1970: TimeInterval(tmtRecord.experimentDate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
            let experimentDate: String = dateFormatter.string(from: date)
            
            let experimentType: String = tmtRecord.experimentType ?? "No Data"
            let gender: String = tmtRecord.gender ?? "No Data"
            let remarks: String = tmtRecord.remarks ?? "No Data"
            
            let tmtNumStartingCircles: String = String(tmtRecord.tmtNumStartingCircles)
            let tmtNumCirclesLeftTestA: String = String(tmtRecord.tmtNumCirclesLeftTestA)
            let tmtNumCirclesLeftTestB: String = String(tmtRecord.tmtNumCirclesLeftTestB)
            let tmtNumErrorsTestA: String = String(tmtRecord.tmtNumErrorsTestA)
            let tmtNumErrorsTestB: String = String(tmtRecord.tmtNumErrorsTestB)
            let tmtNumLiftsTestA: String = String(tmtRecord.tmtNumLiftsTestA)
            let tmtNumLiftsTestB: String = String(tmtRecord.tmtNumLiftsTestB)
            let tmtTotalTimeTakenTestA: String = String(tmtRecord.tmtTotalTimeTakenTestA)
            let tmtTotalTimeTakenTestB: String = String(tmtRecord.tmtTotalTimeTakenTestB)
            
            csvContent.append(patientId + "," + age + "," + annualIncome + "," + educationLevel + "," + ethnicity + "," + experimentDate + "," + experimentType + "," + gender + "," + remarks + "," + tmtNumStartingCircles + "," + tmtNumCirclesLeftTestA + "," + tmtNumCirclesLeftTestB + "," + tmtNumErrorsTestA + "," + tmtNumErrorsTestB + "," + tmtNumLiftsTestA + "," + tmtNumLiftsTestB + "," + tmtTotalTimeTakenTestA + "," + tmtTotalTimeTakenTestB + "\n")
        }
        return csvContent
    }
}
