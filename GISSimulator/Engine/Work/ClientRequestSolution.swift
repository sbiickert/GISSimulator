//
//  ClientRequestSolution.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct ClientRequestSolution {
	public var steps: [ClientRequestSolutionStep]
	
	public var currentStep: ClientRequestSolutionStep? {
		steps.first
	}
	public var gotoNextStep: ClientRequestSolution {
		.init(steps: Array(steps.dropFirst()))
	}
	
	public static func createSolution(for chain: WorkflowChain, in network: [Connection]) -> ClientRequestSolution {
		guard chain.isValid else {
			fatalError("Invalid workflow chain")
		}
		// Starting at the head of the chain (client), stop at each
		// service provider, traversing the network between each
		var step = chain.steps.first!
		var sourceSP = chain.serviceProvider(for: step)!
		var handlerNode = sourceSP.handlerNode
		guard handlerNode != nil else { fatalError("No handler node for \(sourceSP)")}
		var sourceNode = handlerNode!
		
		var steps: [ClientRequestSolutionStep] = []
		steps.append(ClientRequestSolutionStep(serviceTimeCalculator: sourceNode,
											   isResponse: false,
											   dataSize: step.requestSizeKB,
											   chatter: 0, // No chatter for compute step
											   serviceTime: step.serviceTime))
		for i in 1..<chain.steps.count {
			step = chain.steps[i]
			let destSP = chain.serviceProviderForStep(at: i)!
			let handlerNode = destSP.handlerNode
			guard handlerNode != nil else { fatalError("No handler node for \(destSP)")}
			let destNode = handlerNode!
			guard let route = Route.findRoute(from: sourceNode.zone, to: destNode.zone, in: network) else {
				fatalError("Could not find route from \(sourceNode.zone.name) to \(destNode.zone.name)")
			}
			// Add the network steps
			route.connections.forEach { connection in
				steps.append(ClientRequestSolutionStep(serviceTimeCalculator: connection,
													   isResponse: false,
													   dataSize: step.requestSizeKB,
													   chatter: step.chatter,
													   serviceTime: 0)) // Service time is derived from the data size
			}
			// Add the next compute step
			steps.append(ClientRequestSolutionStep(serviceTimeCalculator: destNode,
												   isResponse: false,
												   dataSize: step.requestSizeKB,
												   chatter: 0, // No chatter for compute step
												   serviceTime: step.serviceTime))
			sourceSP = destSP
			sourceNode = destNode
		}
		
		// Now retrace back to client
		for i in (0..<chain.steps.count-1).reversed() {
			step = chain.steps[i]
			let destSP = chain.serviceProviderForStep(at: i)!
			let handlerNode = destSP.handlerNode
			guard handlerNode != nil else { fatalError("No handler node for \(destSP)")}
			let destNode = handlerNode!
			guard let route = Route.findRoute(from: sourceNode.zone, to: destNode.zone, in: network) else {
				fatalError("Could not find route from \(sourceNode.zone.name) to \(destNode.zone.name)")
			}
			// Add the network steps
			route.connections.forEach { connection in
				steps.append(ClientRequestSolutionStep(serviceTimeCalculator: connection,
													   isResponse: true,
													   dataSize: step.responseSizeKB,
													   chatter: step.chatter,
													   serviceTime: 0)) // Service time is derived from the data size
			}
			// Add the next compute step
			steps.append(ClientRequestSolutionStep(serviceTimeCalculator: destNode,
												   isResponse: true,
												   dataSize: step.responseSizeKB,
												   chatter: 0, // No chatter for compute step
												   serviceTime: step.serviceTime))
			sourceSP = destSP
			sourceNode = destNode
		}
		
		return ClientRequestSolution(steps: steps)
	}
}
