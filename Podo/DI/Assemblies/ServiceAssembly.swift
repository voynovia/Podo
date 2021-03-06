//
//  ServiceAssembly.swift
//  Podo
//
//  Created by m3g0byt3 on 28/02/2018.
//  Copyright © 2018 m3g0byt3. All rights reserved.
//

import Foundation
import Swinject
import RealmSwift
import BSK
import Moya

final class ServiceAssembly: Assembly {

    func assemble(container: Container) {

        container.register(BSKAdapter.self) { resolver in
            let plugins = resolver.resolve(PluginType.self).flatMap { [$0] } ?? []
            return BSKAdapter(providerPlugins: plugins)
        }

        container.register(NetworkServiceProtocol.self) { resolver in
            let dependencyType = BSKAdapter.self
            guard let adapter = resolver.resolve(dependencyType) else {
                unableToResolve(dependencyType)
            }
            return BSKNetworkService(adapter)
        }.inObjectScope(.weak)
        // swiftlint:disable:previous multiline_function_chains

        container.register(AnyDatabaseService<PaymentItem>.self) { _ in
            // Create custom configuration without `Object` subclasses shipped in bundled database files.
            let configuration = Realm.Configuration(objectTypes: [TransportCard.self, PaymentItem.self])
            guard let service = try? RealmDatabaseService<PaymentItem>(configuration: configuration) else {
                unableToResolve(RealmDatabaseService<PaymentItem>.self)
            }
            return AnyDatabaseService<PaymentItem>(service)
        }

        container.register(AnyDatabaseService<TransportCard>.self) { _ in
            // Create custom configuration without `Object` subclasses shipped in bundled database files
            let configuration = Realm.Configuration(objectTypes: [TransportCard.self, PaymentItem.self])
            guard let service = try? RealmDatabaseService<TransportCard>(configuration: configuration) else {
                unableToResolve(RealmDatabaseService<TransportCard>.self)
            }
            return AnyDatabaseService<TransportCard>(service)
        }

        container.register(AnyDatabaseService<SideMenuItem>.self) { _ in
            // Create custom configuration for bundled `sideMenuItemsRealm` database file
            let configuration = Realm.Configuration(fileURL: R.file.sideMenuItemsRealm(),
                                                    readOnly: true,
                                                    objectTypes: [SideMenuItem.self])
            guard let service = try? RealmDatabaseService<SideMenuItem>(configuration: configuration) else {
                unableToResolve(RealmDatabaseService<SideMenuItem>.self)
            }
            return AnyDatabaseService<SideMenuItem>(service)
        }

        container.register(AnyDatabaseService<PaymentMethod>.self) { _ in
            // Create custom configuration for bundled `paymentMethodsRealm` database file
            let configuration = Realm.Configuration(fileURL: R.file.paymentMethodsRealm(),
                                                    readOnly: true,
                                                    objectTypes: [PaymentMethod.self])
            guard let service = try? RealmDatabaseService<PaymentMethod>(configuration: configuration) else {
                unableToResolve(RealmDatabaseService<PaymentMethod>.self)
            }
            return AnyDatabaseService<PaymentMethod>(service)
        }

        container.register(ReportingServiceProtocol.self) { _ in
            return CrashlyticsReportingService()
        }

        container.register(LocationServiceProtocol.self) { _ in
            return CoreLocationService()
        }

        container.register(StationServiceProtocol.self) { _ in
            return FirebaseStationService(path: Constant.Firebase.path)
        }

    }
}
