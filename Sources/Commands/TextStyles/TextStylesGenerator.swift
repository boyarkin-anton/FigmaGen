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

    func generateTextStyles(from file: FigmaFile, with configuration: StepConfiguration) -> Promise<Void> {
        let templateType = resolveTemplateType(configuration: configuration)
        let destinationPath = resolveDestinationPath(configuration: configuration)

        let textStylesProvider = services.makeTextStylesProvider()
        let textStylesRenderer = services.makeTextStylesRenderer()

        return firstly {
            textStylesProvider.fetchTextStyles(
                from: file,
                includingNodes: configuration.includingNodes,
                excludingNodes: configuration.excludingNodes
            )
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
