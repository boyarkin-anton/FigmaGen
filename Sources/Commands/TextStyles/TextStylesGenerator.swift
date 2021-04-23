//
// FigmaGen
// Copyright © 2019 HeadHunter
// MIT Licence
//

import Foundation
import PromiseKit

final class TextStylesGenerator {

    // MARK: - Type Properties

    static let defaultTemplateName = "TextStyles.stencil"
    static let defaultDestinationPath = "Generated/TextStyles.swift"

    // MARK: - Instance Properties

    private let services: TextStylesServices

    // MARK: - Initializers

    init(services: TextStylesServices) {
        self.services = services
    }

    // MARK: - Instance Methods

    func generateTextStyles(from files: [FigmaFile], with configuration: StepConfiguration) -> Promise<Void> {
        let templateType = resolveTemplateType(configuration: configuration)
        let destinationPath = resolveDestinationPath(configuration: configuration)

        let textStylesProvider = services.makeTextStylesProvider()
        let textStylesRenderer = services.makeTextStylesRenderer()

        let fetches = files.map { file in
            textStylesProvider.fetchTextStyles(
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
        }.map { textStyles in
            try textStylesRenderer.renderTemplate(
                templateType,
                to: destinationPath,
                textStyles: textStyles
            )
        }
    }

    private func resolveTemplateType(configuration: StepConfiguration) -> TemplateType {
        if let templatePath = configuration.templatePath {
            return .custom(path: templatePath)
        } else {
            return .native(name: Self.defaultTemplateName)
        }
    }

    private func resolveDestinationPath(configuration: StepConfiguration) -> String {
        return configuration.destinationPath ?? Self.defaultDestinationPath
    }
}
