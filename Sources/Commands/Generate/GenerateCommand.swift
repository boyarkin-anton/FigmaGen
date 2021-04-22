//
// FigmaGen
// Copyright © 2019 HeadHunter
// MIT Licence
//

import Foundation
import SwiftCLI
import PathKit
import Yams
import PromiseKit

final class GenerateCommand: Command {

    // MARK: - Nested Types

    private enum Constants {
        static let defaultConfigurationPath = ".figmagen.yml"
    }

    // MARK: - Instance Properties

    let name = "generate"
    let shortDescription = "Generates code from Figma files using a configuration file."

    let configurationPath = Key<String>(
        "--config",
        description: """
            Path to the configuration file.
            Defaults to '\(Constants.defaultConfigurationPath)'.
            """
    )

    private let services: GenerateServices

    // MARK: - Initializers

    init(services: GenerateServices) {
        self.services = services
    }

    // MARK: - Instance Methods

    func execute() throws {
        let configurationPath = Path(self.configurationPath.value ?? Constants.defaultConfigurationPath)
        let configuration = try YAMLDecoder().decode(Configuration.self, from: configurationPath.read())
        let basePath = configurationPath.parent()

        guard let fileKey = configuration.base?.fileKey else {
            throw FigmaFileError.missingConfiguration
        }

        let ids = [
            configuration.colors?.includingNodes ?? [],
            configuration.spacings?.includingNodes ?? [],
            configuration.textStyles?.includingNodes ?? []
        ].flatMap { $0 }

        firstly {
            Guarantee()
        }.then {
            try Downloader(with: configuration)
                .download(route: FigmaAPINodesFileRouter(fileKey: fileKey,
                                                         ids: ids.isEmpty ? nil : ids))
        }.done { container in
            let nodes = container.nodes.map { $0.value }
            self.extract(from: nodes, configuration: configuration, basePath: basePath)
        }.catch { error in
            self.fail(error: error)
        }

        RunLoop.main.run()
    }

    private func extract(from nodes: [FigmaFile], configuration: Configuration, basePath: Path) {
        let promises = [
            generateColorsIfNeeded(from: nodes, configuration: configuration, basePath: basePath),
            generateTextStylesIfNeeded(from: nodes, configuration: configuration, basePath: basePath),
            generateSpacingsIfNeeded(from: nodes, configuration: configuration, basePath: basePath)
        ]

        firstly {
            when(fulfilled: promises)
        }.done {
            self.success(message: "Generation completed successfully!")
        }.catch { error in
            self.fail(error: error)
        }

        RunLoop.main.run()
    }

    private func generateFile(configuration: Configuration) -> Promise<FigmaFile> {
        return FigmaFileGenerator(services: services).generateFile(configuration: configuration)
    }

    private func generateColorsIfNeeded(from files: [FigmaFile], configuration: Configuration, basePath: Path) -> Promise<Void> {
        guard let colorsConfiguration = configuration.resolveColorsConfiguration(with: basePath) else {
            return .value(Void())
        }

        return ColorsGenerator(services: services).generateColors(from: files, with: colorsConfiguration)
    }

    private func generateTextStylesIfNeeded(from files: [FigmaFile], configuration: Configuration, basePath: Path) -> Promise<Void> {
        guard let textStylesConfiguration = configuration.resolveTextStylesConfiguration(with: basePath) else {
            return .value(Void())
        }

        return TextStylesGenerator(services: services).generateTextStyles(from: files, with: textStylesConfiguration)
    }

    private func generateSpacingsIfNeeded(from files: [FigmaFile], configuration: Configuration, basePath: Path) -> Promise<Void> {
        guard let spacingsConfiguration = configuration.resolveSpacingsConfiguration(with: basePath) else {
            return .value(Void())
        }

        return SpacingsGenerator(services: services).generateSpacings(from: files, with: spacingsConfiguration)
    }
}

final class FigmaFileGenerator {

    // MARK: - Instance Properties

    private let services: FigmaFileServices

    // MARK: - Initializers

    init(services: FigmaFileServices) {
        self.services = services
    }

    func generateFile(configuration: Configuration) -> Promise<FigmaFile> {
        guard let accessToken = configuration.base?.accessToken else {
            return .init(error: FigmaFileError.missingConfiguration)
        }

        guard let fileKey = configuration.base?.fileKey else {
            return .init(error: FigmaFileError.missingConfiguration)
        }

        let provider = services.makeFileProvider(accessToken: accessToken)

        return firstly {
            provider.fetch(fileKey: fileKey)
        }
    }

}
