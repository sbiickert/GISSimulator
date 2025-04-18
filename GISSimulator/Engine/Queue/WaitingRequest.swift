//
//  WaitingRequest.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct WaitingRequest: Equatable {
	public var request: ClientRequest
	public var waitStart: Int
	public var serviceTime: Int?
	public var latency: Int?
	public var waitMode: WaitMode
	public var queueTime: Int = 0
	
	public mutating func queueEnded(at clock: Int, waitMode: WaitMode) {
		self.waitMode = waitMode
		self.queueTime = clock - waitStart
	}
	
	var waitEnd: Int? {
		if waitMode == .Queueing || serviceTime == nil {
			return nil
		}
		return waitStart + serviceTime! + (latency ?? 0) + queueTime
	}
}
