//
//  SimulatorTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-22.
//

import Testing
@testable import GISSimulator
import Foundation

struct SimulatorTest {

    @Test func create() async throws {
        let simulator = SimulatorTest.sampleSimulator
		#expect(simulator.name == "Test Simulator")
		#expect(simulator.description == "Unit testing Simulator")
		#expect(simulator.isGeneratingNewRequests == false)
    }
	
	@Test func advancingTime() async throws {
		let simulator = SimulatorTest.sampleSimulator
		#expect(DesignTest.sampleDesign.isValid)
		simulator.design = DesignTest.sampleDesign
		#expect(simulator.nextEventTime == nil)
		simulator.start()
		#expect(simulator.isGeneratingNewRequests == true)
		#expect(simulator.nextEventTime != nil)
		simulator.advanceTimeTo(clock: simulator.nextEventTime!)
		#expect(simulator.clock > 0)
		#expect(simulator.queues.count(where: {$0.requestCount > 0}) > 0)
		
		simulator.isGeneratingNewRequests = false // Turning off for testing purposes
		#expect(simulator.nextEventTime != nil)
		#expect(simulator.nextEventTime! > simulator.clock)
		
		while (simulator.nextEventTime != nil) {
			print(simulator.clock)
			simulator.advanceTimeTo(clock: simulator.nextEventTime!)
		}
		#expect(simulator.finishedRequests.count > 0)
	}

	static var sampleSimulator: Simulator {
		return .init(name: "Test Simulator", description: "Unit testing Simulator")
	}
}
