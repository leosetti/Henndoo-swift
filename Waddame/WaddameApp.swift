//
//  WaddameApp.swift
//  Waddame
//
//  Created by Leandro Setti de Almeida on 2022-07-15.
//

import SwiftUI

var shortcutItemToProcess: UIApplicationShortcutItem?

@main
struct WaddameApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            WrapperView()
        }
    }
}
