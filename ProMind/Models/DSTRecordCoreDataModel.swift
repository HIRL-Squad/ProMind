//
//  DSTRecordCoreDataModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 31/3/23.
//

import Foundation
import UIKit
import CoreData

class DSTRecordCoreDataModel {
    public let container: NSPersistentContainer
    public var savedEntities: [TestRecord] = []
    
    init() {
        self.container = NSPersistentContainer(name: "ProMindTestRecord")
        container.loadPersistentStores { (NSEntityDescription, NSEntityError) in
            if let NSEntityError {
                print("Error happened when loading DSTRecordCoreData!")
                print(NSEntityError.localizedDescription)
            } else {
                print("Successfully loaded DSTRecordCoreData!")
            }
        }
    }
    
    public func fetchRecords() {
        let request = NSFetchRequest<TestRecord>(entityName: "DSTRecord")
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error happened when fetch DST records!")
            print(error.localizedDescription)
        }
    }
    
    public func addTestRecord(experimentDate: Int, experimentType: String,
                              age: Int, gender: String, annualIncome: String, educationLevel: String, ethnicity: String, patientId: String, remarks: String,
                              fstLongestSequence: Int, fstMaxDigits: Int, fstNumCorrectTrials: Int, fstTotalTimeTaken: Int, fstAudioPath: URL,
                              bstLongestSequence: Int, bstMaxDigits: Int, bstNumCorrectTrials: Int, bstTotalTimeTaken: Int, bstAudioPath: URL) {
        
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
        
        newTestRecord.fstLongestSequence = Int16(fstLongestSequence)
        newTestRecord.fstMaxDigits = Int16(fstMaxDigits)
        newTestRecord.fstNumCorrectTrials = Int16(fstNumCorrectTrials)
        newTestRecord.fstTotalTimeTaken = Int64(fstTotalTimeTaken)
        newTestRecord.fstAudioPath = fstAudioPath
        
        newTestRecord.bstLongestSequence = Int16(bstLongestSequence)
        newTestRecord.bstMaxDigits = Int16(bstMaxDigits)
        newTestRecord.bstNumCorrectTrials = Int16(bstNumCorrectTrials)
        newTestRecord.bstTotalTimeTaken = Int64(bstTotalTimeTaken)
        newTestRecord.bstAudioPath = bstAudioPath
        
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
                print("Error happened when saving DST records!")
                print(error.localizedDescription)
            }
        }
    }
}
