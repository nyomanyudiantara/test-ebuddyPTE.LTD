//
//  ebuddyPTE_LTDApp.swift
//  ebuddyPTE.LTD
//
//  Created by a mutant on 21/12/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct ebuddyPTE_LTDApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("EBUDDY-darkmode") private var isSwitchingDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup(content: {
            ContentView()
                .preferredColorScheme(isSwitchingDarkMode ? .dark : .light)
        })
    }
}
