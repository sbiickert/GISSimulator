//
//  DesignTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-21.
//

import Testing
@testable import GISSimulator

struct DesignTest {

    @Test func create() async throws {
		let d = DesignTest.sampleDesign
		#expect(d.name == "Sample 01")
		#expect(d.zones.count == 4)
		#expect(d.getZone(named: "DMZ")!.isFullyConnected(in: d.network))
		
		#expect(d.computeNodes.count == 7) // 2 physical, 3 virtual and 2 clients
		let localHost = d.getComputeNode(named: "SRV01")
		#expect(localHost != nil)
		#expect(localHost!.totalVirtualCPUAllocation == 16)
		#expect(localHost!.totalPhysicalCPUAllocation == 8)
		let gisHost = d.getComputeNode(named: "VGIS01")
		#expect(gisHost != nil)
		#expect(gisHost?.type == .VirtualServer(vCores: 8))
		
		#expect(d.serviceProviders.count == 16)
		#expect(d.workflows.count == 2)
		
		#expect(d.isValid)
		if !d.isValid { printDesignValidationMessages(d) }
    }
	
	@Test func updateServiceProviderList() async throws {
		var d = DesignTest.sampleDesign
		// Update the first VM on SRV01 (the web server)
		let updatedNodes = d.computeNodes.map({
				if $0.name != "SRV01" {
					return $0
				}
				var copy = $0
				copy.virtualHosts[0].description = "Updated"
				return copy
			})
		d.computeNodes = updatedNodes
		d.updateServiceProvidersWithNewComputeNodes()
		
		let updatedSPs = d.serviceProviders
			.filter({($0.handlerNode?.description ?? "") == "Updated"})
		#expect(updatedSPs.count == 2) // IIS and Portal are bot on the web server
		//print(updatedSPs)
		#expect(d.isValid)
	}
	
	@Test func updateWorkflowList() async throws {
		var d = DesignTest.sampleDesign
		var updatedSPs = d.serviceProviders
		updatedSPs[0].description = "Updated"
		d.serviceProviders = updatedSPs
		#expect(d.serviceProviders[0].description == "Updated")
		let name = d.serviceProviders[0].name
		d.updateWorkflowsWithNewServiceProviders()
		#expect(d.workflows[0].defaultServiceProviders.count(where: {$0.name == name && $0.description == "Updated"}) == 1)
		//print(d)
		#expect(d.isValid)
	}
	
	@Test func editZone() async throws {
		var d = DesignTest.sampleDesign
		var editZone = d.getZone(named: "Intranet")
		var local = editZone?.localConnection(in: d.network)
		#expect(editZone != nil)
		#expect(local != nil)
		editZone!.name = "Home Base"
		local!.bandwidthMbps = 789
		local!.latencyMs = 123
		
		d.replace(connection: local!)
		d.replace(zone: editZone!)
		
		#expect(d.getZone(named: "Intranet") == nil)
		
		let updatedConns = d.network.filter { $0.source.name == "Home Base" || $0.destination.name == "Home Base"}
		#expect(updatedConns.count == 3)
		
		let updatedNodes = d.computeNodes.filter { $0.zone.name == "Home Base" }
		#expect(updatedNodes.count == 5) // One physical server, 3 VMs, 1 client
	}
	
	@Test func deleteZone() async throws {
		var d = DesignTest.sampleDesign
		#expect(d.zones.count == 4)
		#expect(d.network.count == 10)
		d.remove(zone: d.getZone(named: "AGOL")!)
		#expect(d.zones.count == 3)
		#expect(d.network.count == 7)
		#expect(!d.isValid)
		printDesignValidationMessages(d)
	}
	
	private func printDesignValidationMessages(_ d: Design) {
		print("Validation errors:")
		d.validate().forEach { print($0) }
		d.workflows.forEach({wf in
			if !wf.isValid {
				print("Workflow \(wf.name):")
				wf.validate().forEach { print($0) }
				wf.definition.chains.forEach { chain in
					if !chain.isValid {
						print("Chain \(chain.name):")
						chain.validate().forEach { print($0) }
					}
				}
			}
		})
	}

