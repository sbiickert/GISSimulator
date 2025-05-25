//
//  Zone.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct Zone: Described, Equatable, Hashable, Codable {
	public static func === (lhs: Zone, rhs: Zone?) -> Bool {
		lhs.id == rhs?.id
	}
	public static func !== (lhs: Zone, rhs: Zone?) -> Bool {
		lhs.id != rhs?.id
	}

	public var id: UUID = UUID()
	public var name: String
	public var description: String
	public var zoneType: ZoneType
		
	public func connect(to other: Zone, bandwidthMbps: Int, latencyMs: Int) -> Connection {
		Connection(source: self, destination: other, bandwidthMbps: bandwidthMbps, latencyMs: latencyMs)
	}
	
	public func selfConnect(bandwidthMbps: Int, latencyMs: Int = 0) -> Connection {
		connect(to: self, bandwidthMbps: bandwidthMbps, latencyMs: latencyMs)
	}
	
	func connections(in network: [Connection]) -> [Connection] {
		return network.filter({$0.source === self || $0.destination === self})
	}
	
	func localConnection(in network: [Connection]) -> Connection? {
		let local = network.filter({$0.isLocal})
		return connections(in: local).first
	}
	
	func exitConnections(in network: [Connection]) -> [Connection] {
		return network.filter({$0.source === self && $0.destination !== self})
	}
	
	func entryConnections(in network: [Connection]) -> [Connection] {
		return network.filter({$0.source !== self && $0.destination === self})
	}
	
	func otherConnections(in network: [Connection]) -> [Connection] {
		return network.filter({$0.source !== self && $0.destination !== self})
	}
	
	func isFullyConnected(in network: [Connection]) -> Bool {
		return localConnection(in: network) != nil &&
			entryConnections(in: network).count > 0 &&
			exitConnections(in: network).count > 0
	}
	
	func connectionStatus(to other: Zone, in network: [Connection]) -> ZoneConnectionStatus {
		let exits = exitConnections(in: network)
		let entries = entryConnections(in: network)
		if exits.contains(where: {$0.destination === other}) {
			if entries.contains(where: {$0.source === other}) {
				return .Both
			}
			return .ExitOnly
		}
		if entries.contains(where: {$0.source === other}) {
			return .EnterOnly
		}
		if let route = Route.findRoute(from: self, to: other, in: network) {
			return .Indirect
		}
		return .None
	}
	
	func allComputeNodes(in computeNodes: [ComputeNode]) -> [ComputeNode] {
		return computeNodes.filter({$0.zone === self})
	}
	
	func clients(in computeNodes: [ComputeNode]) -> [ComputeNode] {
		return computeNodes.filter({$0.type == .Client})
			.filter({$0.zone === self})
	}
	
	func servers(in computeNodes: [ComputeNode]) -> [ComputeNode] {
		return computeNodes.filter({$0.type != .Client})
			.filter({$0.zone === self})
	}
	
	func workflows(in wfList: [Workflow]) -> [Workflow] {
		wfList.filter({
			let clientNodes = $0.defaultServiceProviders.flatMap({$0.nodes})
				.filter({$0.type == .Client})
			return self === clientNodes.first?.zone
		})
	}
}

enum ZoneConnectionStatus: CaseIterable {
	case None
	case ExitOnly
	case EnterOnly
	case Both
	case Indirect
}
