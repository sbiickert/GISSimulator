//
//  ComputeArchitecture.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public enum ComputeArchitecture: String, CaseIterable, Codable {
	case Intel = "INTEL"
	case ARM64 = "ARM64"
	case RISCV = "RISCV"
	case Other = "OTHER"
	
	static func from(_ string: String) -> ComputeArchitecture {
		switch string.uppercased() {
		case Intel.rawValue: return .Intel
		case ARM64.rawValue: return .ARM64
		case RISCV.rawValue: return .RISCV
		case "AARM64", "ARMV7": return .ARM64
		default: return .Other
		}
	}
}
