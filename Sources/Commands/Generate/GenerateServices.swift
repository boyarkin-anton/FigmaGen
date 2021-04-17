//
// FigmaGen
// Copyright © 2019 HeadHunter
// MIT Licence
//

import Foundation

typealias GenerateServices = FigmaFileServices & ColorsServices & TextStylesServices & SpacingsServices

protocol FigmaFileServices {

    // MARK: - Instance Methods

    func makeFileProvider(accessToken: String) -> FigmaFileProvider
}
