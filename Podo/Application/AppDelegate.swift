//
//  AppDelegate.swift
//  Podo
//
//  Created by m3g0byt3 on 23/11/2017.
//  Copyright © 2017 m3g0byt3. All rights reserved.
//

import Foundation
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder,
                         UIApplicationDelegate,
                         AppDelegateConfigurable {

    // MARK: - Properties

    var window: UIWindow?
    var rootView: UIViewController? { return window?.rootViewController }
    var rootCoordinator: Coordinator?

    // MARK: - UIApplicationDelegate protocol conformance

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Perform initial DI
        // swiftlint:disable:next force_try
        try! AppDelegateConfigurator().configure(self)
        // Handle cold start from 3Dtouch shortcuts
        var startOption: StartOption?

        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            startOption = StartOption(with: shortcutItem)
        }
        rootCoordinator?.start(with: startOption)

        return startOption == nil
    }

    // MARK: - Handle 3D Touch shortcuts

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        let startOption = StartOption(with: shortcutItem)
        rootCoordinator?.start(with: startOption)
        completionHandler(startOption != nil)
    }

    // MARK: - Handle push notifications

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        let startOption = StartOption(with: userInfo)
        rootCoordinator?.start(with: startOption)
    }

    // MARK: - Handle Handoff

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let startOption = StartOption(with: userActivity)
        rootCoordinator?.start(with: startOption)
        return true
    }
}
