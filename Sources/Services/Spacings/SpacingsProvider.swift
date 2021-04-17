//
// FigmaGen
// Copyright © 2020 HeadHunter
// MIT Licence
//

import Foundation
import PromiseKit

protocol SpacingsProvider {

    // MARK: - Instance Methods

    func fetchSpacings(
        from file: FigmaFile,
        includingNodes includingNodeIDs: [String]?,
        excludingNodes excludingNodeIDs: [String]?
    ) -> Promise<[Spacing]>
}
