//
//  NameProcessor.swift
//  
//
//  Created by Anton Boyarkin on 22.04.2021.
//

import Foundation

class NameProcessor {
    
    enum NameStyle: String {
        case camelCase = "camelCase"
        case snakeCase = "snake_case"
    }

    let validateRegexp: String?
    let replaceRegexp: String?

    init(validateRegexp: String?, replaceRegexp: String?) {
        self.validateRegexp = validateRegexp
        self.replaceRegexp = replaceRegexp
    }

    func process(_ name: String, style: NameStyle? = nil) -> String {
        var processedName = name

        if let replaceRegexp = replaceRegexp, let validateRegexp = validateRegexp {
            processedName = replace(processedName,
                                    validateRegexp: validateRegexp,
                                    replaceRegexp: replaceRegexp)
        } else {
            processedName = normalize(processedName)
        }

        if let style = style {
            processedName = normalizeName(processedName, style: style)
        }

        return processedName
    }

    private func replace(_ name: String, validateRegexp: String, replaceRegexp: String) -> String {
        let result = name.replace(validateRegexp) { array in
            replaceRegexp.replace(#"\$(\d)"#) {
                let index = Int($0[1])!
                return array[index]
            }
        }
        
        return result
    }
    
    /// Normalizes asset name by replacing "/" with "_" and by removing duplication (e.g. "color/color" becomes "color"
    func normalize(_ name: String) -> String {
        var renamedName = name
        
        let split = name.split(separator: "/")
        if split.count == 2, split[0] == split[1] {
            renamedName = String(split[0])
        } else {
            renamedName = renamedName.replacingOccurrences(of: "/", with: "_")
        }
        return renamedName
    }

    func normalizeName(_ name: String, style: NameStyle) -> String {
        switch style {
        case .camelCase:
            return name.lowerCamelCased()
        case .snakeCase:
            return name.snakeCased()
        }
    }

}
