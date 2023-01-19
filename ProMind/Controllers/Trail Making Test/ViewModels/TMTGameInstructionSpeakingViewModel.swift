//
//  TMTGameInstructionSpeakingViewModel.swift
//  ProMind
//
//  Created by HAIKUO YU on 2/10/22.
//

import Foundation
import UIKit

class TMTGameInstructionSpeakingViewModel: NSObject, ObservableObject, TMTInstructionSpeakingDelegate {
    
    internal var viewModel: TMTViewModels
    internal var rate: Double
    // internal var instructions: [String]
    
    private let speaker = InstructionSpeaker()
    private let notification = NotificationBroadcast()
    
    static let shared = TMTGameInstructionSpeakingViewModel(rate: 0.4, viewModel: .TMTGameViewModel)
    
    private init(rate: Double, viewModel: TMTViewModels) {
        self.rate = rate
        self.viewModel = viewModel
        super.init()
        self.speaker.delegate = self
    }
    
    internal func speechDidStart() {
        notification.post("Update Instruction Text\(viewModel)", object: nil)
    }
    
    internal func speechDidFinish() {
        
    }
    
    
}
