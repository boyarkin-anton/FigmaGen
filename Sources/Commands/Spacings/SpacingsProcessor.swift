//
//  SpacingsProcessor.swift
//  
//
//  Created by Anton Boyarkin on 14.05.2021.
//

import Foundation
import PromiseKit

final class SpacingsProcessor: ItemProcessor {

    // MARK: - Constants

    static let defaultDestinationPath = "Generated/Spacings.swift"
    static let defaultTemplateName = "Spacings.stencil"

    // MARK: - Internal Methods

    func extract(from files: [FigmaFile], with configuration: StepConfiguration) -> Promise<[Spacing]> {
        let provider = DefaultSpacingsProvider(nodesExtractor: DefaultNodesExtractor())

        let fetches = files.map { file in
            provider.fetchSpacings(
                from: file,
                includingNodes: configuration.includingNodes,
                excludingNodes: configuration.excludingNodes
            )
        }
        
        let processor = NameProcessor(validateRegexp: configuration.nameValidateRegexp,
                                      replaceRegexp: configuration.nameReplaceRegexp)

        return when(fulfilled: fetches).then { results -> Promise<[Spacing]> in
            return Promise.value(results.flatMap { $0 }.compactMap {
                return Spacing(name: processor.process($0.name, style: .camelCase), value: $0.value)
            })
        }
    }

    func render(_ items: [Spacing], with configuration: StepConfiguration) -> Promise<Void> {
        let templateType = resolveTemplateType(configuration: configuration)
        let destinationPath = resolveDestinationPath(configuration: configuration)

        let renderer = DefaultSpacingsRenderer()

        do {
            try renderer.renderTemplate(
                templateType,
                to: destinationPath,
                spacings: items
            )
            return .value(Void())
        } catch {
            return .init(error: error)
        }
    }

}
