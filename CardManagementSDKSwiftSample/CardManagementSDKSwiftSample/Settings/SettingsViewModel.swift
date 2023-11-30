//
//  SettingsViewModel.swift
//  CardManagementSDKSwiftSample
//
//  Created by Aleksei Kiselev on 17.11.2023.
//

import Foundation
import NICardManagementSDK

final class SettingsViewModel {
    let settingsProvider: SettingsProvider
    
    init(settingsProvider: SettingsProvider) {
        self.settingsProvider = settingsProvider
    }
    
    func updateLanguage(_ language: NILanguage) {
        settingsProvider.updateLanguage(language)
    }
    
    func updateSettings(_ settings: SettingsModel) {
        settingsProvider.updateSettings(settings)
    }
    
    func updateTheme(_ theme: NITheme) {
        settingsProvider.updateTheme(theme)
    }
}
