//
//  WorkflowDefStep.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct WorkflowDefStep: Described, Codable {
	public var name: String
	public var description: String
	public var serviceType: String
	public var serviceTime: Int
	public var chatter: Int
	public var requestSizeKB: Int
	public var responseSizeKB: Int
	public var dataSourceType: DataSourceType
	public var cachePercent: Int
}
