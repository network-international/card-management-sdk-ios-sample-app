//
//  SettingsViewModel.swift
//  CardManagementSDKSwiftSample
//
//  Created by Aleksei Kiselev on 16.11.2023.
//

import Foundation
import NICardManagementSDK

struct SettingsModel {
    var connection: Connection
    var cardIdentifier: CardIdentifier
    var pinType: NIPinFormType
}

extension SettingsModel {
    struct Connection {
        var baseUrl: String
        var token: String
        var bankCode: String
    }
    struct CardIdentifier {
        var Id: String
        var type: String
    }
}

extension SettingsModel {
    static func decode(from dict: [String: Any]) -> Self? {
        guard
            let connection = Connection.decode(from: dict["connection"] as? [String: String] ?? [:]),
            let cardIdentifier = CardIdentifier.decode(from: dict["cardIdentifier"] as? [String: String] ?? [:])
        else { return nil }
        return .init(
            connection: connection,
            cardIdentifier: cardIdentifier,
            pinType: .initial
        )
    }
}
extension SettingsModel.Connection {
    static func decode(from dict: [String: String]) -> Self? {
        guard
            let baseUrl = dict["baseUrl"],
            let token = dict["token"],
            let bankCode = dict["bankCode"]
        else { return nil }
        return .init(baseUrl: baseUrl, token: token, bankCode: bankCode)
    }
}
extension SettingsModel.CardIdentifier {
    static func decode(from dict: [String: String]) -> Self? {
        guard let id = dict["Id"], let type = dict["type"] else { return nil }
        return .init(Id: id, type: type)
    }
}

extension NIPinFormType {
    // according to SDK if no pinType provided - use `.dynamic`
    static var initial: Self { .fourDigits }
}
