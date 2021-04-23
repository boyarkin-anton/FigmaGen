//
// FigmaGen
// Copyright © 2019 HeadHunter
// MIT Licence
//

import Foundation
import PromiseKit

final class DefaultTextStylesProvider {

    // MARK: - Instance Properties

    let nodesExtractor: NodesExtractor

    // MARK: - Initializers

    init(nodesExtractor: NodesExtractor) {
        self.nodesExtractor = nodesExtractor
    }

    // MARK: - Instance Methods

    private func extractTextStyles(
        from file: FigmaFile,
        includingNodes includingNodeIDs: [String]?,
        excludingNodes excludingNodeIDs: [String]?
    ) throws -> [TextStyle] {
        return try nodesExtractor
            .extractNodes(from: file, including: includingNodeIDs, excluding: excludingNodeIDs)
            .lazy
            .compactMap { FontProcessor(node: $0, styles: file.styles ?? [:]).extract() }
            .reduce(into: []) { result, textStyle in
                if !result.contains(textStyle) {
                    result.append(textStyle)
                }
            }
    }
}

extension DefaultTextStylesProvider: TextStylesProvider {

    // MARK: - Instance Methods

    func fetchTextStyles(
        from file: FigmaFile,
        includingNodes includingNodeIDs: [String]?,
        excludingNodes excludingNodeIDs: [String]?
    ) -> Promise<[TextStyle]> {
        return Promise { seal in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let value = try self.extractTextStyles(from: file,
                                                           includingNodes: includingNodeIDs,
                                                           excludingNodes: excludingNodeIDs)
                    seal.fulfill(value)
                } catch {
                    seal.reject(error)
                }
            }
        }
    }

}
