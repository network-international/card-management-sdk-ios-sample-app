//
//  SettingsProvider.swift
//  CardManagementSDKSwiftSample
//
//  Created by Aleksei Kiselev on 17.11.2023.
//

import Foundation
import Combine
import NICardManagementSDK

class SettingsProvider {
    @Published private(set) var currentLanguage: NILanguage
    @Published private(set) var settings: SettingsModel
    @Published private(set) var theme: NITheme
    
    init() {
        let isArabicLang = Locale.preferredLanguages.first?.hasPrefix("ar") ?? false
        currentLanguage = isArabicLang ? .arabic : .english
        settings = Self.readSettings()
        theme = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .dark : .light
    }
    
    func updateLanguage(_ language: NILanguage) {
        currentLanguage = language
    }
    
    func updateSettings(_ settings: SettingsModel) {
        self.settings = settings
    }
    
    func updateTheme(_ theme: NITheme) {
        self.theme = theme
    }
}

private extension SettingsProvider {
    static func readSettings() -> SettingsModel {
        let plistData: (_ path: String) -> Data? = { path in
            let url: URL
            if #available(iOS 16.0, *) {
                url = URL(filePath: path)
            } else {
                url = URL(fileURLWithPath: path)
            }
            return try? Data(contentsOf: url)
        }
        
        guard
            let path = Bundle.main.path(forResource: "Settings", ofType: "plist"),
            let data = plistData(path),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let dict = plist["CardView"] as? [String: Any],
            let settings = SettingsModel.decode(from: dict)
        else { return .zero }
        
        return settings
    }
}

fileprivate extension SettingsModel {
    static var zero: SettingsModel {
        .init(
            connection: .init(baseUrl: "", token: "", bankCode: ""),
            cardIdentifier: .init(Id: "", type: ""),
            pinType: .initial,
            language: .initial,
            theme: .initial
        )
    }
}
