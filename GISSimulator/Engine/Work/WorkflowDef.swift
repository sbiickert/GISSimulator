//
//  WorkflowDef.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct WorkflowDef: Described, Codable {
	public var name: String
	public var description: String
	public var thinkTimeSeconds: Int
	public var chains: [WorkflowChain]
	
	public mutating func add(chain: WorkflowChain) {
		chains = [chain] + chains
	}
	
	public mutating func removeChain(at index: Int) {
		guard index >= 0 && index < chains.count else {
			fatalError("Invalid index \(index)")
		}
		chains.remove(at: index)
	}
	
	public var allRequiredServiceTypes: Set<String> {
		return Set(chains.flatMap(\.allRequiredServiceTypes))
	}
	
	public mutating func updateServiceProviders(at index: Int, serviceProviders: Set<ServiceProvider>) {
		guard index >= 0 && index < chains.count else {
			fatalError()
		}
		chains[index].serviceProviders = serviceProviders
	}
}
