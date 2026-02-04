import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum RegisterMacroError: Error, CustomStringConvertible {
    case notStructOrClass
    case noArgument
    case invalidArgument

    public var description: String {
        switch self {
        case .notStructOrClass:
            return "Register macro can only be applied to structs or classes"
        case .noArgument:
            return "Register macro requires a single argument of type ConfigurableType"
        case .invalidArgument:
            return "Invalid argument for Register macro. Must be .style, .listener, or .store"
        }
    }
}

public struct Register: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let structName: String
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            structName = structDecl.name.text
        } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
            structName = classDecl.name.text
        } else {
            throw RegisterMacroError.notStructOrClass
        }

        let propertyName = lowercaseFirst(structName)

        guard let argument = node.arguments?.as(LabeledExprListSyntax.self)?.first?.expression else {
            throw RegisterMacroError.noArgument
        }

        let extensionType: String
        if argument.description.contains("style") {
            extensionType = "Styles"
        } else if argument.description.contains("listener") {
            extensionType = "Listeners"
        } else if argument.description.contains("store") {
            extensionType = "Stores"
        } else {
            throw RegisterMacroError.invalidArgument
        }

        let extensionDecl = try ExtensionDeclSyntax("extension \(raw: extensionType)") {
            try VariableDeclSyntax("static var \(raw: propertyName): \(raw: structName)") {
                "\(raw: structName)()"
            }
        }

        return [extensionDecl]
    }

    private static func lowercaseFirst(_ s: String) -> String {
        var result = s
        let firstChar = result.removeFirst()
        return firstChar.lowercased() + result
    }
}

@main
struct ViewConfigurePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Register.self,
    ]
}
