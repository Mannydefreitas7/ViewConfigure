//
//  Macros.swift
//
//
//  Created by Emmanuel on 03/02/2026.
//

import Foundation

public enum ConfigurableType {
    case style
    case listener
    case store
}

@attached(extension, names: prefixed(`$`))
public macro Register(_ type: ConfigurableType) = #externalMacro(module: "ViewConfigureMacros", type: "Register")
