//
//  ColorsProcessor.swift
//  
//
//  Created by Anton Boyarkin on 14.05.2021.
//

import Foundation
import PromiseKit

final class ColorsProcessor: ItemProcessor {

    // MARK: - Constants

    static let defaultDestinationPath = "Generated/Colors.swift"
    static let defaultTemplateName = "Colors.stencil"

    // MARK: - Internal Methods

    func extract(from files: [FigmaFile], with configuration: StepConfiguration) -> Promise<[Color]> {
        let provider = DefaultColorsProvider(nodesExtractor: DefaultNodesExtractor())

        let fetches = files.map { file in
            provider.fetchColors(
                from: file,
                includingNodes: configuration.includingNodes,
                excludingNodes: configuration.excludingNodes
            )
        }
        
        let processor = NameProcessor(validateRegexp: configuration.nameValidateRegexp,
                                      replaceRegexp: configuration.nameReplaceRegexp)

        return when(fulfilled: fetches).then { results -> Promise<[Color]> in
            return Promise.value(results.flatMap { $0 }.compactMap {
                guard let name = $0.name else { return nil }

                return Color(name: processor.process(name, style: .camelCase),
                             red: $0.red,
                             green: $0.green,
                             blue: $0.blue,
                             alpha: $0.alpha)
            })
        }
    }

    func render(_ items: [Color], with configuration: StepConfiguration) -> Promise<Void> {
        let templateType = resolveTemplateType(configuration: configuration)
        let destinationPath = resolveDestinationPath(configuration: configuration)

        let renderer = DefaultColorsRenderer()
        
        do {
            try renderer.renderTemplate(
                templateType,
                to: destinationPath,
                colors: items
            )
            return .value(Void())
        } catch {
            return .init(error: error)
        }
    }

}
