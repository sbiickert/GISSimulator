//
//  MultiQueueTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-18.
//

import Testing
@testable import GISSimulator

struct MultiQueueTest {
	
	@Test func create() async throws {
		let connQ = MultiQueueTest.sampleConnectionQ
		#expect(connQ.serviceTimeCalculator is Connection)
		#expect(connQ.serviceTimeCalculator as! Connection == ConnectionTest.sampleConnectionToInternet)
		
		let vmQ = MultiQueueTest.sampleComputeQ
		#expect(vmQ.serviceTimeCalculator is VirtualHost)
		#expect(vmQ.serviceTimeCalculator as! VirtualHost == ComputeNodeTest.sampleVHost)
		#expect(vmQ.channelCount == ComputeNodeTest.sampleVHost.vCores)
	}
	
	@Test func networkEnqueue() async throws {
		// A single channel. All requests will queue up in order of arrival.
		let connQ = MultiQueueTest.sampleConnectionQ
		connQ.enqueue(request: MultiQueueTest.sampleConnectionCR, clock: 13)
		#expect(connQ.requestCount == 1)
		#expect(connQ.availableChannelCount == 0)
		// 13 ms + 160 ms ST + 100 ms latency
		#expect(connQ.nextEventTime != nil)
		#expect(connQ.nextEventTime! == 13 + 160 + 100)
		
		// Yes, I know it's the same request. Just looking at queueing.
		connQ.enqueue(request: MultiQueueTest.sampleConnectionCR, clock: 15)
		connQ.enqueue(request: MultiQueueTest.sampleConnectionCR, clock: 16)
		#expect(connQ.requestCount == 3)
		#expect(connQ.nextEventTime == 273)
		
		var finished = connQ.removeFinishedRequests(clock: 273)
		#expect(finished.count == 1)
		#expect(connQ.requestCount == 2)
		#expect(connQ.availableChannelCount == 0)
		#expect(finished[0].1.queueTime == 0)
		#expect(finished[0].1.serviceTime == 160)
		#expect(finished[0].1.latencyTime == 100)
		
		#expect(connQ.nextEventTime == 273 + 260)
		finished = connQ.removeFinishedRequests(clock: 273 + 260)
		#expect(finished.count == 1)
		#expect(connQ.requestCount == 1)
		#expect(connQ.availableChannelCount == 0)
		#expect(finished[0].1.queueTime == 260 - (15 - 13)) // Arrived 2 ms after first request started transmitting
		#expect(finished[0].1.serviceTime == 160)
		#expect(finished[0].1.latencyTime == 100)
	}
	
	@Test func computeEnqueue() async throws {
		let computeQ = MultiQueueTest.sampleComputeQ
		computeQ.enqueue(request: MultiQueueTest.sampleComputeCR, clock: 13)
		#expect(computeQ.requestCount == 1)
		#expect(computeQ.availableChannelCount == 3) // 4 vCores - 1 busy
		let st = 505 // (141 ms then adjusted for the slow hardware and hyperthreading)
		#expect(computeQ.nextEventTime == 13 + st)
		
		computeQ.enqueue(request: MultiQueueTest.sampleComputeCR, clock: 23)
		computeQ.enqueue(request: MultiQueueTest.sampleComputeCR, clock: 33)
		#expect(computeQ.requestCount == 3)
		#expect(computeQ.availableChannelCount == 1) // 4 vCores - 3 busy
		
		computeQ.enqueue(request: MultiQueueTest.sampleComputeCR, clock: 43)
		computeQ.enqueue(request: MultiQueueTest.sampleComputeCR, clock: 53)
		#expect(computeQ.requestCount == 5)
		#expect(computeQ.availableChannelCount == 0) // 4 vCores - 4 busy
		
		var finished = computeQ.removeFinishedRequests(clock: 13 + st)
		#expect(finished.count == 1)
		#expect(computeQ.requestCount == 4)
		#expect(computeQ.availableChannelCount == 0) // 4 vCores - 4 busy
		#expect(finished[0].1.queueTime == 0)
		#expect(finished[0].1.serviceTime == st)
		#expect(finished[0].1.latencyTime == 0) // No latency for compute

		finished = computeQ.removeFinishedRequests(clock: 23 + st)
		#expect(finished.count == 1)
		#expect(computeQ.requestCount == 3)
		#expect(computeQ.availableChannelCount == 1) // 4 vCores - 3 busy
		#expect(finished[0].1.queueTime == 0)
		#expect(finished[0].1.serviceTime == st)

		finished = computeQ.removeFinishedRequests(clock: 33 + st)
		finished = computeQ.removeFinishedRequests(clock: 43 + st)
		#expect(computeQ.requestCount == 1)
		#expect(computeQ.availableChannelCount == 3) // 4 vCores - 1 busy

		// Was queueing until the first request finished
		#expect(computeQ.nextEventTime == 13 + st + st)
		finished = computeQ.removeFinishedRequests(clock: 13 + st + st)
		#expect(finished.count == 1)
		#expect(computeQ.requestCount == 0)
		#expect(computeQ.availableChannelCount == 4)
		#expect(finished[0].1.queueTime == st - (53 - 13))
		#expect(finished[0].1.serviceTime == st)
	}
	
	static var sampleConnectionQ: MultiQueue {
		let conn = ConnectionTest.sampleConnectionToInternet
		return MultiQueue(serviceTimeCalculator: conn, waitMode: .Transmitting, channelCount: 1)
	}
	
	static var sampleComputeQ: MultiQueue {
		let vm = ComputeNodeTest.sampleVHost
		return MultiQueue(serviceTimeCalculator: vm, waitMode: .Processing, channelCount: vm.vCores)
	}
	
	static var sampleConnectionCR: ClientRequest {
		let step = ClientRequestSolutionStep(serviceTimeCalculator: sampleConnectionQ.serviceTimeCalculator,
											 isResponse: true,
											 dataSize: 2000, chatter: 10, serviceTime: 0)
		let solution = ClientRequestSolution(steps: [step])
		return ClientRequest(name: ClientRequest.nextName, description: "", requestClock: 10,
							 solution: solution, groupID: ClientRequestGroup.nextID)
	}
	
	static var sampleComputeCR: ClientRequest {
		let step = ClientRequestSolutionStep(serviceTimeCalculator: sampleComputeQ.serviceTimeCalculator,
											 isResponse: true,
											 dataSize: 2000, chatter: 0, serviceTime: 141)
		let solution = ClientRequestSolution(steps: [step])
		return ClientRequest(name: ClientRequest.nextName, description: "", requestClock: 10,
							 solution: solution, groupID: ClientRequestGroup.nextID)
	}

}
