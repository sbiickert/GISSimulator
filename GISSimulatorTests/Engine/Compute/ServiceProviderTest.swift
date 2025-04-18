//
//  ServiceProviderTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-18.
//

import Testing
@testable import GISSimulator

struct ServiceProviderTest {

    @Test func create() async throws {
		let webSP = ServiceProviderTest.sampleWebServiceProvider
		#expect(webSP.name == "IIS")
		#expect(webSP.isValid)
		let portalSP = ServiceProviderTest.samplePortalServiceProvider
		
		#expect(portalSP.name == "Portal")
		#expect(portalSP.isValid)
		
		let mapSP = ServiceProviderTest.sampleMapServiceProvider
		#expect(mapSP.name == "GIS Site")
		#expect(mapSP.isValid)
		
		let haMapSP = ServiceProviderTest.sampleHAMapServiceProvider
		#expect(haMapSP.name == "GIS Site")
		#expect(haMapSP.isValid)
		
		let dbmsSP = ServiceProviderTest.sampleDBMSServiceProvider
		#expect(dbmsSP.name == "SQL Server")
		#expect(dbmsSP.isValid)
		
		let dsSP = ServiceProviderTest.sampleHADataStoreServiceProvider
		#expect(dsSP.name == "Relational DS")
		#expect(dsSP.isValid)
		
		let fileSP = ServiceProviderTest.sampleFileServiceProvider
		#expect(fileSP.name == "File Server")
		#expect(fileSP.isValid)
		
		let vdiSP = ServiceProviderTest.sampleVDIServiceProvider
		#expect(vdiSP.name == "VDI")
		#expect(vdiSP.isValid)
		
		let browserSP = ServiceProviderTest.sampleBrowserServiceProvider
		#expect(browserSP.name == "Chrome")
		#expect(browserSP.isValid)
		
		let proSP = ServiceProviderTest.sampleProServiceProvider
		#expect(proSP.name == "Pro")
		#expect(proSP.isValid)
    }

	static let vm = ComputeNodeTest.sampleVHost
	static func vm(named name: String) -> VirtualHost {
		var copy = vm
		copy.name = name
		return copy
	}
	
	static var sampleWebServiceProvider: ServiceProvider {
		let webVM = vm(named: "Web 001")
		return ServiceProvider(name: "IIS", description: "Web Server", service: ServiceTest.sampleService(for: "web"), nodes: [webVM])
	}
	
	static var samplePortalServiceProvider: ServiceProvider {
		let myVM = vm(named: "Portal 001")
		return ServiceProvider(name: "Portal", description: "Portal Server",
							   service: ServiceTest.sampleService(for: "portal"),
							   primary: myVM,
							   nodes: [myVM])
	}
	
	static var sampleMapServiceProvider: ServiceProvider {
		let myVM = vm(named: "GIS 001")
		return ServiceProvider(name: "GIS Site", description: "Map Server Site", service: ServiceTest.sampleService(for: "map"), nodes: [myVM])
	}
	
	static var sampleHAMapServiceProvider: ServiceProvider {
		let myVM1 = vm(named: "GIS 001")
		let myVM2 = vm(named: "GIS 002")
		return ServiceProvider(name: "GIS Site", description: "HA GIS Server Site", service: ServiceTest.sampleService(for: "map"), nodes: [myVM1, myVM2])
	}
	
	static var sampleDBMSServiceProvider: ServiceProvider {
		let myVM = vm(named: "SQL 001")
		return ServiceProvider(name: "SQL Server", description: "Geodatabase Server",
							   service: ServiceTest.sampleService(for: "dbms"),
							   primary: myVM,
							   nodes: [myVM])
	}
	
	static var sampleHADataStoreServiceProvider: ServiceProvider {
		let myVM1 = vm(named: "DS 001")
		let myVM2 = vm(named: "DS 002")
		return ServiceProvider(name: "Relational DS", description: "HA Datastore",
							   service: ServiceTest.sampleService(for: "relational"),
							   primary: myVM1,
							   nodes: [myVM1, myVM2])
	}
	
	static var sampleFileServiceProvider: ServiceProvider {
		let myVM = vm(named: "File 001")
		return ServiceProvider(name: "File Server", description: "File Server",
							   service: ServiceTest.sampleService(for: "file"),
							   primary: myVM,
							   nodes: [myVM])
	}
	
	static var sampleVDIServiceProvider: ServiceProvider {
		let myVM = vm(named: "Citrix 001")
		return ServiceProvider(name: "VDI", description: "Citrix Server",
							   service: ServiceTest.sampleService(for: "vdi"),
							   primary: myVM,
							   nodes: [myVM])
	}
	
	static var sampleBrowserServiceProvider: ServiceProvider {
		let client = ComputeNodeTest.sampleClient
		return ServiceProvider(name: "Chrome", description: "PC Workstation",
							   service: ServiceTest.sampleService(for: "browser"),
							   primary: client,
							   nodes: [client])
	}
	
	static var sampleProServiceProvider: ServiceProvider {
		let client = ComputeNodeTest.sampleClient
		return ServiceProvider(name: "Pro", description: "Pro Workstation",
							   service: ServiceTest.sampleService(for: "pro"),
							   primary: client,
							   nodes: [client])
	}

	static var sampleWebGISServiceProviders: Set<ServiceProvider> {
		return Set([sampleBrowserServiceProvider, sampleProServiceProvider, sampleVDIServiceProvider,
					sampleFileServiceProvider, sampleHADataStoreServiceProvider, sampleDBMSServiceProvider,
					sampleMapServiceProvider, samplePortalServiceProvider, sampleWebServiceProvider])
	}
}
