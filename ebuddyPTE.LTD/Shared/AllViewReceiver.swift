//
//  AllViewReceiver.swift
//  ebuddyPTE.LTD
//
//  Created by a mutant on 21/12/24.
//

import Foundation

class AllViewReceiver: ObservableObject {
    /// Alert Toast
    @Published var isShowingASuccessfulAlertToast: Bool = false
    @Published var isShowingAFailedAlertToast: Bool = false
    @Published var isShowingASuccessfulAlertToastMessage: String = ""
    @Published var isShowingAFailedAlertToastMessage: String = ""
    
    static let shared = AllViewReceiver()
}
