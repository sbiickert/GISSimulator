//
//  ZoneType.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public enum ZoneType: String, CaseIterable, Codable {
	case Internet = "Internet"
	case Edge = "Edge"
	case Secured = "Secured"
}
