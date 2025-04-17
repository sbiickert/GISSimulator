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
	
	var waitEnd: Int? {
		if waitMode == .Queueing || serviceTime == nil {
			return nil
		}
		return waitStart + serviceTime! + (latency ?? 0)
	}
}
