//
// FigmaGen
// Copyright © 2020 HeadHunter
// MIT Licence
//

import Foundation

protocol SpacingsServices {

    // MARK: - Instance Methods

    func makeSpacingsProvider() -> SpacingsProvider
    func makeSpacingsRenderer() -> SpacingsRenderer
}
