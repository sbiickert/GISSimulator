//
//  ComputeArchitecture.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public enum ComputeArchitecture: String, CaseIterable {
	case Intel = "INTEL"
	case ARM64 = "ARM64"
	case RISCV = "RISCV"
	case Other = "OTHER"
}
