//
//  ContentView.swift
//  ebuddyPTE.LTD
//
//  Created by a mutant on 21/12/24.
//

import SwiftUI
import AlertToast

struct ContentView: View {
    @ObservedObject private var allViewRecever: AllViewReceiver = AllViewReceiver.shared
    var body: some View {
        MainView()
            .toast(isPresenting: $allViewRecever.isShowingAFailedAlertToast, alert: {
                AlertToast(displayMode: .hud, type: .error(Color.red), title: allViewRecever.isShowingAFailedAlertToastMessage)
            })
            .toast(isPresenting: $allViewRecever.isShowingASuccessfulAlertToast, alert: {
                AlertToast(displayMode: .hud, type: .complete(Color.blue), title: allViewRecever.isShowingASuccessfulAlertToastMessage)
            })
    }
}

#Preview {
    ContentView()
}
