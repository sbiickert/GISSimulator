//
//  ComputeNodeTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-18.
//

import Testing
@testable import GISSimulator

struct ComputeNodeTest {

    @Test func create() async throws {
        let client = ComputeNodeTest.sampleClient
		#expect(client.name == "Client 001")
		#expect(client.zone == ZoneTest.sampleIntranetZone)
		
		let host = ComputeNodeTest.sampleHost
		#expect(host.name == "Host 001")
		#expect(host.hardwareDefinition.cores == 12)
		#expect(host.virtualHosts.count == 1)
		#expect(host.virtualHosts[0].vCoreCount != nil)
		#expect(host.virtualHosts[0].vCoreCount! == 4)
    }

	static private var _sampleClient: ComputeNode? = nil
	static var sampleClient: ComputeNode {
		if _sampleClient == nil {
			_sampleClient = ComputeNode(name: "Client 001",
										description: "Sample PC",
										hardwareDefinition: HardwareDefTest.sampleClientHWDef,
										zone: ZoneTest.sampleIntranetZone,
										type: .Client)
		}
		return _sampleClient!
	}

	static private var _sampleMobile: ComputeNode? = nil
	static var sampleMobile: ComputeNode {
		if _sampleMobile == nil {
			_sampleMobile = ComputeNode(name: "Mobile 001",
										description: "Sample Phone",
										hardwareDefinition: HardwareDefTest.sampleMobileHWDef,
										zone: ZoneTest.sampleInternetZone,
										type: .Client)
		}
		return _sampleMobile!
	}

	static private var _sampleVHost: ComputeNode? = nil
	static var sampleVHost: ComputeNode {
		if _sampleVHost == nil {
			_sampleVHost = ComputeNode(name: "VHost 001",
									   description: "Sample VHost",
									   hardwareDefinition: HardwareDefTest.sampleServerHWDef,
									   zone: ZoneTest.sampleIntranetZone,
									   type: .VirtualServer(vCores: 4, memoryGB: 16))
		}
		return _sampleVHost!
	}
	
	static private var _sampleHost: ComputeNode? = nil
	static var sampleHost: ComputeNode {
		if _sampleHost == nil {
			_sampleHost = ComputeNode(name: "Host 001",
									  description: "Sample Physical Host",
									  hardwareDefinition: HardwareDefTest.sampleServerHWDef,
									  zone: ZoneTest.sampleIntranetZone,
									  type: .PhysicalServer,
									  virtualHosts: [sampleVHost])
		}
		return _sampleHost!
	}
}
