//
//  DSTTestResultTableViewCells.swift
//  ProMind
//
//  Created by HAIKUO YU on 2/5/23.
//

import Foundation

enum DSTTestResultTableViewCells: String {
    case patientIdCell
    case experimentDateCell
    case experimentTypeCell
    
    case ageCell
    case genderCell
    case educationLevelCell
    case ethnicityCell
    case annualIncomeCell
    case remarksCell
    
    case fstLongestConsecutiveCorrectnessCell
    case fstNumberOfCorrectTrialsCell
    case fstMaximumCorrectDigitsCell
    case fstTotalTimeTakenCell
    case fstAudioRecordingCell
    
    case bstLongestConsecutiveCorrectnessCell
    case bstNumberOfCorrectnessTrialsCell
    case bstMaximumCorrectDigitsCell
    case bstTotalTimeTakenCell
    case bstAudioRecordingCell
    
    case unselected
}
