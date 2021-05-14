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
            return Promise.value(results.flatMap { $0 }.compactMap {
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
            })
        }
    }

    func render(_ items: [TextStyle], with configuration: StepConfiguration) -> Promise<Void> {
        let templateType = resolveTemplateType(configuration: configuration)
        let destinationPath = resolveDestinationPath(configuration: configuration)

        let renderer = DefaultTextStylesRenderer()

        do {
            try renderer.renderTemplate(
                templateType,
                to: destinationPath,
                textStyles: items
            )
            return .value(Void())
        } catch {
            return .init(error: error)
        }
    }

}
