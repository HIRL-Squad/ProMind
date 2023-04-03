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
    public let container: NSPersistentContainer
    public var savedEntities: [TestRecord] = []
    
    init() {
        self.container = NSPersistentContainer(name: "ProMindTestRecord")
        container.loadPersistentStores { (NSEntityDescription, NSEntityError) in
            if let NSEntityError {
                print("Error happened when loading TMTRecordCoreData!")
                print(NSEntityError.localizedDescription)
            } else {
                print("Successfully loaded TMTRecordCoreData!")
            }
        }
    }
    
    public func fetchRecords() {
        let request = NSFetchRequest<TestRecord>(entityName: "TMTRecord")
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error happened when fetch TMT records!")
            print(error.localizedDescription)
        }
    }
    
    public func addTestRecord(experimentDate: Int, experimentType: String,
                              age: Int, gender: String, annualIncome: String, educationLevel: String, ethnicity: String, patientId: String, remarks: String,
                              tmtNumStartingCircles: Int,
                              tmtNumCirclesLeftTestA: Int, tmtNumErrorsTestA: Int, tmtNumLiftsTestA: Int, tmtTotalTimeTakenTestA: Int, tmtImagePathTestA: URL,
                              tmtNumCirclesLeftTestB: Int,  tmtNumErrorsTestB: Int,  tmtNumLiftsTestB: Int, tmtTotalTimeTakenTestB: Int, tmtImagePathTestB: URL) {
        
        let newTestRecord = TestRecord(context: container.viewContext)
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
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                fetchRecords()
            } catch let error {
                print("Error happened when saving TMT records!")
                print(error.localizedDescription)
            }
        }
    }
}