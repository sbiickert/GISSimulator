//
//  PerformanceMetric.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public protocol PerformanceMetric {
	var sourceName: String {get set}
	var clock: Int {get set}
}

public struct QueueMetric: PerformanceMetric {
	public var sourceName: String
	public var clock: Int
	public var channelCount: Int
	public var requestCount: Int
}

public struct RequestMetric: PerformanceMetric {
	public var sourceName: String
	public var clock: Int
	public var requestName: String
	public var serviceTime: Int
	public var queueTime: Int
	public var latencyTime: Int
}
