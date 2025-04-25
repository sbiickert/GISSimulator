//
//  DrawingInfo.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-24.
//

import Foundation
import CoreGraphics

struct DrawingInfo: Codable {
	var zones: [String: RectangleInfo] = [:]
	var connections: [String: [ConnectionInfo]] = [:]
}

struct RectangleInfo: Codable {
	var rect: CGRect
	var label: String
	var fgColor: RGBAColor
	var bgColor: RGBAColor
	var icon: String
}

struct ConnectionInfo: Codable {
	var snap0: CGPoint
	var snap1: CGPoint
	var label: String
	var fgColor: RGBAColor
	var bgColor: RGBAColor
	var icon: String
}

struct RGBAColor: Codable {
	var r: CGFloat
	var g: CGFloat
	var b: CGFloat
	var a: CGFloat
}
