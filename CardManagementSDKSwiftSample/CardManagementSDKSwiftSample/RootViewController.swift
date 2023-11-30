//
//  RootViewController.swift
//  CardManagementSDKSwiftSample
//
//  Created by Aleksei Kiselev on 16.11.2023.
//

import UIKit
import NICardManagementSDK

class RootViewController: UITabBarController {
    private let viewModel: RootViewModel
    
    init() {
        viewModel = RootViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .background)
        
        let cardVc = CardViewController(viewModel: CardViewModel(settingsProvider: viewModel.settingsProvider))
        cardVc.tabBarItem = UITabBarItem(title: "Card", image: UIImage(systemName: "creditcard.and.123"), tag: 0)
        
        let settingsVc = SettingsViewController(viewModel: SettingsViewModel(settingsProvider: viewModel.settingsProvider))
        settingsVc.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 1)
        
        viewControllers = [cardVc, settingsVc]
    }
}
