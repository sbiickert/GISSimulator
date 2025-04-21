//
//  Design.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-19.
//

import Foundation

public struct Design: Described, Validatable {
	public var name: String
	public var description: String
	public var zones: [Zone] = []
	public var network: [Connection] = []
	public var computeNodes: [ComputeNode] = []
	public var services: Dictionary<String, Service> = [:]
	public var serviceProviders: [ServiceProvider] = []
	public var workflows: [Workflow] = []
	
	public var isValid: Bool {
		return validate().isEmpty
	}
	public func validate() -> [ValidationMessage] {
		var messages: [ValidationMessage] = []
		
		let allServiceProvidersValid = serviceProviders.allSatisfy { $0.isValid }
		let allZonesAreConnected = zones.allSatisfy { $0.isFullyConnected(in: network) }
		let allWorkflowsValid = workflows.allSatisfy { $0.isValid }
		
		if !allServiceProvidersValid {
			messages.append(.init(message: "Not all service providers are valid.", source: self.name))
		}
		if !allZonesAreConnected {
			messages.append(.init(message: "Not all zones are fully connected.", source: self.name))
		}
		if !allWorkflowsValid {
			messages.append(.init(message: "One or more invalid workflows.", source: self.name))
		}
		if zones.isEmpty {
			messages.append(.init(message: "No zones defined.", source: self.name))
		}
		if network.isEmpty {
			messages.append(.init(message: "No network defined.", source: self.name))
		}
		if computeNodes.isEmpty {
			messages.append(.init(message: "No compute nodes defined.", source: self.name))
		}
		if workflows.isEmpty {
			messages.append(.init(message: "No workflows configured.", source: self.name))
		}
		if services.isEmpty {
			messages.append(.init(message: "No services configured.", source: self.name))
		}
		
		return messages
	}
	
	//
	// MARK: - Zone Management
	//

	/** Creates a new zone if it doesn't already exist.
	  *  Creates a local network connection to save a step. */
	public func add(zone: Zone, localBandwidthMbps: Int, localLatencyMs: Int) -> Self {
		guard !zones.contains(zone) else { return self }
		let updatedZones = self.zones + [zone]
		let internalConnection = zone.selfConnect(bandwidthMbps: localBandwidthMbps, latencyMs: localLatencyMs)
		let updatedConnections = network + [internalConnection]
		var copy = self
		copy.zones = updatedZones
		copy.network = updatedConnections
		return copy
	}
	
	/**
	 * Removes zone from the Design. Follow on effects:
	 * - Removes any connections running to/from the zone
	 * - Removes any compute nodes in the zone
	 * - Updates the list of service providers affected by removal of compute nodes
	 * - Updates any workflows that are impacted by the change in service providers
	 * @param zone
	 * @return the altered Design
	 */
	public func remove(zone: Zone) -> Self {
		let updatedZones = zones.filter({$0 != zone})
		let updatedConnections = network.filter({$0.destination != zone && $0.source != zone})
		let updatedNodes = computeNodes.filter({$0.zone != zone})
		let updatedSPs = Design.update(serviceProviders: serviceProviders, with: updatedNodes)
		let updatedWorkflows = Design.update(workflows: workflows, with: updatedSPs)
		var copy = self
		copy.zones = updatedZones
		copy.network = updatedConnections
		copy.computeNodes = updatedNodes
		copy.serviceProviders = updatedSPs
		copy.workflows = updatedWorkflows
		return copy
	}
	
	/**
	 * Replaces a zone with another in the Design. Follow on effects:
	 * - Updates any connections running to/from the zone
	 * - Updates any compute nodes in the zone
	 * - Updates the list of service providers affected by change of compute nodes
	 * - Updates any workflows that are impacted by the change in service providers
	 * @param zone
	 * @return the altered Design
	 */
	public func replace(zone original: Zone, with replacement: Zone) -> Self {
		let updatedZones = zones.filter({ $0 != original })
		let updatedConnections = network.map({ conn in
			if conn.source == original {
				var copy = conn
				copy.source = replacement
				return copy
			}
			else if conn.destination == original {
				var copy = conn
				copy.destination = replacement
				return copy
			}
			return conn
		})
		let updatedNodes = computeNodes.map({ node in
			if node.zone == original {
				var copy = node
				copy.zone = replacement
				return copy
			}
			return node
		})
		let updatedSPs = Design.update(serviceProviders: serviceProviders, with: updatedNodes)
		let updatedWorkflows = Design.update(workflows: workflows, with: updatedSPs)
		var copy = self
		copy.zones = updatedZones
		copy.network = updatedConnections
		copy.computeNodes = updatedNodes
		copy.serviceProviders = updatedSPs
		copy.workflows = updatedWorkflows
		return copy
	}
	
	public func getZone(named name: String) -> Zone? {
		return zones.first(where: { $0.name == name })
	}
	
	//
	// MARK: - Network Management
	//
	
