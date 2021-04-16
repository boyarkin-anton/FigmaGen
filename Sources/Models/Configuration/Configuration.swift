//
// FigmaGen
// Copyright © 2019 HeadHunter
// MIT Licence
//

import Foundation
import PathKit

struct Configuration: Decodable {

    // MARK: - Instance Properties

    let base: BaseConfiguration?

    let colors: StepConfiguration?
    let textStyles: StepConfiguration?
    let spacings: StepConfiguration?

    // MARK: - Instance Methods

    func resolveColorsConfiguration(with basePath: Path) -> StepConfiguration? {
        return colors?.resolve(baseConfiguration: base, basePath: basePath)
    }

    func resolveTextStylesConfiguration(with basePath: Path) -> StepConfiguration? {
        return textStyles?.resolve(baseConfiguration: base, basePath: basePath)
    }

    func resolveSpacingsConfiguration(with basePath: Path) -> StepConfiguration? {
        return spacings?.resolve(baseConfiguration: base, basePath: basePath)
    }
}
