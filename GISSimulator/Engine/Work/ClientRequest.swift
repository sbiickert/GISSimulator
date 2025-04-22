//
//  ClientRequest.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct ClientRequest: Described, Equatable {
	private static var _nextID = 0
	static var nextID: Int {
		_nextID += 1
		return _nextID
	}
	static var nextName: String {
		"CR-\(nextID)"
	}
	
	public var name: String
	public var description: String
	public var requestClock: Int
	public var solution: ClientRequestSolution
	public var groupID: Int
	public var isFinished: Bool {
		solution.isFinished
	}
	
	public static func == (lhs: ClientRequest, rhs: ClientRequest) -> Bool {
		return lhs.name == rhs.name
	}
}
