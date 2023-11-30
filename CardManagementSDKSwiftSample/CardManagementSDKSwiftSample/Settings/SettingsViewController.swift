//
//  SettingsViewController.swift
//  CardManagementSDKSwiftSample
//
//  Created by Aleksei Kiselev on 17.11.2023.
//

import UIKit
import Combine
import NICardManagementSDK

class SettingsViewController: UIViewController {
    private let viewModel: SettingsViewModel
    private var bag = Set<AnyCancellable>()
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

private extension SettingsViewController {
    func setupView() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        
        // MARK: - Logo
        let logo = LogoView(currentLanguage: viewModel.settingsProvider.currentLanguage)
        viewModel.settingsProvider.$currentLanguage
            .receive(on: RunLoop.main)
            .sink { [logo] lang in logo.update(with: lang) }
            .store(in: &bag)
        stackView.addArrangedSubview(logo)
        
        // MARK: - Card Identifier Id
        let cardIdentifierId = SettingsItemView(
            title: "Card Identifier Id",
            value: viewModel.settingsProvider.settings.cardIdentifier.Id,
            handler: { [weak self] text in
                guard let self = self else { return }
                var settings = self.viewModel.settingsProvider.settings
                settings.cardIdentifier.Id = text ?? ""
                self.viewModel.updateSettings(settings)
            }
        )
        stackView.addArrangedSubview(cardIdentifierId)
        
        // MARK: - Card Identifier Type
        let cardIdentifierType = SettingsItemView(
            title: "Card Identifier Type",
            value: viewModel.settingsProvider.settings.cardIdentifier.type,
            handler: { [weak self] text in
                guard let self = self else { return }
                var settings = self.viewModel.settingsProvider.settings
                settings.cardIdentifier.type = text ?? ""
                self.viewModel.updateSettings(settings)
            }
        )
        stackView.addArrangedSubview(cardIdentifierType)
        
        // MARK: - Root URL
        let rootUrl = SettingsItemView(
            title: "Root URL",
            value: viewModel.settingsProvider.settings.connection.baseUrl,
            handler: { [weak self] text in
                guard let self = self else { return }
                var settings = self.viewModel.settingsProvider.settings
                settings.connection.baseUrl = text ?? ""
                self.viewModel.updateSettings(settings)
            }
        )
        stackView.addArrangedSubview(rootUrl)
        
        // MARK: - Token
        let token = SettingsItemView(
            title: "Token",
            value: viewModel.settingsProvider.settings.connection.token,
            handler: { [weak self] text in
                guard let self = self else { return }
                var settings = self.viewModel.settingsProvider.settings
                settings.connection.token = text ?? ""
                self.viewModel.updateSettings(settings)
            }
        )
        stackView.addArrangedSubview(token)
        
        // MARK: - Bank code
        let bankCode = SettingsItemView(
            title: "Bank code",
            value: viewModel.settingsProvider.settings.connection.bankCode,
            handler: { [weak self] text in
                guard let self = self else { return }
                var settings = self.viewModel.settingsProvider.settings
                settings.connection.bankCode = text ?? ""
                self.viewModel.updateSettings(settings)
            }
        )
        stackView.addArrangedSubview(bankCode)
        
        // MARK: - PIN length
        let pinType = SettingsItemView(
            title: "PIN length",
            value: viewModel.settingsProvider.settings.pinType.text
        )
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pinType.textField.inputView = pickerView
        stackView.addArrangedSubview(pinType)
        viewModel.settingsProvider.$settings
            .map(\.pinType)
            .receive(on: RunLoop.main)
            .sink { [weak pinType] pinValue in
                pinType?.textField.text = pinValue.text
            }
            .store(in: &bag)
        
        // MARK: - Language
    }
}

// MARK: - Picker
extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { NIPinFormType.allCases.count }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        NIPinFormType.allCases[row].text
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var settings = viewModel.settingsProvider.settings
        settings.pinType = NIPinFormType.allCases[row]
        viewModel.updateSettings(settings)
        self.view.endEditing(true)
    }
}

// MARK: -
private extension NIPinFormType {
    var text: String {
        switch self {
        case .dynamic: return "4 to 6 digits"
        case .fourDigits: return "4 digits"
        case .fiveDigits: return "5 digits"
        case .sixDigits: return "6 digits"
        @unknown default:
            fatalError()
        }
    }
}
