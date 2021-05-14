//
//  TextStylesProcessor.swift
//  
//
//  Created by Anton Boyarkin on 14.05.2021.
//

import Foundation
import PromiseKit

final class TextStylesProcessor: ItemProcessor {

    // MARK: - Constants

    static let defaultTemplateName = "TextStyles.stencil"
    static let defaultDestinationPath = "Generated/TextStyles.swift"

    // MARK: - Internal Methods

    func extract(from files: [FigmaFile], with configuration: StepConfiguration) -> Promise<[TextStyle]> {
        Logger.default.info("Start text styles extraction")

        let provider = DefaultTextStylesProvider(nodesExtractor: DefaultNodesExtractor())

        let fetches = files.map { file in
            provider.fetchTextStyles(
                from: file,
                includingNodes: configuration.includingNodes,
                excludingNodes: configuration.excludingNodes
            )
        }

        let processor = NameProcessor(validateRegexp: configuration.nameValidateRegexp,
                                      replaceRegexp: configuration.nameReplaceRegexp)

        return when(fulfilled: fetches).then { results -> Promise<[TextStyle]> in
            let items = results.flatMap { $0 }

            Logger.default.info("Found \(items.count) text styles")

            let processed: [TextStyle] = items.compactMap {
                return TextStyle(isSystemFont: $0.isSystemFont,
                                 name: processor.process($0.name, style: .camelCase),
                                 fontFamily: $0.fontFamily,
                                 fontPostScriptName: $0.fontPostScriptName,
                                 fontWeight: $0.fontWeight,
                                 fontWeightType: $0.fontWeightType,
                                 fontSize: $0.fontSize,
                                 textColor: $0.textColor,
                                 paragraphSpacing: $0.paragraphSpacing,
                                 paragraphIndent: $0.paragraphIndent,
                                 lineHeight: $0.lineHeight,
                                 letterSpacing: $0.letterSpacing)
            }

            Logger.default.success("Complete text styles extraction")

            return Promise.value(processed)
        }
    }

    func render(_ items: [TextStyle], with configuration: StepConfiguration) -> Promise<Void> {
        Logger.default.info("Start text styles generation")

        let templateType = resolveTemplateType(configuration: configuration)
        let destinationPath = resolveDestinationPath(configuration: configuration)

        let renderer = DefaultTextStylesRenderer()

        do {
            try renderer.renderTemplate(
                templateType,
                to: destinationPath,
                textStyles: items
            )

            Logger.default.success("Complete  text styles generation")

            return .value(Void())
        } catch {
            return .init(error: error)
        }
    }

}
