//
//  WorkflowDefStepTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-18.
//

import Testing
@testable import GISSimulator

struct WorkflowDefStepTest {

    @Test func create() async throws {
		let vdi = WorkflowDefStepTest.sampleVDIWorkflowDefStep
		#expect(vdi.chatter == 10)
    }

	// Client Steps
	static let sampleProWorkflowDefStep: WorkflowDefStep =
		WorkflowDefStep(name: "Pro Client Step", description: "Sample Pro WDS", serviceType: "pro", serviceTime: 831, chatter: 500, requestSizeKB: 1000, responseSizeKB: 13340, dataSourceType: .DBMS, cachePercent: 0)
	static let sampleBrowserWorkflowDefStep: WorkflowDefStep = WorkflowDefStep(name: "Browser Client Step", description: "Sample Browser WDS", serviceType: "browser", serviceTime: 20, chatter: 10, requestSizeKB: 100, responseSizeKB: 2134, dataSourceType: .None, cachePercent: 20)
	static let sampleMobileWorkflowDefStep: WorkflowDefStep = WorkflowDefStep(name: "Mobile Client Step", description: "Sample Mobile WDS", serviceType: "mobile", serviceTime: 20, chatter: 10, requestSizeKB: 100, responseSizeKB: 1234, dataSourceType: .None, cachePercent: 20)
	static let sampleVDIWorkflowDefStep: WorkflowDefStep = WorkflowDefStep(name: "VDI Client Step", description: "Sample VDI WDS", serviceType: "vdi", serviceTime: 831, chatter: 10, requestSizeKB: 100, responseSizeKB: 3691, dataSourceType: .DBMS, cachePercent: 0)
	
	// Service Steps
	static let sampleWebWorkflowDefStep: WorkflowDefStep = WorkflowDefStep(name: "Web Service Step", description: "Sample Web WDS", serviceType: "web", serviceTime: 18, chatter: 10, requestSizeKB: 100, responseSizeKB: 2134, dataSourceType: .None, cachePercent: 0)
	static let samplePortalWorkflowDefStep: WorkflowDefStep = WorkflowDefStep(name: "Portal Service Step", description: "Sample Portal WDS", serviceType: "portal", serviceTime: 19, chatter: 10, requestSizeKB: 100, responseSizeKB: 2134, dataSourceType: .File, cachePercent: 0)
	static let sampleDynMapWorkflowDefStep: WorkflowDefStep = WorkflowDefStep(name: "Dynamic Map Service Step", description: "Sample Dynamic Map WDS", serviceType: "map", serviceTime: 141, chatter: 10, requestSizeKB: 100, responseSizeKB: 2134, dataSourceType: .DBMS, cachePercent: 0)
	static let sampleCachedMapWorkflowDefStep: WorkflowDefStep = WorkflowDefStep(name: "Cached Map Service Step", description: "Sample Cached Map WDS", serviceType: "map", serviceTime: 1, chatter: 10, requestSizeKB: 100, responseSizeKB: 2134, dataSourceType: .File, cachePercent: 100)
	static let sampleHostedWorkflowDefStep: WorkflowDefStep = WorkflowDefStep(name: "Hosted Service Step", description: "Sample Hosted WDS", serviceType: "feature", serviceTime: 70, chatter: 10, requestSizeKB: 100, responseSizeKB: 4000, dataSourceType: .Relational, cachePercent: 0)
	static let sampleDBMSWorkflowDefStep: WorkflowDefStep = WorkflowDefStep(name: "DBMS Service Step", description: "Sample DBMS WDS", serviceType: "dbms", serviceTime: 24, chatter: 500, requestSizeKB: 500, responseSizeKB: 13340, dataSourceType: .File, cachePercent: 75)
	static let sampleFileWorkflowDefStep: WorkflowDefStep = WorkflowDefStep(name: "File Service Step", description: "Sample File WDS", serviceType: "file", serviceTime: 24, chatter: 500, requestSizeKB: 1000, responseSizeKB: 13340, dataSourceType: .File, cachePercent: 0)
	static let sampleRelationalWorkflowService: WorkflowDefStep = WorkflowDefStep(name: "Relational Service Step", description: "Sample Relational WDS", serviceType: "relational", serviceTime: 24, chatter: 10, requestSizeKB: 1000, responseSizeKB: 13340, dataSourceType: .File, cachePercent: 0)
}
