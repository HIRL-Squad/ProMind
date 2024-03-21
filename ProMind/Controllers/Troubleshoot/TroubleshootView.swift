//
//  TroubleshootView.swift
//  ProMind
//
//  Created by HAIKUO YU on 22/3/24.
//

import SwiftUI

struct TroubleshootView: View {
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationSplitView {
                
            } detail: {
                TroubleshootDetailedView()
            }
        } else {
            NavigationView {
                
            }
        }
    }
}

struct TroubleshootDetailedView: View {
    var body: some View {
        VStack {
            Text("Please note that voice synthesizing function of Digit Span Test is not working well under the latest OS, which is iPadOS 17.4.")
        }
        .navigationTitle("Do NOT Upgrade to iPadOS 17.4")
        navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TroubleshootView()
}
