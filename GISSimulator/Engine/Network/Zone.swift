//
//  Zone.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct Zone: Described, Equatable, Hashable {
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
		return network.filter({$0.source == self || $0.destination == self})
	}
	
	func localConnection(in network: [Connection]) -> Connection? {
		let local = network.filter({$0.isLocal})
		return connections(in: local).first
	}
	
	func exitConnections(in network: [Connection]) -> [Connection] {
		return network.filter({$0.source == self && $0.destination != self})
	}
	
	func entryConnections(in network: [Connection]) -> [Connection] {
		return network.filter({$0.source != self && $0.destination == self})
	}
	
	func isFullyConnected(in network: [Connection]) -> Bool {
		return localConnection(in: network) != nil &&
			entryConnections(in: network).count > 0 &&
			exitConnections(in: network).count > 0
	}
	
	func clients(in computeNodes: [ComputeNode]) -> [Client] {
		return computeNodes.compactMap({$0 as? Client ?? nil})
			.filter({$0.zone == self})
	}
	
	func servers(in computeNodes: [ComputeNode]) -> [ComputeNode] {
		let pHosts = computeNodes.compactMap({$0 as? PhysicalHost ?? nil})
		let vHosts = computeNodes.compactMap({$0 as? VirtualHost ?? nil})
		return pHosts.filter({$0.zone == self}) + vHosts.filter({$0.zone == self})
	}
	
	func workflows(in wfList: [Workflow]) -> [Workflow] {
		wfList.filter({
			let clientNodes = $0.defaultServiceProviders.flatMap({$0.nodes})
				.filter({$0 is Client})
			return (clientNodes.first?.zone ?? nil) == self
		})
	}
}
