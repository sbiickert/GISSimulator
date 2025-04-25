//
//  Service.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct ServiceDef: Described, Hashable, Codable {
	public var name: String
	public var description: String
	public var serviceType: String
	public var balancingModel: BalancingModel
}
