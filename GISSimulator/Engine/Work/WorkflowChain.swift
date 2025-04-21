//
//  WorkflowChain.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct WorkflowChain: Described, Validatable {
	public var name: String
	public var description: String
	public var steps: [WorkflowDefStep]
	public var serviceProviders: Set<ServiceProvider>
	
	public init(name: String, description: String, steps: [WorkflowDefStep], serviceProviders: Set<ServiceProvider>,
				addClient cWDS: WorkflowDefStep? = nil) {
		self.name = name
		self.description = description
		if let cWDS = cWDS {
			self.steps = [cWDS] + steps
		}
		else {
			self.steps = steps
		}
		self.serviceProviders = serviceProviders
	}
	public var isValid: Bool {
		validate().isEmpty
	}
	
	public func validate() -> [ValidationMessage] {
		var messages: [ValidationMessage] = []
		
		if hasDuplicateServiceProviders {
			messages.append(ValidationMessage(message: "Duplicate service providers found", source: name))
		}
		if missingServiceProviders.isEmpty == false {
			messages.append(contentsOf: missingServiceProviders.map({
				ValidationMessage(message: "Missing service provider for \($0)", source: name)
			}))
		}
		
		return messages
	}
	
	public mutating func set(clientStep cWDS: WorkflowDefStep) {
		steps.insert(cWDS, at: 0)
	}
	
	public mutating func update(clientStep cWDS: WorkflowDefStep) {
		steps.removeFirst()
		set(clientStep: cWDS)
	}
	
	public var allRequiredServiceTypes: Set<String> {
		return Set(steps.map({ $0.serviceType }))
	}
	
	public var missingServiceProviders: [String] {
		let allRequired = allRequiredServiceTypes
		let configured = Set(serviceProviders.map({$0.service.serviceType}))
		return Array(allRequired.subtracting(configured))
	}
	
	private var hasDuplicateServiceProviders: Bool {
		let configuredServiceTypes = Set(serviceProviders.map({$0.service.serviceType}))
		return configuredServiceTypes.count != serviceProviders.count
	}
	
	public func serviceProviderForStep(at index:Int) -> ServiceProvider? {
		guard index >= 0 && index < steps.count else {
			fatalError()
		}
		return serviceProviders.first(where: { $0.service.serviceType == steps[index].serviceType })
	}
	
	public func serviceProvider(for step: WorkflowDefStep) -> ServiceProvider? {
		return serviceProviders.first(where: { $0.service.serviceType == step.serviceType})
	}
}
