//
//  Workflow.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation
import GameplayKit

public enum WorkflowType: String, CaseIterable, Codable {
	case User = "User"
	case Transactional = "Transactional"
}

public struct Workflow: Described, Validatable, Equatable, Codable {
	public static func == (lhs: Workflow, rhs: Workflow) -> Bool {
		return lhs.name == rhs.name && lhs.description == rhs.description && lhs.type == rhs.type
	}
	
	public var name: String
	public var description: String
	public var type: WorkflowType
	public var definition: WorkflowDef
	public var defaultServiceProviders: Set<ServiceProvider>
	public var userCount = 0
	public var productivity = 0
	public var tph = 0
	
	public var transactionRate: Int {
		switch type {
		case .User:
			userCount * productivity * 60
		case .Transactional:
			tph
		}
	}
	
	public var missingServiceProviders: [String] {
		let allRequiredServiceTypes = definition.allRequiredServiceTypes
		let allConfigured = Set(defaultServiceProviders.map(\.service.serviceType))
		return Array(allRequiredServiceTypes.subtracting(allConfigured)).sorted()
	}
	
	public mutating func applyDefaultServiceProviders() {
		let updatedChains = definition.chains.map({
			var chainCopy = $0
			chainCopy.serviceProviders = defaultServiceProviders
			return chainCopy
		})
		definition.chains = updatedChains
	}
	
	public mutating func updateServiceProviders(at index: Int, serviceProviders: Set<ServiceProvider>) {
		definition.updateServiceProviders(at: index, serviceProviders: serviceProviders)
	}
	
	public func createClientRequests(network: [Connection], clock: Int) -> (ClientRequestGroup, [ClientRequest]) {
		let group = ClientRequestGroup(requestClock: clock, workflow: self)
		let requests = definition.chains.map( {
			let solution = ClientRequestSolution.createSolution(for: $0, in: network)
			return ClientRequest(name: ClientRequest.nextName, description: "", requestClock: clock, solution: solution, groupID: group.id)
		})
		return (group, requests)
	}
	
	var _random: GKRandomSource {
		GKRandomSource()
	}
	
	public func calculateNextEventTime(clock: Int) -> Int {
		// transactionRate is transactions per hour
		// time between events in ms is
		let msPerEvent = 3600000 / Float(transactionRate)
		let distribution = GKGaussianDistribution(randomSource: _random, mean: msPerEvent, deviation: msPerEvent * 0.25)
		return distribution.nextInt() + clock
	}
	
	public var isValid: Bool {
		validate().isEmpty
	}
	
	public func validate() -> [ValidationMessage] {
		var messages: [ValidationMessage] = []
		
		if definition.chains.isEmpty {
			messages.append(ValidationMessage(message: "Need at least one configured Workflow Chain", source: name))
		}
		let invalidChains = definition.chains.filter({$0.isValid == false})
		for chain in invalidChains {
			messages.append(ValidationMessage(message: "Workflow chain is invalid", source: chain.name))
		}
		if transactionRate <= 0 {
			messages.append(ValidationMessage(message: "Transaction rate must be greater or equal to zero", source: name))
		}
		
		return messages
	}
	
	
}
