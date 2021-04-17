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

        guard let accessToken = configuration.base?.accessToken else {
            throw FigmaFileError.missingConfiguration
        }

        guard let fileKey = configuration.base?.fileKey else {
            throw FigmaFileError.missingConfiguration
        }

        firstly {
            Guarantee()
        }.then{
//            self.generateFile(configuration: configuration)
            Downloader(accessToken: accessToken).download(route: FigmaAPIFileRoute(fileKey: fileKey))
        }.done { file in
            self.extract(from: file, configuration: configuration, basePath: basePath)
        }.catch { error in
            self.fail(error: error)
        }

        RunLoop.main.run()
    }

    private func extract(from file: FigmaFile, configuration: Configuration, basePath: Path) {
        let promises = [
            generateColorsIfNeeded(from: file, configuration: configuration, basePath: basePath),
            generateTextStylesIfNeeded(from: file, configuration: configuration, basePath: basePath),
            generateSpacingsIfNeeded(from: file, configuration: configuration, basePath: basePath)
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

    private func generateColorsIfNeeded(from file: FigmaFile, configuration: Configuration, basePath: Path) -> Promise<Void> {
        guard let colorsConfiguration = configuration.resolveColorsConfiguration(with: basePath) else {
            return .value(Void())
        }

        return ColorsGenerator(services: services).generateColors(from: file, with: colorsConfiguration)
    }

    private func generateTextStylesIfNeeded(from file: FigmaFile, configuration: Configuration, basePath: Path) -> Promise<Void> {
        guard let textStylesConfiguration = configuration.resolveTextStylesConfiguration(with: basePath) else {
            return .value(Void())
        }

        return TextStylesGenerator(services: services).generateTextStyles(from: file, with: textStylesConfiguration)
    }

    private func generateSpacingsIfNeeded(from file: FigmaFile, configuration: Configuration, basePath: Path) -> Promise<Void> {
        guard let spacingsConfiguration = configuration.resolveSpacingsConfiguration(with: basePath) else {
            return .value(Void())
        }

        return SpacingsGenerator(services: services).generateSpacings(from: file, with: spacingsConfiguration)
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
