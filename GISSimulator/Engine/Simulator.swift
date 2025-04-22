//
//  Simulator.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-22.
//

import Foundation

public class Simulator: Described {
	public var name: String
	public var description: String
	public var design: Design = Design(name: Design.nextName, description: "")
	
	var clock: Int = 0
	var isGeneratingNewRequests: Bool = false
	var finishedRequests: [ClientRequest] = []
	var queues: [MultiQueue] = []
	var nextEventTimeForWorkflows: [String:Int] = [:]
	var metrics: [PerformanceMetric] = []
	
	public init(name: String, description: String) {
		self.name = name
		self.description = description
	}
	
	public func start() {
		guard design.isValid else {
			isGeneratingNewRequests = false
			print("Invalid design. Cannot start simulation.")
			return
		}
		reset()
		isGeneratingNewRequests = true
		for wf in design.workflows {
			nextEventTimeForWorkflows[wf.name] = wf.calculateNextEventTime(clock: clock)
		}
	}
	
	public func stop() {
		isGeneratingNewRequests = false
		// TODO: Summarize
	}
	
	private func reset() {
		clock = 0
		finishedRequests.removeAll()
		nextEventTimeForWorkflows.removeAll()
		metrics.removeAll()
		queues = design.provideQueues()
	}
	
	var nextEventTime: Int? {
		return [nextWFEventTime, nextQEventTime]
			.compactMap({$0})
			.min()
	}
	
	private var nextWFEventTime: Int? {
		guard isGeneratingNewRequests else { return nil }
		return nextEventTimeForWorkflows.values
			.min()
	}
	
	private var nextQEventTime: Int? {
		let tempTimes = queues.map(\.nextEventTime)
		return queues.compactMap(\.nextEventTime)
			.min()
	}
	
	private var nextWorkflow: Workflow? {
		if let nameTime = nextEventTimeForWorkflows.min(by: {$0.value < $1.value}) {
			return design.getWorkflow(named: nameTime.key)
		}
		return nil
	}
	
	private var nextQueue: MultiQueue? {
		return queues.filter({$0.nextEventTime != nil})
			.min(by: {$0.nextEventTime! < $1.nextEventTime!})
	}
	
	@discardableResult
	func advanceTimeBy(milliseconds: Int) -> Int {
		guard milliseconds >= 0 else {
			fatalError("Cannot advance time by negative \(milliseconds) milliseconds.")
		}
		return advanceTimeTo(clock: clock + milliseconds)
	}
	
	@discardableResult
	func advanceTimeTo(clock newClock: Int) -> Int {
		guard newClock > clock else {
			fatalError("Cannot advance time from \(clock) to \(newClock). Time must progress forward.")
		}
		
		while nextEventTime != nil && nextEventTime! <= newClock {
			doTheNextTask()
		}
		
		clock = newClock
		return clock
	}
	
	private func doTheNextTask() {
		let wfTime = nextWFEventTime ?? Int.max
		let qTime = nextQEventTime ?? Int.max
		let now = [wfTime, qTime].min()!
		
		var requests: [ClientRequest]
		if wfTime < qTime {
			let workflow = nextWorkflow!
			nextEventTimeForWorkflows[workflow.name] = workflow.calculateNextEventTime(clock: now)
			let (group, r) = workflow.createClientRequests(network: design.network, clock: now)
			requests = r
		} else {
			let queue = nextQueue
			let requestsAndMetrics = queue!.removeFinishedRequests(clock: now)
			requests = requestsAndMetrics.map({ r, m in
				self.metrics.append(m)
				var request = r
				request.solution.gotoNextStep()
				return request
			})
		}
		
		// Move requests on to their next step
		for req in requests {
			if req.isFinished {
				finishedRequests.append(req)
			}
			else {
				let stCalc = req.solution.currentStep!.serviceTimeCalculator
				if let queue = findQueue(with: stCalc) {
					queue.enqueue(request: req, clock: now)
				}
				else {
					let stCalcName = (stCalc as! Described).name
					fatalError("Could not find queue with calculator named \(stCalcName)")
				}
			}
		}
	}
	
	private func findQueue(with stCalc: ServiceTimeCalculator) -> MultiQueue? {
		let stCalcName = (stCalc as! Described).name
		return queues
			.first(where: { q in
				return (q.name  == stCalcName)
			})
	}
	
	var activeRequests: [WaitingRequest] {
		var result: [WaitingRequest] = []
		for q in queues {
			result.append(contentsOf: q.allWaitingRequests)
		}
		return result
	}
}
