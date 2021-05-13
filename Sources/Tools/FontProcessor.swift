//
//  FontProcessor.swift
//  
//
//  Created by Anton Boyarkin on 23.04.2021.
//

import Foundation
import Logging

enum FontWeightType: String {
    case black
    case bold
    case heavy
    case light
    case medium
    case regular
    case semibold
    case thin
    case ultraLight

    static func from(_ weight: Double) -> FontWeightType {
        switch weight {
        case 100: return .thin
        case 200: return .ultraLight
        case 300: return .light
        case 400: return .regular
        case 500: return .medium
        case 600: return .semibold
        case 700: return .bold
        case 800: return .heavy
        case 900: return .black

        default: return .regular
        }
    }
}

final class FontProcessor {

    // MARK: - Constants

    private enum Constants {
        static let systenFontName = "sfpro"
    }

    // MARK: - Private Properties

    private let node: FigmaNode
    private let styles: [String: FigmaStyle]

    private let logger = Logger(label: "FontProcessor")

    // MARK: - Initialization

    init(node: FigmaNode, styles: [String: FigmaStyle]) {
        self.node = node
        self.styles = styles
    }

    func extract() -> TextStyle? {
        guard
            case let .text(info: nodeInfo, payload: textNodePayload) = node.type,
            let nodeStyleID = nodeInfo.styleID(of: .text) else {
            return nil
        }

        guard let nodeStyle = styles[nodeStyleID], nodeStyle.type == .text  else {
            logger.error("\(TextStylesError.styleNotFound(nodeName: node.name, nodeID: node.id).description)")
            return nil
        }

        guard let nodeStyleName = nodeStyle.name, !nodeStyleName.isEmpty else {
            logger.error("\(TextStylesError.invalidStyleName(nodeName: node.name, nodeID: node.id).description)")
            return nil
        }

        guard let nodeTextStyle = textNodePayload.style else {
            logger.error("\(TextStylesError.textStyleNotFound(nodeName: node.name, nodeID: node.id).description)")
            return nil
        }

        guard let fontFamily = nodeTextStyle.fontFamily, !fontFamily.isEmpty else {
            logger.error("\(TextStylesError.invalidFontFamily(nodeName: node.name, nodeID: node.id).description)")
            return nil
        }

        guard let fontWeight = nodeTextStyle.fontWeight else {
            logger.error("\(TextStylesError.invalidFontWeight(nodeName: node.name, nodeID: node.id).description)")
            return nil
        }

        guard let fontSize = nodeTextStyle.fontSize else {
            logger.error("\(TextStylesError.invalidFontSize(nodeName: node.name, nodeID: node.id).description)")
            return nil
        }

        guard let textColor = extractTextColor(from: nodeInfo, styles: styles) else {
            logger.error("\(TextStylesError.invalidTextColor(nodeName: node.name, nodeID: node.id).description)")
            return nil
        }

        if nodeTextStyle.fontPostScriptName == nil {
            logger.warning("\(TextStylesError.invalidFontName(nodeName: node.name, nodeID: node.id).description)")
        }

        let fontName = nodeTextStyle.fontPostScriptName ?? fontFamily

        return TextStyle(
            isSystemFont: isSystem(fontName),
            name: nodeStyleName,
            fontFamily: fontFamily,
            fontPostScriptName: fontName,
            fontWeight: fontWeight,
            fontWeightType: FontWeightType.from(fontWeight),
            fontSize: fontSize,
            textColor: textColor,
            paragraphSpacing: nodeTextStyle.paragraphSpacing,
            paragraphIndent: nodeTextStyle.paragraphIndent,
            lineHeight: nodeTextStyle.lineHeight,
            letterSpacing: nodeTextStyle.letterSpacing
        )
    }

    func isSystem(_ name: String) -> Bool {
        let name = name.replacingOccurrences(of: " ", with: "")
        return name.lowercased().contains(Constants.systenFontName)
    }

    private func extractTextColor(from nodeInfo: FigmaVectorNodeInfo, styles: [String: FigmaStyle]) -> Color? {
        let nodeStyleName = nodeInfo
            .styleID(of: .fill)
            .flatMap { styles[$0] }?
            .name

        let nodeSingleSolidFill = nodeInfo
            .fills
            .flatMap { $0.count == 1 ? $0.first : nil }
            .flatMap { $0.type == .solid ? $0 : nil }

        guard let nodeFillColor = nodeSingleSolidFill?.color else {
            return nil
        }

        return Color(
            name: nodeStyleName,
            red: nodeFillColor.r,
            green: nodeFillColor.g,
            blue: nodeFillColor.b,
            alpha: nodeFillColor.a
        )
    }

}
