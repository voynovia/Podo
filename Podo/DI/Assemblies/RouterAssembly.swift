//
//  RouterAssembly.swift
//  Podo
//
//  Created by m3g0byt3 on 06/03/2018.
//  Copyright © 2018 m3g0byt3. All rights reserved.
//

import Foundation
import Swinject

final class RouterAssembly: Assembly {

    func assemble(container: Container) {
        container.register(Router.self) { resolver, rootViewController in
            return RouterImpl(rootViewController, themeProvider: resolver.resolve(ThemeProvider.self))
        }
    }
}