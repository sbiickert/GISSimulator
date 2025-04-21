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

	static var sampleClient: ComputeNode {
		return ComputeNode(name: "Client 001",
						   description: "Sample PC",
						   hardwareDefinition: HardwareDefTest.sampleClientHWDef,
						   zone: ZoneTest.sampleIntranetZone,
						   type: .Client)
	}
	
	static var sampleVHost: ComputeNode {
		return ComputeNode(name: "VHost 001",
						   description: "Sample VHost",
						   hardwareDefinition: HardwareDefTest.sampleServerHWDef,
						   zone: ZoneTest.sampleIntranetZone,
						   type: .VirtualServer(vCores: 4, memoryGB: 16))
	}
	
	static var sampleHost: ComputeNode {
		return ComputeNode(name: "Host 001",
						   description: "Sample Physical Host",
						   hardwareDefinition: HardwareDefTest.sampleServerHWDef,
						   zone: ZoneTest.sampleIntranetZone,
						   type: .PhysicalServer,
						   virtualHosts: [sampleVHost])
	}
}
