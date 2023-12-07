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
    
    let languages: [NILanguage] = [.arabic, .english]
    var selectedLanguageIdx: Int {
        for tuple in languages.enumerated() {
            if settingsProvider.currentLanguage == tuple.element { return tuple.offset }
        }
        return 0
    }
    
    let themes: [NITheme] = [.light, .dark]
    var selectedThemeIdx: Int {
        for tuple in themes.enumerated() {
            if settingsProvider.theme == tuple.element { return tuple.offset }
        }
        return 0
    }
    
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

extension NILanguage {
    var localizedString: String {
        switch self {
        case .arabic:
            return Locale(identifier: "ar").localizedString(forLanguageCode: "ar") ?? "ar"
        case .english:
            return Locale(identifier: "en").localizedString(forLanguageCode: "en") ?? "en"
        }
    }
}

extension NITheme {
    var name: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}
