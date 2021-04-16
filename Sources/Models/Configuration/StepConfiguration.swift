//
// FigmaGen
// Copyright © 2019 HeadHunter
// MIT Licence
//

import Foundation
import PathKit

struct StepConfiguration: Decodable {

    // MARK: - Instance Properties

    let fileKey: String?
    let accessToken: String?
    let includingNodes: [String]?
    let excludingNodes: [String]?
    let templatePath: String?
    let destinationPath: String?

    // MARK: - Instance Methods

    func resolve(baseConfiguration: BaseConfiguration?, basePath: Path) -> StepConfiguration {
        guard let baseConfiguration = baseConfiguration else {
            return self
        }

        return StepConfiguration(
            fileKey: fileKey ?? baseConfiguration.fileKey,
            accessToken: accessToken ?? baseConfiguration.accessToken,
            includingNodes: includingNodes,
            excludingNodes: excludingNodes,
            templatePath: basePath.appending(templatePath ?? "").string,
            destinationPath: basePath.appending(destinationPath ?? "").string
        )
    }
}
