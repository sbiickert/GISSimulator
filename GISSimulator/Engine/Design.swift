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
	public var services: Dictionary<String, Service> = [:]
	public var serviceProviders: [ServiceProvider] = []
	public var workflows: [Workflow] = []
	
	var _computeNodes: [ComputeNode] = []
	
	/**
	 Returns all clients, physical servers and virtual servers on physical hosts
	 */
	public var computeNodes: [ComputeNode] {
		get {
			let allNodes: [[ComputeNode]] = _computeNodes.map({ node in
				switch node.type {
				case .Client:
					return [node]
				case .PhysicalServer:
					return [node] + node.virtualHosts
				case .VirtualServer(_, _):
					fatalError("Virtual servers should not be in the Design's _computeNodes. They are in Physical Servers.")
				}
			})
			return allNodes.flatMap { $0 }
		}
		set {
			_computeNodes = newValue.filter({$0.type == .Client || $0.type == .PhysicalServer})
		}
	}

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

	mutating func updateServiceProvidersWithNewComputeNodes() {
		serviceProviders = serviceProviders.map({ sp in
			let updatedNodes = sp.nodes.compactMap({ n in
				computeNodes.first(where: { $0.name == n.name })
			})
			var copy = sp
			copy.nodes = updatedNodes
			return copy
		})
	}

	mutating func updateWorkflowsWithNewServiceProviders() {
		workflows = workflows.map({ w in
			let uSPs = w.defaultServiceProviders.compactMap({ sp in
				serviceProviders.first(where: { $0.name == sp.name })
			})
			var copy = w
			copy.defaultServiceProviders = Set(uSPs)
			return copy
		})
	}

	//
	// MARK: - Zone Management
	//

	/** Creates a new zone if it doesn't already exist.
	  *  Creates a local network connection to save a step. */
	public mutating func add(zone: Zone, localBandwidthMbps: Int, localLatencyMs: Int) {
		guard !zones.contains(zone) else { return }
		zones = zones + [zone]
		let internalConnection = zone.selfConnect(bandwidthMbps: localBandwidthMbps, latencyMs: localLatencyMs)
		network = network + [internalConnection]
	}
	
	/**
	 * Removes zone from the Design. Follow on effects:
	 * - Removes any connections running to/from the zone
	 * - Removes any compute nodes in the zone
	 * - Updates the list of service providers affected by removal of compute nodes
	 * - Updates any workflows that are impacted by the change in service providers
	 * @param zone
	 */
	public mutating func remove(zone: Zone) {
		zones = zones.filter({$0 != zone})
		network = network.filter({$0.destination != zone && $0.source != zone})
		computeNodes = computeNodes.filter({$0.zone != zone})
		updateServiceProvidersWithNewComputeNodes()
		updateWorkflowsWithNewServiceProviders()
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
	public mutating func add(connection conn: Connection, addReciprocalConnection: Bool) {
		guard !network.contains(conn) else { return }
		var updatedNetwork = network + [conn]
		if addReciprocalConnection {
			let reciprocalConn = conn.invert()
			if !network.contains(reciprocalConn) {
				updatedNetwork += [reciprocalConn]
			}
		}
		network = updatedNetwork
	}
	
	/** Removes a connection. Only alters the Design. */
	public mutating func remove(connection conn: Connection) {
		network = network.filter({$0 != conn})
	}
	
	
	//
	// MARK: - Physical Host/Client Management
	//
	
	/**
	 * Adds a physical compute node in a Zone.
	 * @param computeNode: the physical compute node being added.
	 */
	public mutating func add(computeNode: ComputeNode) {
		guard computeNode.type == .Client || computeNode.type == .PhysicalServer else {
			fatalError("Cannot add virtual server to Design directly. Add it to a physical server.")
		}
		guard !computeNodes.contains(computeNode) else { return }
		computeNodes = computeNodes + [computeNode]
	}
	
	/**
	  * Removes a physical host from the Design. All VMs hosted on it are removed.
	  * Updates service providers that referenced the removed compute nodes.
	  * Updates workflows that referenced the updated service providers
	  * @param host: the physical host being removed.
	  */
	public mutating func remove(computeNode node: ComputeNode) {
		guard node.type == .Client || node.type == .PhysicalServer else {
			fatalError("Cannot remove virtual server from Design directly. Add it to a physical server.")
		}
		computeNodes = computeNodes.filter({$0 != node})
		updateServiceProvidersWithNewComputeNodes()
		updateWorkflowsWithNewServiceProviders()
	}
	
	public func getComputeNode(named name: String) -> ComputeNode? {
		return computeNodes.first(where: { $0.name == name })
	}
	

	//
	// MARK: - Service Management
	//
	
	public mutating func add(service: Service) {
		services[service.serviceType] = service
	}
	
	public mutating func remove(service: Service) {
		services.removeValue(forKey: service.serviceType)
		serviceProviders = serviceProviders.filter({$0.service != service})
		updateWorkflowsWithNewServiceProviders()
	}
	
	
	//
	// MARK: - Service Provider Management
	//
	
	public mutating func add(serviceProvider: ServiceProvider) {
		guard !serviceProviders.contains(serviceProvider) else { return }
		serviceProviders = serviceProviders + [serviceProvider]
	}
	
	public mutating func remove(serviceProvider: ServiceProvider) {
		serviceProviders = serviceProviders.filter({$0 != serviceProvider})
		updateWorkflowsWithNewServiceProviders()
	}
	
	
	//
	// MARK: - Workflow Management
	//
	
	public mutating func add(workflow: Workflow) {
		guard !workflows.contains(workflow) else { return }
		workflows = workflows + [workflow]
	}
	
	public mutating func remove(workflow: Workflow) {
		workflows = workflows.filter({$0 != workflow})
	}
	
	
	//
	// MARK: - Queues
	//
	public func provideQueues() -> [MultiQueue] {
		let queues: [MultiQueue] =
			network.map({$0.provideQueue()}) + computeNodes.map({$0.provideQueue()})
		return queues
	}
	
	//
	// MARK: - Static Methods
	//

	static var _nextID: Int = 0
	static var nextID: Int {
		Design._nextID += 1
		return Design._nextID
	}
	
	static var nextName: String {
		return "Design_\(nextID)"
	}
}
