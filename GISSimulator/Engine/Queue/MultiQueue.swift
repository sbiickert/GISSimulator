//
//  MultiQueue.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public class MultiQueue {
	var serviceTimeCalculator: ServiceTimeCalculator
	var waitMode: WaitMode
	var channels: [WaitingRequest?] // parallel, concurrent requests being worked on
	var mainQueue: [WaitingRequest] // serial, requests waiting for a channel
	
	public init(serviceTimeCalculator: ServiceTimeCalculator, waitMode: WaitMode, channelCount: Int) {
		self.serviceTimeCalculator = serviceTimeCalculator
		self.waitMode = waitMode
		self.channels = Array(repeating: nil, count: channelCount)
		self.mainQueue = []
	}
	
	public var name: String {
		return (serviceTimeCalculator as? Described)?.name ?? ""
	}
	
	public var channelCount: Int {
		return channels.count
	}
	
	public var availableChannelCount: Int {
		return channels.count(where: {$0 == nil})
	}
	
	private var firstAvailableChannelIndex: Int? {
		return channels.firstIndex(of: nil)
	}
	
	private func channelsWithFinishedRequests(clock: Int) -> [Int] {
		return channels.enumerated().filter {($0.1?.waitEnd ?? 0) < clock}.map(\.0)
	}
	
	public var requestCount: Int {
		return mainQueue.count + channels.count(where: {$0 != nil})
	}
	
	public var nextEventTime: Int? {
		return channels.compactMap({$0?.waitEnd}).sorted().first
	}
	
	public func removeFinishedRequests(clock: Int) -> [(ClientRequest, RequestMetric)] {
		let finishedChannelIndices = self.channelsWithFinishedRequests(clock: clock)
		var finishedRequests: [(ClientRequest, RequestMetric)] = []
		
		// Move finished requests out of channels
		for index in finishedChannelIndices {
			guard let wr = self.channels[index] else { continue }
			finishedRequests.append((
				wr.request,
				RequestMetric(sourceName: name,
							  clock: clock,
							  requestName: wr.request.name,
							  serviceTime: wr.serviceTime ?? 0,
							  queueTime: clock - wr.waitStart - (wr.serviceTime ?? 0) - (wr.latency ?? 0),
							  latencyTime: wr.latency ?? 0)
			))
			
			// Move a waiting request into the empty channel
			self.channels[index] = mainQueue.isEmpty ? nil : self.mainQueue.removeFirst()
		}
		
		return finishedRequests
	}
	
	public func enqueue(request: ClientRequest, clock: Int) {
		guard let step = request.solution.currentStep else { return }
		
		let st = serviceTimeCalculator.calculateServiceTime(for: request)
		let lat = serviceTimeCalculator.calculateLatency(for: request)
		
		if let index = firstAvailableChannelIndex {
			let wr = WaitingRequest(request: request, waitStart: clock, serviceTime: st, latency: lat, waitMode: waitMode)
			channels[index] = wr
		}
		else {
			mainQueue.append(WaitingRequest(request: request, waitStart: clock, serviceTime: st, latency: lat, waitMode: .Queueing))
		}
	}
	
	public var allWaitingRequests: [WaitingRequest] {
		return channels.compactMap({$0}) + mainQueue
	}
	
	public func getPerformanceMetric(clock: Int) -> PerformanceMetric {
		return QueueMetric(sourceName: name, clock: clock, channelCount: channelCount, requestCount: requestCount)
	}
}
