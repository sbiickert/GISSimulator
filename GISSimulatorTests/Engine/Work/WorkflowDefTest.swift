//
//  WorkflowDefTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-19.
//

import Testing
@testable import GISSimulator

struct WorkflowDefTest {

    @Test func create() async throws {
		let wf = WorkflowDefTest.sampleWebWorkflowDef
		#expect(wf.name == "Web Map Definition")
		#expect(wf.description == "Sample Web Map")
		#expect(wf.chains.count == 2)
		#expect(wf.chains[0].steps[3].serviceType == "map")
		#expect(wf.chains[0].steps[4].serviceType == "dbms")
		#expect(wf.chains[1].steps[3].serviceType == "map")
		#expect(wf.allRequiredServiceTypes == Set(["portal", "file", "browser", "map", "dbms", "web"]))
    }
	
	@Test func addChain() async throws {
		let wf = WorkflowDefTest.sampleWebWorkflowDef
		let overlay = WorkflowChain(
			name: "Hosted Features",
			description: "",
			steps: [
				WorkflowDefStepTest.sampleBrowserWorkflowDefStep,
				WorkflowDefStepTest.sampleWebWorkflowDefStep,
				WorkflowDefStepTest.samplePortalWorkflowDefStep,
				WorkflowDefStepTest.sampleHostedWorkflowDefStep,
				WorkflowDefStepTest.sampleRelationalWorkflowService
			], serviceProviders: Set<ServiceProvider>())
		
		let withOverlay = wf.add(chain: overlay)
		#expect(withOverlay.chains.count == 3)
		#expect(withOverlay.chains[0].steps[3].serviceType == "feature")
		#expect(withOverlay.chains[0].steps[4].serviceType == "relational")
		#expect(withOverlay.allRequiredServiceTypes == Set(["portal", "file", "browser", "map", "dbms", "web", "feature", "relational"]))
	}
	
	@Test func removeChain() async throws {
		let wf = WorkflowDefTest.sampleWebWorkflowDef
		let withoutOverlay = wf.removeChain(at: 0)
		#expect(withoutOverlay.chains.count == 1)
		#expect(wf.chains[0].steps[3].serviceType == "map")
		#expect(wf.chains[0].steps[4].serviceType == "dbms")
		#expect(withoutOverlay.allRequiredServiceTypes == Set(["portal", "file", "browser", "map", "web"]))
	}

	// Chains
	static let sampleWebDynamicMapChain: WorkflowChain = WorkflowChain(
		name: "Dynamic Map Image",
		description: "",
		steps: [
			WorkflowDefStepTest.sampleBrowserWorkflowDefStep,
			WorkflowDefStepTest.sampleWebWorkflowDefStep,
			WorkflowDefStepTest.samplePortalWorkflowDefStep,
			WorkflowDefStepTest.sampleDynMapWorkflowDefStep,
			WorkflowDefStepTest.sampleDBMSWorkflowDefStep
		],
		serviceProviders: Set<ServiceProvider>())

	static let sampleWebCachedMapChain: WorkflowChain = WorkflowChain(
		name: "Dynamic Map Image",
		description: "",
		steps: [
			WorkflowDefStepTest.sampleBrowserWorkflowDefStep,
			WorkflowDefStepTest.sampleWebWorkflowDefStep,
			WorkflowDefStepTest.samplePortalWorkflowDefStep,
			WorkflowDefStepTest.sampleCachedMapWorkflowDefStep,
			WorkflowDefStepTest.sampleFileWorkflowDefStep
		],
		serviceProviders: Set<ServiceProvider>())

	static let sampleProChain: WorkflowChain = WorkflowChain(
		name: "Pro DC",
		description: "",
		steps: [
			WorkflowDefStepTest.sampleProWorkflowDefStep,
			WorkflowDefStepTest.sampleDBMSWorkflowDefStep
		],
		serviceProviders: Set<ServiceProvider>())
	
	static let sampleProBasemapChain = WorkflowChain(
		name: "Pro Basemap",
		description: "",
		steps: [
			WorkflowDefStepTest.sampleProWorkflowDefStep,
			WorkflowDefStepTest.sampleWebWorkflowDefStep,
			WorkflowDefStepTest.samplePortalWorkflowDefStep,
			WorkflowDefStepTest.sampleCachedMapWorkflowDefStep,
			WorkflowDefStepTest.sampleFileWorkflowDefStep
		],
		serviceProviders: Set<ServiceProvider>())
	
	static let sampleProVDIChain = WorkflowChain(
		name: "Pro VDI",
		description: "",
		steps: [
			WorkflowDefStepTest.sampleVDIWorkflowDefStep,
			WorkflowDefStepTest.sampleProWorkflowDefStep,
			WorkflowDefStepTest.sampleDBMSWorkflowDefStep
		],
		serviceProviders: Set<ServiceProvider>())
	
	// Workflow Definitions
	static let sampleWebWorkflowDef: WorkflowDef = WorkflowDef(
		name: "Web Map Definition",
		description: "Sample Web Map",
		thinkTimeSeconds: 6,
		chains: [sampleWebDynamicMapChain, sampleWebCachedMapChain])
	
	static let sampleMobileWorkflowDef: WorkflowDef = WorkflowDef(
		name: "Mobile Map Definition",
		description: "Sample Mobile Map",
		thinkTimeSeconds: 10,
		chains: [sampleWebDynamicMapChain, sampleWebCachedMapChain])
	
	static let sampleWorkstationWorkflowDef: WorkflowDef = WorkflowDef(
		name: "Workstation Map Definition",
		description: "Sample Workstation Map",
		thinkTimeSeconds: 3,
		chains: [sampleProChain, sampleWebCachedMapChain])
	
	static let sampleVDIWorkflowDef: WorkflowDef = WorkflowDef(
		name: "VDI Map Definition",
		description: "Sample VDI Map",
		thinkTimeSeconds: 3,
		chains: [sampleProVDIChain, sampleProBasemapChain])
}