	/** Create a new connection if it doesn't exist.
	 *  Adds a reciprocal connection if specified.
	 *  Only alters the Design. */
	public func add(connection conn: Connection, addReciprocalConnection: Bool) -> Design {
		guard !network.contains(conn) else { return self }
		var updatedNetwork = network + [conn]
		if addReciprocalConnection {
			let reciprocalConn = conn.invert()
			if !network.contains(reciprocalConn) {
				updatedNetwork += [reciprocalConn]
			}
		}
		var copy = self
		copy.network = updatedNetwork
		return copy
	}
	
	/** Removes a connection. Only alters the Design. */
	public func remove(connection conn: Connection) -> Design {
		let updatedNetwork = network.filter({$0 != conn})
		var copy = self
		copy.network = updatedNetwork
		return copy
	}
	
	/**
	  * Replaces one connection with another. Alters the Design.
	  * @param original: the connection being replaced
	  * @param updated: the replacement connection
	  * @return The modified Design
	  */
	public func replace(connection original: Connection, with updated: Connection) -> Design {
		var updatedNetwork = network
		updatedNetwork.removeAll(where: { $0 == original })
		updatedNetwork += [updated]
		var copy = self
		copy.network = updatedNetwork
		return copy
	}
	
	
	//
	// MARK: - Physical Host/Client Management
	//
	
	/**
	 * Adds a physical host in a Zone.
	 * @param host: the physical host being added.
	 * @return The modified Design
	 */
//	public func add(host: PhysicalHost) -> Design {
//		return add(computeNode: host)
//	}
//	
//	public func add(client: Client) -> Design {
//		return add(computeNode: client)
//	}
//	
//	public func add(computeNode: ComputeNode) -> Design {
//		guard !computeNodes.contains(where: { $0.isEqualTo(computeNode) }) else { return self }
//		var copy = self
//		copy.computeNodes += [computeNode]
//		return copy
//	}
//	
//	/**
//	  * Removes a physical host from a Zone. All VMs hosted on it are removed.
//	  * Updates service providers that referenced the removed compute nodes.
//	  * Updates workflows that referenced the updated service providers
//	  * @param host: the physical host being removed.
//	  * @return The modified Design
//	  */
//	public func remove(host: PhysicalHost) -> Design {
////		var vHostsToRemove: [VirtualHost] = []
////		for vh in host.virtualHosts {
////			if let node = computeNodes.first(where: { $0.isEqualTo(vh) }) {
////				vHostsToRemove.append(vh)
////			}
////		}
//		return remove(computeNodes: [host] + host.virtualHosts)
//	}
//	
//	public func remove(client: Client) -> Design {
//		return remove(computeNodes: [client])
//	}
//	
//	func remove(computeNodes nodes: [ComputeNode]) -> Design {
//		let updatedNodes = computeNodes.filter({computeNodes.contains(where: $0.isEqualTo(computeNode)})
//		let updatedSPs = Design.update(serviceProviders: serviceProviders, with: updatedNodes)
//		let updatedWorkflows = Design.update(workflows: workflows, with: updatedSPs)
//		var copy = self
//		copy.computeNodes = updatedNodes
//		copy.serviceProviders = updatedSPs
//		copy.workflows = updatedWorkflows
//		return copy
//	}
//	
//	/**
//	 * Replaces a physical host in a Zone. All original VMs hosted on it are removed.
//	 * and replaced with new ones.
//	 * Updates service providers that referenced the removed compute nodes.
//	 * Updates workflows that referenced the updated service providers.
//	 * @param original: the original physical host
//	 * @param updated: the updated physical host
//	 * @return The modified Design
//	 */
//	public func replace(host original: PhysicalHost, with updated: PhysicalHost) -> Design {
//		var updatedNodes = computeNodes.filter({!$0.isEqualTo(original)})
//		updatedNodes.append(updated)
//	}
	

	//
	// Service Management
	//
	
	
	
	//
	// Service Provider Management
	//
	
	
	//
	// Workflow Management
	//
	
	
	
	//
	// Queues
	//
	public func provideQueues() -> [MultiQueue] {
		let queues: [MultiQueue] =
			network.map({$0.provideQueue()}) + computeNodes.map({$0.provideQueue()})
		return queues
	}
	
	//
	// Static Methods
	//

	static var _nextID: Int = 0
	static var nextID: Int {
		Design._nextID += 1
		return Design._nextID
	}
	
	static var nextName: String {
		return "Design_\(nextID)"
	}

	static func update(serviceProviders: [ServiceProvider], with newNodes: [ComputeNode]) -> [ServiceProvider] {
		serviceProviders.map({ sp in
			let updatedNodes = sp.nodes.compactMap({ n in
				newNodes.first(where: { $0.name == n.name })
			})
			var copy = sp
			copy.nodes = updatedNodes
			return copy
		})
	}
	
	static func update(workflows: [Workflow], with newServiceProviders: [ServiceProvider]) -> [Workflow] {
		workflows.map({ w in
			let uSPs = w.defaultServiceProviders.compactMap({ sp in
				newServiceProviders.first(where: { $0.name == sp.name })
			})
			var copy = w
			copy.defaultServiceProviders = Set(uSPs)
			return copy
		})
	}
}
