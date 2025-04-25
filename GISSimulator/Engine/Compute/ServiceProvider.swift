//
//  ServiceProvider.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct ServiceProvider: Described, Validatable, Hashable, Codable {
	public var name: String
	public var description: String
	public var service: ServiceDef
	public var nodes: [ComputeNode]

	var _primary = 0
	public var primary: Int {
		get {
			switch service.balancingModel {
			case .Single, .RoundRobin:
				return 0
			default:
				return _primary
			}
		}
		set {
			_primary = newValue
		}
	}
	
	public init(name: String, description: String, service: ServiceDef, nodes: [ComputeNode], primaryIndex: Int = 0) {
		self.name = name
		self.description = description
		self.service = service
		self.nodes = nodes
		self.primary = primaryIndex
	}
	
	var handlerNode: ComputeNode? {
		guard !nodes.isEmpty else { return nil }
		guard primary >= 0 && primary < nodes.count else { return nil }
		
		switch service.balancingModel {
		case .Single, .Failover, .Other, .Containerized:
			return nodes[primary]
		case .RoundRobin:
			let i = Int.random(in: 0..<nodes.count)
			return nodes[i]
		}
	}
	
	public mutating func addNode(_ node: ComputeNode) {
		guard service.balancingModel == .Single && nodes.isEmpty else { return }
		guard service.balancingModel == .Failover && nodes.count < 2 else { return }
		nodes = nodes + [node]
	}
	
	public mutating func removeNode(_ node: ComputeNode) {
		nodes = nodes.filter { $0 != node }
	}
	
	public var isValid: Bool {
		validate().isEmpty
	}
	
	public func validate() -> [ValidationMessage] {
		var messages: [ValidationMessage] = []
		if service.balancingModel == .Single && handlerNode == nil {
			messages.append(ValidationMessage(message: "Service Provider with single balancing model must have a primary node", source: name))
		}
		if service.balancingModel == .Failover && handlerNode == nil {
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
