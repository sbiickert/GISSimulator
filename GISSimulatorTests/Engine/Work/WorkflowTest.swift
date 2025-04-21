//
//  WorkflowTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-19.
//

import Testing
@testable import GISSimulator

struct WorkflowTest {

    @Test func create() async throws {
		let wfPro = WorkflowTest.sampleWorkstationWorkflow
		#expect(wfPro.name == "Pro")
		#expect(wfPro.missingServiceProviders.isEmpty)
		let wfVDI = WorkflowTest.sampleVDIWorkflow
		#expect(wfVDI.name == "VDI")
		#expect(wfVDI.missingServiceProviders.isEmpty)
		let wfWeb = WorkflowTest.sampleWebWorkflow
		#expect(wfWeb.name == "Web")
		#expect(wfWeb.missingServiceProviders.isEmpty)
		
		var wfMissingSPs = wfWeb
		wfMissingSPs.defaultServiceProviders = Set([
			ServiceProviderTest.sampleBrowserServiceProvider,
			ServiceProviderTest.sampleFileServiceProvider,
			ServiceProviderTest.sampleWebServiceProvider])
		let missing = wfMissingSPs.missingServiceProviders
		#expect(missing.count == 3)
		#expect(missing.contains("map"))
		#expect(missing.contains("dbms"))
		#expect(missing.contains("portal"))
    }

	static let sampleWorkstationWorkflow: Workflow = Workflow(
		name: "Pro",
		description: "Local workstation",
		type: .User,
		definition: WorkflowDefTest.sampleWorkstationWorkflowDef,
		defaultServiceProviders: ServiceProviderTest.sampleWebGISServiceProviders,
		userCount: 5,
		productivity: 10,
		tph: 0) // Ignored for .User workflow

	static let sampleVDIWorkflow: Workflow = Workflow(
		name: "VDI",
		description: "VDI workstation",
		type: .User,
		definition: WorkflowDefTest.sampleVDIWorkflowDef,
		defaultServiceProviders: ServiceProviderTest.sampleWebGISServiceProviders,
		userCount: 5,
		productivity: 10,
		tph: 0) // Ignored for .User workflow
	
	static let sampleWebWorkflow: Workflow = Workflow(
		name: "Web",
		description: "Web application",
		type: .Transactional,
		definition: WorkflowDefTest.sampleWebWorkflowDef,
		defaultServiceProviders: ServiceProviderTest.sampleWebGISServiceProviders,
		userCount: 0,	 	// Ignored for .Transactional workflow
		productivity: 0,	// Ignored for .Transactional workflow
		tph: 10000) // Ignored for .User workflow

}
