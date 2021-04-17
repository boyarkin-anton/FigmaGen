//
// FigmaGen
// Copyright © 2019 HeadHunter
// MIT Licence
//

import Foundation

final class Services {

    // MARK: - Instance Methods

    private func makeAPIProvider(accessToken: String) -> FigmaAPIProvider {
        return DefaultFigmaAPIProvider(accessToken: accessToken)
    }

    private func makeNodesExtractor() -> NodesExtractor {
        return DefaultNodesExtractor()
    }
}

extension Services: FigmaFileServices {

    func makeFileProvider(accessToken: String) -> FigmaFileProvider {
        return DefaultFigmaFileProvider(apiProvider: makeAPIProvider(accessToken: accessToken))
    }

}

extension Services: ColorsServices {

    // MARK: - Instance Methods

    func makeColorsProvider() -> ColorsProvider {
        return DefaultColorsProvider(nodesExtractor: makeNodesExtractor())
    }

    func makeColorsRenderer() -> ColorsRenderer {
        return DefaultColorsRenderer()
    }
}

extension Services: TextStylesServices {

    // MARK: - Instance Methods

    func makeTextStylesProvider() -> TextStylesProvider {
        return DefaultTextStylesProvider(nodesExtractor: makeNodesExtractor())
    }

    func makeTextStylesRenderer() -> TextStylesRenderer {
        return DefaultTextStylesRenderer()
    }
}

extension Services: SpacingsServices {

    // MARK: - Instance Methods

    func makeSpacingsProvider() -> SpacingsProvider {
        DefaultSpacingsProvider(nodesExtractor: makeNodesExtractor())
    }

    func makeSpacingsRenderer() -> SpacingsRenderer {
        DefaultSpacingsRenderer()
    }
}
