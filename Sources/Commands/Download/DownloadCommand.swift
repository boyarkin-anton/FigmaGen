//
//  DownloadCommand.swift
//  
//
//  Created by Anton Boyarkin on 16.04.2021.
//

import Foundation
import SwiftCLI
import PathKit
import Yams
import PromiseKit

final class DownloadCommand: Command {

    // MARK: - Nested Types

    private enum Constants {
        static let defaultConfigurationPath = ".figmagen.yml"
    }

    // MARK: - Instance Properties

    let name = "download"
    let shortDescription = "Download code from Figma files using a configuration file."

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

        let promises = [
            Downloader(accessToken: accessToken).download(fileKey: fileKey, to: basePath)
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

}
