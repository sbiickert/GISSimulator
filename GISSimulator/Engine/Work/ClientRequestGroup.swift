//
//  ClientRequestGroup.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct ClientRequestGroup {
	private static var _nextID = 0
	static var nextID: Int {
		_nextID += 1
		return _nextID
	}
	public var id: Int = nextID
	public var requestClock: Int
	public var workflow: Workflow
	
}
