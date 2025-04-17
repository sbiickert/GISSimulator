//
//  ThreadingModel.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public enum ThreadingModel: String, CaseIterable {
	case Physical = "Physical"
	case HyperThreaded = "HyperThreaded"
	
	public var factor: Double {
		switch self {
		case .Physical:
			return 1.0
		case .HyperThreaded:
			return 0.5
		}
	}
}
