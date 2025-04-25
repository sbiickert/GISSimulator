//
//  HardwareDef.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct HardwareDef: Equatable, Hashable, Codable {
	private static var _baselinePerCore: Double = 10.0
	public static var BaselinePerCore: Double {
		get {
			_baselinePerCore
		}
		set {
			_baselinePerCore = newValue
		}
	}
	
	public var processor: String
	public var cores: Int
	public var specIntRate2017: Double
	public var architecture: ComputeArchitecture
	public var threading: ThreadingModel
	
	var specIntRate2017PerCore: Double {
		specIntRate2017 / Double(cores) * threading.factor
	}
}
