//
//  FigmaAPINodesFileRouter.swift
//  
//
//  Created by Anton Boyarkin on 22.04.2021.
//

import Foundation

/// Route to fetch the document refered to by key.
struct FigmaAPINodesFileRouter: FigmaAPIRoute {

    // MARK: - Nested Types

    typealias Response = FigmaNodeContainerFile

    struct Parameters: Encodable {
        let version: String?
        let ids: String?
        let depth: Int?
    }

    // MARK: - Instance Properties

    /// The file key can be parsed from any Figma file URL: https://www.figma.com/file/:key/:title
    let fileKey: String

    /// Route parameters.
    let parameters: Parameters

    /// Route URL path.
    var urlPath: String {
        let isNodeLoad = parameters.ids != nil
        return "files/\(fileKey)" + (isNodeLoad ? "/nodes" : "")
    }

    // MARK: - Initializers

    /// Creates a new instance with a file key and optional parameters.
    ///
    /// - Parameter fileKey: The file key.
    /// - Parameter version: A specific version ID to get. Omitting this will get the current version of the file.
    /// - Parameter ids: List of nodes that you care about in the document.
    /// If specified, only a subset of the document will be returned corresponding to the nodes listed,
    /// their children, and everything between the root node and the listed nodes.
    /// - Parameter depth: Positive integer representing how deep into the document tree to traverse.
    /// For example, setting this to 1 returns only Pages,
    /// setting it to 2 returns Pages and all top level objects on each page.
    /// Not setting this parameter returns all nodes.
    init(fileKey: String, version: String? = nil, ids: [String]? = nil, depth: Int? = nil) {
        self.fileKey = fileKey

        self.parameters = Parameters(
            version: version,
            ids: ids?.joined(separator: ","),
            depth: depth
        )
    }
}