	static var sampleDesign: Design {
		var d = Design(name: "Sample 01", description: "For testing purposes only")
		
		// Zones and Connections
		d.add(zone: ZoneTest.sampleIntranetZone, localBandwidthMbps: 1000, localLatencyMs: 0)
		d.add(zone: ZoneTest.sampleEdgeZone, localBandwidthMbps: 1000, localLatencyMs: 0)
		d.add(zone: ZoneTest.sampleInternetZone, localBandwidthMbps: 10000, localLatencyMs: 10)
		d.add(zone: ZoneTest.sampleAGOLZone, localBandwidthMbps: 10000, localLatencyMs: 0)
		
		d.add(connection: ConnectionTest.sampleConnectionToDMZ, addReciprocalConnection: true)
		d.add(connection: ConnectionTest.sampleConnectionToInternet, addReciprocalConnection: true)
		d.add(connection: ConnectionTest.sampleConnectionToAGOL, addReciprocalConnection: true)
		
		// Physical servers
		let localHost = ComputeNode(name: "SRV01", description: "Local Server",
									hardwareDefinition: HardwareDefTest.sampleServerHWDef,
									memoryGB: 48,
									zone: d.getZone(named: "Intranet")!, type: .PhysicalServer)
		let agolHost = ComputeNode(name: "AGOL01", description: "AWS Server",
								   hardwareDefinition: HardwareDefTest.sampleServerHWDef,
								   memoryGB: 64,
								   zone: d.getZone(named: "AGOL")!, type: .PhysicalServer)
		d.add(computeNode: localHost)
		d.add(computeNode: agolHost)
		
		// Virtual servers
		var copy = localHost
		copy.addVirtualHost(name: "VWEB01", vCores: 4, memoryGB: 16)
		copy.addVirtualHost(name: "VGIS01", vCores: 8, memoryGB: 32)
		copy.addVirtualHost(name: "VDB01", vCores: 4, memoryGB: 16)
		d.remove(computeNode: localHost)
		d.add(computeNode: copy)
		
		// Clients
		let localClient = ComputeNodeTest.sampleClient
		d.add(computeNode: localClient)
		let mobileClient = ComputeNodeTest.sampleMobile
		d.add(computeNode: mobileClient)
		
		// Services
		ServiceDefTest.sampleServiceTypes.forEach {
			d.add(service: ServiceDefTest.sampleService(for: $0))
		}
		
		// Service providers - Two sets. One local, one AGOL
		var spLocal = Set<ServiceProvider>()
		let spBrowser = ServiceProvider(name: "Web browser", description: "", service: d.services["browser"]!,
										nodes: [localClient])
		spLocal.insert(spBrowser)
		
		let spPro = ServiceProvider(name: "Pro workstation", description: "", service: d.services["pro"]!,
									nodes: [localClient])
		spLocal.insert(spPro)
		
		let spWeb = ServiceProvider(name: "IIS", description: "", service: d.services["web"]!,
									nodes: [d.getComputeNode(named: "VWEB01")!])
		spLocal.insert(spWeb)
		
		let spPortal = ServiceProvider(name: "Portal", description: "", service: d.services["portal"]!,
									   nodes: [d.getComputeNode(named: "VWEB01")!])
		spLocal.insert(spPortal)
		
		let spGIS = ServiceProvider(name: "Map Server", description: "", service: d.services["map"]!,
									nodes: [d.getComputeNode(named: "VGIS01")!])
		d.add(serviceProvider: spGIS)
		spLocal.insert(spGIS)
		
		let spHosted = ServiceProvider(name: "Hosted", description: "", service: d.services["feature"]!,
									   nodes: [d.getComputeNode(named: "VGIS01")!])
		spLocal.insert(spHosted)
		
		let spDS = ServiceProvider(name: "Datastore", description: "", service: d.services["relational"]!,
								   nodes: [d.getComputeNode(named: "VGIS01")!])
		spLocal.insert(spDS)
		
		let spDB = ServiceProvider(name: "SQL", description: "", service: d.services["dbms"]!,
								   nodes: [d.getComputeNode(named: "VDB01")!])
		spLocal.insert(spDB)
		
		let spFile = ServiceProvider(name: "File", description: "", service: d.services["file"]!,
									 nodes: [d.getComputeNode(named: "VGIS01")!])
		spLocal.insert(spFile)
		
		for sp in spLocal {
			d.add(serviceProvider: sp)
		}

		var spAGOL = Set<ServiceProvider>()
		spAGOL.insert(spBrowser)
		let agoMobile = ServiceProvider(name: "Field Maps", description: "", service: d.services["mobile"]!,
										nodes: [mobileClient])
		spAGOL.insert(agoMobile)
		
		let agoWeb = ServiceProvider(name: "AGOL Edge", description: "", service: d.services["web"]!,
									 nodes: [agolHost])
		spAGOL.insert(agoWeb)
		
		let agoPortal = ServiceProvider(name: "AGOL Portal", description: "", service: d.services["portal"]!,
										nodes: [agolHost])
		spAGOL.insert(agoPortal)
		
		let agoGIS = ServiceProvider(name: "AGOL GIS", description: "", service: d.services["feature"]!,
									 nodes: [agolHost])
		spAGOL.insert(agoGIS)
		
		let agoBasemap = ServiceProvider(name: "AGOL Basemap", description: "", service: d.services["map"]!,
										 nodes: [agolHost])
		spAGOL.insert(agoBasemap)
		
		let agoDB = ServiceProvider(name: "AGOL DB", description: "", service: d.services["relational"]!,
									nodes: [agolHost])
		spAGOL.insert(agoDB)
		
		let agoFile = ServiceProvider(name: "AGOL File", description: "", service: d.services["file"]!,
									  nodes: [agolHost])
		spAGOL.insert(agoFile)
		
		for sp in spAGOL {
			d.add(serviceProvider: sp)
		}
		
		// Workflows
		var webWF = Workflow(name: "Web", description: "Web Application", type: .Transactional,
							 definition: WorkflowDefTest.sampleWebWorkflowDef,
							 defaultServiceProviders: spLocal, tph: 1000)
		webWF.applyDefaultServiceProviders()
		webWF.updateServiceProviders(at: 1, serviceProviders: spAGOL) // Basemap from AGOL
		d.add(workflow: webWF)

		var mobileWF = Workflow(name: "Field Maps", description: "Mobile Data Collection", type: .User,
								definition: WorkflowDefTest.sampleMobileWorkflowDef,
								defaultServiceProviders: spAGOL, userCount: 15, productivity: 6)
		mobileWF.applyDefaultServiceProviders()
		d.add(workflow: mobileWF)
		
		return d
	}
}
