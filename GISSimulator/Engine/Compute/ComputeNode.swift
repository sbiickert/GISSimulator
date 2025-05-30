//
//  ComputeNode.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public enum ComputeNodeType: Equatable, Codable {
	case Client
	case PhysicalServer
	case VirtualServer(vCores: Int)
}

public struct ComputeNode: Described, ServiceTimeCalculator, QueueProvider, Equatable, Codable {
	public var id: UUID = UUID()
	public var name: String
	public var description: String
	public var hardwareDefinition: HardwareDef
	public var memoryGB: Int
	public var zone: Zone {
		didSet {
			if type == .PhysicalServer {
				virtualHosts = virtualHosts.map {
					return $0.replacingZone(with: zone)
				}
			}
		}
	}
	public var type: ComputeNodeType
	public var virtualHosts: [ComputeNode] = []
	
	func replacingZone(with zone:Zone) -> ComputeNode {
		var copy = self
		if self.zone === zone {
			copy.zone = zone
		}
		return copy
	}
	
	public var vCoreCount: Int? {
		switch type {
		case .VirtualServer(vCores: let vCores):
			return vCores
		default:
			return nil
		}
	}
	public func adjustedServiceTime(for serviceTime: Int) -> Int {
		let relative = HardwareDef.BaselinePerCore / hardwareDefinition.specIntRate2017PerCore
		return Int(Double(serviceTime) * relative)
	}
	
	public func calculateServiceTime(for request: ClientRequest) -> Int? {
		guard request.solution.currentStep != nil else { return nil }
		return adjustedServiceTime(for: request.solution.currentStep!.serviceTime)
	}
	
	public func calculateLatency(for request: ClientRequest) -> Int? {
		return nil // No latency on a compute step
	}
	
	public func provideQueue() -> MultiQueue {
		let c: Int
		switch type {
		case .Client:
			c = 1000 // Arbitrary large number. Clients represent a group, not a PC.
		case .PhysicalServer:
			c = hardwareDefinition.cores
		case .VirtualServer(let vCores):
			c = vCores
		}
		return MultiQueue(serviceTimeCalculator: self,
						  waitMode: .Processing,
						  channelCount: c)
	}
	
	public mutating func addVirtualHost(name n: String? = nil, vCores: Int, memoryGB: Int) {
		guard type == .PhysicalServer else {
			fatalError("Can only add virtual hosts to physical servers")
		}
		let vHostName = n == nil ? "VH \(name):\(virtualHosts.count)" : n!
		let vHost = ComputeNode(name: vHostName,
								description: "",
								hardwareDefinition: hardwareDefinition,
								memoryGB: memoryGB,
								zone: zone,
								type: .VirtualServer(vCores: vCores))
		add(vHost: vHost)
	}
	
	mutating func add(vHost: ComputeNode) {
		guard vHost.type != .PhysicalServer && vHost.type != .Client else {
			fatalError("Can only add virtual hosts to physical servers")
		}
		let list = virtualHosts + [vHost]
		virtualHosts = list
	}
	
	public mutating func remove(vHost: ComputeNode) {
		let list = virtualHosts.filter { $0 != vHost }
		virtualHosts = list
	}
	
	public var totalVirtualCPUAllocation: Int {
		return virtualHosts
			.reduce(0, {$0 + ($1.vCoreCount ?? 0)})
	}
	public var totalPhysicalCPUAllocation: Int {
		Int(Double(totalVirtualCPUAllocation) * hardwareDefinition.threading.factor)
	}
	public var totalMemoryAllocation: Int {
		virtualHosts
			.reduce(0, {$0 + $1.memoryGB})
	}
}
