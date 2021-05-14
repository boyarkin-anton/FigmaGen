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
        Logger.default.info("Start spacings extraction")

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
            let items = results.flatMap { $0 }

            Logger.default.info("Found \(items.count) spacings")

            let processed: [Spacing] = items.compactMap {
                return Spacing(name: processor.process($0.name, style: .camelCase), value: $0.value)
            }

            Logger.default.success("Complete spacings extraction")

            return Promise.value(processed)
        }
    }

    func render(_ items: [Spacing], with configuration: StepConfiguration) -> Promise<Void> {
        Logger.default.info("Start spacings generation")

        let templateType = resolveTemplateType(configuration: configuration)
        let destinationPath = resolveDestinationPath(configuration: configuration)

        let renderer = DefaultSpacingsRenderer()

        do {
            try renderer.renderTemplate(
                templateType,
                to: destinationPath,
                spacings: items
            )

            Logger.default.success("Complete spacings generation")

            return .value(Void())
        } catch {
            return .init(error: error)
        }
    }

}
