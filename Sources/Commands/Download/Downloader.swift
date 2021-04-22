//
//  Downloader.swift
//  
//
//  Created by Anton Boyarkin on 16.04.2021.
//

import Foundation
import PromiseKit
import Alamofire
import PathKit

final class Downloader {

    // MARK: - Nested Types

    private enum Constants {
        static let serverBaseURL = URL(string: "https://api.figma.com")!
        static let accessTokenHeaderName = "X-Figma-Token"
    }

    // MARK: - Instance Properties

    private let alamofireSession: Alamofire.Session
    private let responseDecoder: JSONDecoder

    // MARK: - Private Properties

    private let configuration: Configuration

    // MARK: - Initializers

    init(with configuration: Configuration) {
        self.configuration = configuration

        alamofireSession = Alamofire.Session()
        responseDecoder = JSONDecoder()

        responseDecoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = DateFormatter.figmaAPI(withMilliseconds: true).date(from: dateString) {
                return date
            }

            if let date = DateFormatter.figmaAPI(withMilliseconds: false).date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date string does not match format expected by formatter"
            )
        }
    }

    func download(to path: Path) throws -> Promise<Void> {
        guard let fileKey = configuration.base?.fileKey else {
            throw FigmaFileError.missingConfiguration
        }

        let backgroundQueue = DispatchQueue.global(qos: .background)

        return firstly {
            Guarantee()
        }.then(on: backgroundQueue) {
            try self.fetch(route: FigmaAPIFileRoute(fileKey: fileKey))
        }.then(on: backgroundQueue) { data in
            self.save(data, to: path)
        }
    }

    func download<T: FigmaAPIRoute>(route: T) throws -> Promise<T.Response> {
        let backgroundQueue = DispatchQueue.global(qos: .background)

        return firstly {
            Guarantee()
        }.then(on: backgroundQueue) {
            try self.fetch(route: route)
        }.then(on: backgroundQueue) { data in
            self.decode(data, to: route)
        }
    }

    func fetch<T: FigmaAPIRoute>(route: T) throws -> Promise<Data> {
        guard let accessToken = configuration.base?.accessToken else {
            throw FigmaFileError.missingConfiguration
        }

        let url = Constants.serverBaseURL
            .appendingPathComponent(route.apiVersion.urlPath)
            .appendingPathComponent(route.urlPath)

        let accessTokenHTTPHeader = HTTPHeader(name: Constants.accessTokenHeaderName, value: accessToken)

        let httpMethod = HTTPMethod(rawValue: route.httpMethod.rawValue)
        let httpHeaders = HTTPHeaders([accessTokenHTTPHeader])

        return Promise { seal in
            alamofireSession.request(
                url,
                method: httpMethod,
                parameters: route.parameters,
                headers: httpHeaders
            )
            .validate()
            .responseData { response in
                switch response.result {
                case let .failure(error):
                    seal.reject(error)

                case let .success(value):
                    seal.fulfill(value)
                }
            }
        }
    }

    func decode<Route: FigmaAPIRoute>(_ data: Data, to route: Route) -> Promise<Route.Response> {
        return Promise { seal in
            do {
                let value = try responseDecoder.decode(Route.Response.self, from: data)
                seal.fulfill(value)
            } catch {
                seal.reject(error)
            }
        }
    }

    func save(_ data: Data, to path: Path) -> Promise<Void> {
        let destinationPath = path.appending("figma.json")
        let rendered = String(decoding: data, as: UTF8.self)
        do {
            try destinationPath.write(rendered, encoding: .utf8)
            return .value(Void())
        } catch {
            return .init(error: error)
        }
    }

}
