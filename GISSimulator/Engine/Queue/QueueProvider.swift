//
//  QueueProvider.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public protocol QueueProvider {
	func provideQueue() -> MultiQueue
}
