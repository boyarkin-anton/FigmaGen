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

    func generateSpacings(from files: [FigmaFile], with configuration: StepConfiguration) -> Promise<Void> {
        let templateType = resolveTemplateType(configuration: configuration)
        let destinationPath = resolveDestinationPath(configuration: configuration)

        let spacingsProvider = services.makeSpacingsProvider()
        let spacingsRenderer = services.makeSpacingsRenderer()

        let fetches = files.map { file in
            spacingsProvider.fetchSpacings(
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
