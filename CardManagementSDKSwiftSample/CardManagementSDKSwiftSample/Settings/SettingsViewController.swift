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
    
    // MARK: - DataSource
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    private let layout: UICollectionViewLayout = {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = true
        listConfiguration.headerMode = .firstItemInSection
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    private lazy var dataSource: DataSource = {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        return DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }()
    
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
        applySnapshot()
    }
}

private extension SettingsViewController {
    func setupView() {
        // Logo
        let logo = LogoView(currentLanguage: viewModel.settingsProvider.currentLanguage)
        view.addSubview(logo)
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            logo.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        // CollectionView
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: logo.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        viewModel.settingsProvider.$currentLanguage
            .receive(on: RunLoop.main)
            .sink { [logo] lang in logo.update(with: lang) }
            .store(in: &bag)
        viewModel.settingsProvider.$theme
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.applySnapshot() }
            .store(in: &bag)
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

// MARK: - DataSource
private extension SettingsViewController {
    enum Section: Int, CustomStringConvertible, CaseIterable {
        case cardIdentifier
        case connection
        case pinType
        case language
        case theme
        
        var description: String {
            switch self {
            case .cardIdentifier: return "Card Identifier"
            case .connection: return "Connection settings"
            case .pinType: return "Pin Length"
            case .language: return "Language"
            case .theme: return "Theme"
            }
        }
    }
    enum Item: Identifiable, Hashable {
        case header(String)
        case row(ItemValue)
        
        // MARK: - Identifiable
        var id: String {
            switch self {
            case let .row(value):
                return value.name.rawValue
            case let .header(title):
                return title
            }
        }
    }
    struct ItemValue: Hashable {
        var name: ItemName
        var text: String
    }
    enum ItemName: String {
        case cardIdentifierId = "Card Identifier Id"
        case cardIdentifierType = "Card Identifier Type"
        case rootUrl = "Root URL"
        case token = "Token"
        case bankCode = "Bank code"
        case pinLength = "PIN length"
        case language = "Language"
        case theme = "Theme"
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, item: Item) {
        if #available(iOS 16.0, *) {
            cell.backgroundConfiguration = cell.defaultBackgroundConfiguration()
        }
        switch item {
        case let .row(itemValue) where itemValue.name == .theme:
            var config = cell.segmentedConfiguration()
            config.segments = viewModel.themes.map(\.name)
            config.selectedIndex = viewModel.selectedThemeIdx
            config.segmentSelected = { [weak self, itemValue] segment in
                self?.updateSettings(itemName: itemValue.name, text: segment)
            }
            cell.contentConfiguration = config
            cell.backgroundConfiguration = nil
        case let .row(itemValue) where itemValue.name == .language:
            var config = cell.segmentedConfiguration()
            config.segments = viewModel.languages.map(\.localizedString)
            config.selectedIndex = viewModel.selectedLanguageIdx
            config.segmentSelected = { [weak self, itemValue] segment in
                self?.updateSettings(itemName: itemValue.name, text: segment)
            }
            cell.contentConfiguration = config
            cell.backgroundConfiguration = nil
        case let .row(itemValue):
            var config = cell.textFieldConfiguration()
            config.text = itemValue.text
            config.placeholder = itemValue.name.rawValue
            config.pickerSource = itemValue.name == .pinLength ? NIPinFormType.allCases.map(\.text) : nil
            config.textChanged = { [weak self, itemValue] text in
                self?.updateSettings(itemName: itemValue.name, text: text ?? "")
            }
            cell.contentConfiguration = config
        case let .header(title):
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = title
            cell.contentConfiguration = contentConfiguration
        }
    }
    func applySnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([
            .header(Section.cardIdentifier.description),
            .row(.init(
                name: .cardIdentifierId,
                text: viewModel.settingsProvider.settings.cardIdentifier.Id
            )),
            .row(.init(
                name: .cardIdentifierType,
                text: viewModel.settingsProvider.settings.cardIdentifier.type
            ))
        ], toSection: .cardIdentifier)
        snapshot.appendItems([
            .header(Section.connection.description),
            .row(.init(
                name: .rootUrl,
                text: viewModel.settingsProvider.settings.connection.baseUrl
            )),
            .row(.init(
                name: .token,
                text: viewModel.settingsProvider.settings.connection.token
            )),
            .row(.init(
                name: .bankCode,
                text: viewModel.settingsProvider.settings.connection.bankCode
            ))
        ], toSection: .connection)
        snapshot.appendItems([
            .header(Section.pinType.description),
            .row(.init(
                name: .pinLength,
                text: viewModel.settingsProvider.settings.pinType.text
            ))
        ], toSection: .pinType)
        snapshot.appendItems([
            .header(Section.language.description),
            .row(.init(
                name: .language,
                text: viewModel.settingsProvider.currentLanguage.localizedString
            ))
        ], toSection: .language)
        snapshot.appendItems([
            .header(Section.theme.description),
            .row(.init(
                name: .theme,
                text: viewModel.settingsProvider.theme.name
            ))
        ], toSection: .theme)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func updateSettings(itemName: ItemName, text: String) {
        var settings = self.viewModel.settingsProvider.settings
        switch itemName {
        case .cardIdentifierId:
            settings.cardIdentifier.Id = text
        case .cardIdentifierType:
            settings.cardIdentifier.type = text
        case .rootUrl:
            settings.connection.baseUrl = text
        case .token:
            settings.connection.token = text
        case .bankCode:
            settings.connection.bankCode = text
        case .pinLength:
            settings.pinType = NIPinFormType.allCases.first { $0.text == text } ?? NIPinFormType.allCases[0]
        case .language:
            if let lang = viewModel.languages.first(where: { $0.localizedString == text }) {
                viewModel.updateLanguage(lang)
            }
            return
        case .theme:
            if let theme = viewModel.themes.first(where: { $0.name == text }) {
                viewModel.updateTheme(theme)
            }
            return
        }
        viewModel.updateSettings(settings)
    }
}
