//
//  WorkflowDefLib.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-23.
//

import Foundation

struct WorkflowDefLib {
	var date: Date = Date()
	var baselineSpecPerCore: Double = -1.0
	var steps: [String: WorkflowDefStep] = [:]
	var chains: [String: WorkflowChain] = [:]
	var workflows: [String: WorkflowDef] = [:]
}
