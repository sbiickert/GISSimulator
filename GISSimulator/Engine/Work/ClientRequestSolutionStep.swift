//
//  ClientRequestSolutionStep.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public struct ClientRequestSolutionStep {
	var serviceTimeCalculator: ServiceTimeCalculator
	var isResponse: Bool
	var dataSize: Int
	var chatter: Int
	var serviceTime: Int
}
