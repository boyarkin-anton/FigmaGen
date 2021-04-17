//
// FigmaGen
// Copyright © 2020 HeadHunter
// MIT Licence
//

import Foundation
import PromiseKit

final class SpacingsGenerator {

    static let defaultDestinationPath = "Generated/Spacings.swift"
    static let defaultTemplateName = "Spacings.stencil"

    // MARK: - Instance Properties

    private let services: SpacingsServices

    // MARK: - Initializers

    init(services: SpacingsServices) {
        self.services = services
    }

    // MARK: - Instance Methods

    func generateSpacings(from file: FigmaFile, with configuration: StepConfiguration) -> Promise<Void> {
        let templateType = resolveTemplateType(configuration: configuration)
        let destinationPath = resolveDestinationPath(configuration: configuration)

        let spacingsProvider = services.makeSpacingsProvider()
        let spacingsRenderer = services.makeSpacingsRenderer()

        return firstly {
            spacingsProvider.fetchSpacings(
                from: file,
                includingNodes: configuration.includingNodes,
                excludingNodes: configuration.excludingNodes
            )
        }.map { spacings in
            try spacingsRenderer.renderTemplate(
                templateType,
                to: destinationPath,
                spacings: spacings
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
