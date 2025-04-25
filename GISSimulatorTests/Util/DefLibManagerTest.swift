//
//  DefLibManagerTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-23.
//

import Testing
@testable import GISSimulator

struct DefLibManagerTest {

    @Test func readAssets() async throws {
		let hwAsset = DefLibManager.asset(named: "hardwaredef")
		#expect(hwAsset.typeIdentifier == "public.data")
    }
	
	@Test func readJson() async throws {
		let json = DefLibManager.json(named: "hardwaredef")
		#expect(json != nil)
		#expect(json!.contains("\"hardware\": ["))
	}
	
	@Test func readHardwareDefLib() async throws {
		let hwDefLib = DefLibManager.hardwareDefLib
		print(hwDefLib.date, terminator: "\n")
		#expect(hwDefLib.hardware.count == 436)
	}
	
	@Test func readWorkflowDefLib() async throws {
		let wfDefLib = DefLibManager.workflowDefLib
		print(wfDefLib.date, terminator: "\n")
		#expect(wfDefLib.steps.count == 12)
		#expect(wfDefLib.chains.count == 14)
		#expect(wfDefLib.workflows.count == 3)
	}

	@Test func readServiceDefLib() async throws {
		let svcDefLib = DefLibManager.serviceDefLib
		print(svcDefLib.date, terminator: "\n")
		#expect(svcDefLib.services.count == 25)
	}
}
