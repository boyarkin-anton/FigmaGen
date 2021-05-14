//
//  ItemProcessor.swift
//  
//
//  Created by Anton Boyarkin on 14.05.2021.
//

import Foundation
import PromiseKit

protocol ItemProcessor {
    associatedtype T
    
    static var defaultDestinationPath: String { get }
    static var defaultTemplateName: String { get }

    func extract(from files: [FigmaFile], with configuration: StepConfiguration) -> Promise<[T]>
    func render(_ items: [T], with configuration: StepConfiguration) -> Promise<Void>
}

extension ItemProcessor {

    func resolveTemplateType(configuration: StepConfiguration) -> TemplateType {
        if let templatePath = configuration.templatePath {
            return .custom(path: templatePath)
        } else {
            return .native(name: Self.defaultTemplateName)
        }
    }

    func resolveDestinationPath(configuration: StepConfiguration) -> String {
        return configuration.destinationPath ?? Self.defaultDestinationPath
    }

}
