//
//  BalancingModel.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public enum BalancingModel: String, CaseIterable, Codable {
	case Single = "1"
	case RoundRobin = "ROUNDROBIN"
	case Failover = "FAILOVER"
	case Containerized = "CONTAINERIZED"
	case Other = "OTHER"
}
