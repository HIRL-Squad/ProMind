//
//  TroubleshootIssues.swift
//  ProMind
//
//  Created by HAIKUO YU on 22/5/23.
//

import Foundation
import UIKit

enum ProMindIssues: String {
    case synthesizerNotSpeaking
    case voiceNotRecognized
}

class ProMindIssueTroubleshooter {
    private let issue: ProMindIssues
    private let fontSize: CGFloat
    
    public init(issue: ProMindIssues) {
        self.issue = issue
        self.fontSize = UIFont.systemFontSize
    }
    
    public init(issue: ProMindIssues, fontSize: CGFloat) {
        self.issue = issue
        self.fontSize = fontSize
    }
    
    private func getNormalMutableAttributedString(for string: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: fontSize)])
    }
    
    private func getNormalAttributedString(for string: String) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: fontSize)])
    }
    
    private func getBoldedAttributedString(for string: String) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .bold)])
    }
    
    public func getInstructions () -> NSAttributedString {
        switch issue {
        case .synthesizerNotSpeaking:
            let instruction = getNormalMutableAttributedString(for: "Most of the time why this happenes is because the iPad is on ")
            instruction.append(getBoldedAttributedString(for: "Slient Mode"))
            instruction.append(getNormalAttributedString(for: ". You may just open "))
            instruction.append(getBoldedAttributedString(for: "Control Center"))
            instruction.append(getNormalAttributedString(for: " (swipe from the upper right corner to the bottom left), then find the "))
            instruction.append(getBoldedAttributedString(for: "Bell Icon"))
            instruction.append(getNormalAttributedString(for: ", make sure it is not selected.\n\n"))
            
            instruction.append(getNormalAttributedString(for: "If the above step could not fix the issue, you may try those steps: \n\n1. Open "))
            instruction.append(getBoldedAttributedString(for: "Settings"))
            instruction.append(getNormalAttributedString(for: " .\n\n"))
            
            instruction.append(getNormalAttributedString(for: "2. Go to "))
            instruction.append(getBoldedAttributedString(for: "Accessibility"))
            instruction.append(getNormalAttributedString(for: " -> "))
            instruction.append(getBoldedAttributedString(for: "Spoken Content"))
            instruction.append(getNormalAttributedString(for: ".\n\n"))
            
            instruction.append(getNormalAttributedString(for: "3. Enable "))
            instruction.append(getBoldedAttributedString(for: "Speak Selection"))
            instruction.append(getNormalAttributedString(for: ", then you will notice a "))
            instruction.append(getBoldedAttributedString(for: "Voice"))
            instruction.append(getNormalAttributedString(for: " option appears.\n\n"))
            
            instruction.append(getNormalAttributedString(for: "4. Go to "))
            instruction.append(getBoldedAttributedString(for: "Voice"))
            instruction.append(getNormalAttributedString(for: ", and check if "))
            instruction.append(getBoldedAttributedString(for: "English"))
            instruction.append(getNormalAttributedString(for: ", "))
            instruction.append(getBoldedAttributedString(for: "Malay"))
            instruction.append(getNormalAttributedString(for: ", and "))
            instruction.append(getBoldedAttributedString(for: "Chinese"))
            instruction.append(getNormalAttributedString(for: " languages have their voices. If not, then just download one. \n\n"))
            
            instruction.append(getNormalAttributedString(for: "5. If the issue still persists, reboot the iPad and try again. Please contact us if rebooting could not solve this issue. "))
            
            return instruction
            
        case .voiceNotRecognized:
            let instruction = getNormalMutableAttributedString(for: "1. Double check you have connected to the Internet. Try opening a random webpage using ")
            instruction.append(getBoldedAttributedString(for: "Safari"))
            instruction.append(getNormalAttributedString(for: " to check the Internet connection.\n\n"))
            instruction.append(getNormalAttributedString(for: "2. If the issue still persists, reboot the iPad and try again. Please contact us if rebooting could not solve this issue. "))
            return instruction
        }
    }
}
