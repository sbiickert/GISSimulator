//
//  ServiceProvider.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct ServiceProvider: Described, Validatable, Hashable {
	public var name: String
	public var description: String
	public var service: Service
	public var primary: (any ComputeNode)?
	public var nodes: [ComputeNode]
	
	var handlerNode: ComputeNode {
		switch service.balancingModel {
		case .Single, .Failover:
			return primary!
		case .RoundRobin:
			let i = Int.random(in: 0..<nodes.count)
			return nodes[i]
		default:
			return nodes.first!
		}
	}
	
	func addNode(_ node: ComputeNode) -> ServiceProvider {
		var copy = self
		if service.balancingModel == .Single && !nodes.isEmpty {
			return self
		}
		else if service.balancingModel == .Failover && nodes.count >= 2 {
			return self
		}
		copy.nodes = copy.nodes + [node]
		return copy
	}
	
	func removeNode(_ node: ComputeNode) -> ServiceProvider {
		var copy = self
		copy.nodes = copy.nodes.filter { $0.name != node.name }
		return copy
	}
	
	public var isValid: Bool {
		validate().isEmpty
	}
	
	public func validate() -> [ValidationMessage] {
		var messages: [ValidationMessage] = []
		if service.balancingModel == .Single && primary == nil {
			messages.append(ValidationMessage(message: "Service Provider with single balancing model must have a primary node", source: name))
		}
		if service.balancingModel == .Failover && primary == nil {
			messages.append(ValidationMessage(message: "Service Provider with failover balancing model must have a primary node", source: name))
		}
		if nodes.isEmpty {
			messages.append(ValidationMessage(message: "Service Provider must have at least one node", source: name))
		}
		return messages
	}
	
	public static func == (lhs: ServiceProvider, rhs: ServiceProvider) -> Bool {
		return lhs.name == rhs.name && lhs.service == rhs.service
	}
	public func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(service)
	}
}
