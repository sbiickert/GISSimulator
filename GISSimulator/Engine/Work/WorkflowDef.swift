//
//  WorkflowDef.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct WorkflowDef: Described {
	public var name: String
	public var description: String
	public var thinkTimeSeconds: Int
	public var chains: [WorkflowChain]
	
	public func add(chain: WorkflowChain) -> WorkflowDef {
		var copy = self
		copy.chains = [chain] + chains
		return copy
	}
	
	public func removeChain(at index: Int) -> WorkflowDef {
		guard index >= 0 && index < chains.count else {
			fatalError("Invalid index \(index)")
		}
		var copy = self
		copy.chains.remove(at: index)
		return copy
	}
	
	public var allRequiredServiceTypes: Set<String> {
		return Set(chains.flatMap(\.allRequiredServiceTypes))
	}
	
	public func updateServiceProviders(at index: Int, serviceProviders: Set<ServiceProvider>) -> WorkflowDef {
		guard index >= 0 && index < chains.count else {
			fatalError()
		}
		var copy = self
		copy.chains[index].serviceProviders = serviceProviders
		return copy
	}
}
