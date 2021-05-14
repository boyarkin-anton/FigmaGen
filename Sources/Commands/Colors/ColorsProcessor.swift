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
        Logger.default.info("Start color extraction")

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
            let colors = results.flatMap { $0 }

            Logger.default.info("Found \(colors.count) colors")

            let processed: [Color] = colors.compactMap {
                guard let name = $0.name else { return nil }

                return Color(name: processor.process(name, style: .camelCase),
                             red: $0.red,
                             green: $0.green,
                             blue: $0.blue,
                             alpha: $0.alpha)
            }

            Logger.default.success("Complete color extraction")

            return Promise.value(processed)
        }
    }

    func render(_ items: [Color], with configuration: StepConfiguration) -> Promise<Void> {
        Logger.default.info("Start color generation")

        let templateType = resolveTemplateType(configuration: configuration)
        let destinationPath = resolveDestinationPath(configuration: configuration)

        let renderer = DefaultColorsRenderer()
        
        do {
            try renderer.renderTemplate(
                templateType,
                to: destinationPath,
                colors: items
            )

            Logger.default.success("Complete color generation")

            return .value(Void())
        } catch {
            return .init(error: error)
        }
    }

}
