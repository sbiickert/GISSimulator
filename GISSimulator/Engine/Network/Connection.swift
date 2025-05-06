//
//  Connection.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct Connection: Described, ServiceTimeCalculator, QueueProvider, Equatable, Codable {
	public static func === (lhs: Connection, rhs: Connection) -> Bool {
		lhs.source === rhs.source && lhs.destination === rhs.destination
	}
	public static func !== (lhs: Connection, rhs: Connection) -> Bool {
		lhs.source !== rhs.source || lhs.destination !== rhs.destination
	}

	public var name: String {
		get {
			"\(source.name) to \(destination.name)"
		}
		set {}
	}
	
	public var description: String {
		get {
			"\(source.description) to \(destination.description)"
		}
		set {}
	}
	
	public var source: Zone
	public var destination: Zone
	public var bandwidthMbps: Int
	public var latencyMs: Int
	
	var isLocal:Bool {
		source == destination
	}
	
	func invert() -> Connection {
		let copy = Connection(source: destination, destination: source, bandwidthMbps: bandwidthMbps, latencyMs: latencyMs)
		return copy
	}
	
	func replacingSourceOrDestination(with zone: Zone) -> Connection {
		var copy = self
		if source === zone {
			copy.source = zone
		}
		if destination === zone {
			copy.destination = zone
		}
		return copy
	}
	
	public func provideQueue() -> MultiQueue {
		MultiQueue(serviceTimeCalculator: self, waitMode: .Transmitting, channelCount: 2)
	}
	
	public func calculateServiceTime(for request: ClientRequest) -> Int? {
		guard request.solution.currentStep != nil else { return nil }
		let dataKb = request.solution.currentStep!.dataSize * 8
		
		// Mbps -> kbps -> kb per millisecond (which is the time scale of the simulation)
		let bwKbpms = bandwidthMbps * 1000 / 1000
		return dataKb / bwKbpms
	}
	
	public func calculateLatency(for request: ClientRequest) -> Int? {
		guard request.solution.currentStep != nil else { return nil }
		return latencyMs * request.solution.currentStep!.chatter
	}
}
