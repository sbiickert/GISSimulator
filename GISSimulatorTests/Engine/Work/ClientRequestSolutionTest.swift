//
//  ClientRequestSolutionTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-19.
//

import Testing
@testable import GISSimulator

struct ClientRequestSolutionTest {

    @Test func createIntranet() async throws {
        let crs = ClientRequestSolutionTest.sampleIntranetCRS
		#expect(crs.steps.count == 17)
		
		for i in 0..<crs.steps.count {
			if i % 2 == 0 {
				#expect(crs.steps[i].serviceTimeCalculator is ComputeNode)
			}
			else {
				#expect(crs.steps[i].serviceTimeCalculator is Connection)
			}
			// Check that steps in the second half are "response = true"
			if i > crs.steps.count / 2 {
				#expect(crs.steps[i].isResponse)
			}
		}
    }

	static var sampleIntranetCRS: ClientRequestSolution = {
		var chain = WorkflowDefTest.sampleDynamicMapChain(client: WorkflowDefStepTest.sampleBrowserWorkflowDefStep)
		chain.serviceProviders = ServiceProviderTest.sampleWebGISServiceProviders
		return ClientRequestSolution.createSolution(for: chain,
													in: RouteTest.sampleIntranet)
	}()
}
