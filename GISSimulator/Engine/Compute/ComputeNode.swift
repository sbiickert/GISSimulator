//
//  ComputeNode.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public protocol ComputeNode: Described, ServiceTimeCalculator, QueueProvider {
	var hardwareDefinition: HardwareDef {get}
	var zone: Zone {get}
	func adjustedServiceTime(for serviceTime: Int) -> Int
}

func adjustedServiceTime(_ serviceTime: Int, with hardwareDef: HardwareDef) -> Int {
	let relative = HardwareDef.BaselinePerCore / hardwareDef.specIntRate2017PerCore
	return Int(Double(serviceTime) * relative)
}

public struct Client: ComputeNode {
	public var name: String
	public var description: String
	public var hardwareDefinition: HardwareDef
	public var zone: Zone
	
	public func adjustedServiceTime(for serviceTime: Int) -> Int {
		GISSimulator.adjustedServiceTime(serviceTime, with: hardwareDefinition)
	}
	
	public func calculateServiceTime(for request: ClientRequest) -> Int? {
		guard request.solution.currentStep != nil else { return nil }
		return adjustedServiceTime(for: request.solution.currentStep!.serviceTime)
	}
	
	public func calculateLatency(for request: ClientRequest) -> Int? {
		return nil // No latency on a compute step
	}
	
	public func provideQueue() -> MultiQueue {
		MultiQueue(serviceTimeCalculator: self,
				   waitMode: .Processing,
				   channelCount: 1000) // Arbitrary large number. Clients represent a group, not a PC.
	}
}

public struct PhysicalHost: ComputeNode {
	public var name: String
	public var description: String
	public var hardwareDefinition: HardwareDef
	public var zone: Zone
	public var virtualHosts: [VirtualHost] = []
	
	public func adjustedServiceTime(for serviceTime: Int) -> Int {
		GISSimulator.adjustedServiceTime(serviceTime, with: hardwareDefinition)
	}
	
	public func calculateServiceTime(for request: ClientRequest) -> Int? {
		guard request.solution.currentStep != nil else { return nil }
		return adjustedServiceTime(for: request.solution.currentStep!.serviceTime)
	}
	
	public func calculateLatency(for request: ClientRequest) -> Int? {
		return nil // No latency on a compute step
	}
	
	public func provideQueue() -> MultiQueue {
		MultiQueue(serviceTimeCalculator: self,
				   waitMode: .Processing,
				   channelCount: hardwareDefinition.cores)
	}
	
	public func add(vCores: Int, memoryGB: Int) -> PhysicalHost {
		add(vHost: VirtualHost(name: "VH \(name):\(virtualHosts.count)",
							   description: "",
							   hardwareDefinition: hardwareDefinition,
							   zone: zone,
							   vCores: vCores,
							   memoryGB: memoryGB))
	}
	
	public func add(vHost: VirtualHost) -> PhysicalHost {
		let list = virtualHosts + [vHost]
		var copy = self
		copy.virtualHosts = list
		return copy
	}
	
	public func remove(vHost: VirtualHost) -> PhysicalHost {
		let list = virtualHosts.filter { $0 != vHost }
		var copy = self
		copy.virtualHosts = list
		return copy
	}
	
	public func migrate(vHost: VirtualHost, to newHost: PhysicalHost) -> (PhysicalHost, PhysicalHost) {
		let selfCopy = self.remove(vHost: vHost)
		let newHostCopy = newHost.add(vHost: vHost)
		return (selfCopy, newHostCopy)
	}
	
	public var totalVirtualCPUAllocation: Int {
		virtualHosts.reduce(0) { $0 + $1.vCores }
	}
	public var totalPhysicalCPUAllocation: Int {
		Int(Double(totalVirtualCPUAllocation) * hardwareDefinition.threading.factor)
	}
}

public struct VirtualHost: ComputeNode, Equatable {
	public var name: String
	public var description: String
	public var hardwareDefinition: HardwareDef
	public var zone: Zone
	public var vCores: Int
	public var memoryGB: Int
	
	public func adjustedServiceTime(for serviceTime: Int) -> Int {
		GISSimulator.adjustedServiceTime(serviceTime, with: hardwareDefinition)
	}
	
	
	public func calculateServiceTime(for request: ClientRequest) -> Int? {
		guard request.solution.currentStep != nil else { return nil }
		return adjustedServiceTime(for: request.solution.currentStep!.serviceTime)
	}
	
	public func calculateLatency(for request: ClientRequest) -> Int? {
		return nil // No latency on a compute step
	}
	
	public func provideQueue() -> MultiQueue {
		MultiQueue(serviceTimeCalculator: self,
				   waitMode: .Processing,
				   channelCount: vCores)
	}
}
