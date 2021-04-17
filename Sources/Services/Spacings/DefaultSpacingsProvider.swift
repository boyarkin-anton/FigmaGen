//
// FigmaGen
// Copyright © 2020 HeadHunter
// MIT Licence
//

import Foundation
import PromiseKit

final class DefaultSpacingsProvider {

    // MARK: - Instance Properties

    let nodesExtractor: NodesExtractor

    // MARK: - Initializers

    init(nodesExtractor: NodesExtractor) {
        self.nodesExtractor = nodesExtractor
    }

    // MARK: - Instance Methods

    private func extractSpacing(from node: FigmaNode) throws -> Spacing? {
        guard case .component(let nodeInfo) = node.type else {
            return nil
        }
        guard !node.name.isEmpty else {
            throw SpacingsError.invalidSpacingName(nodeName: node.name, nodeID: node.id)
        }
        guard let value = nodeInfo.absoluteBoundingBox.height else {
            throw SpacingsError.spacingNotFound(nodeName: node.name, nodeID: node.id)
        }
        return Spacing(name: node.name, value: value)
    }

    private func extractSpacings(
        from file: FigmaFile,
        includingNodes includingNodeIDs: [String]?,
        excludingNodes excludingNodeIDs: [String]?
    ) throws -> [Spacing] {
        return try nodesExtractor
            .extractNodes(from: file, including: includingNodeIDs, excluding: excludingNodeIDs)
            .lazy
            .compactMap { try extractSpacing(from: $0) }
            .sorted { $0.name < $1.name }
    }
}

extension DefaultSpacingsProvider: SpacingsProvider {

    // MARK: - Instance Methods

    func fetchSpacings(
        from file: FigmaFile,
        includingNodes includingNodeIDs: [String]?,
        excludingNodes excludingNodeIDs: [String]?
    ) -> Promise<[Spacing]> {
        return Promise { seal in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let value = try self.extractSpacings(from: file,
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
