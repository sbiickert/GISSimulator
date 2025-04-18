//
//  HardwareDefTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-18.
//

import Testing
@testable import GISSimulator

struct HardwareDefTest {

    @Test func create() async throws {
		let phone = HardwareDefTest.sampleMobileHWDef
		#expect(phone.processor == "Apple Silicon M1")
		#expect(phone.cores == 8)
		#expect(phone.specIntRate2017 == 500)
		
		let client = HardwareDefTest.sampleClientHWDef
		#expect(client.processor == "Intel Core i7-4770K")
		#expect(client.cores == 4)
		#expect(client.specIntRate2017 == 20)
		
		let server = HardwareDefTest.sampleServerHWDef
		#expect(server.processor == "Intel Xeon E5-2643v3")
		#expect(server.cores == 12)
		#expect(server.specIntRate2017 == 67)
    }

	static var sampleMobileHWDef: HardwareDef {
		return HardwareDef(processor: "Apple Silicon M1", cores: 8, specIntRate2017: 500, architecture: .ARM64, threading: .Physical)
	}
	
	static var sampleClientHWDef: HardwareDef {
		return HardwareDef(processor: "Intel Core i7-4770K", cores: 4, specIntRate2017: 20, architecture: .Intel, threading: .Physical)
	}
	
	static var sampleServerHWDef: HardwareDef {
		return HardwareDef(processor: "Intel Xeon E5-2643v3", cores: 12, specIntRate2017: 67, architecture: .Intel, threading: .HyperThreaded)
	}
}
