//
//  ServiceTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-18.
//

import Testing
@testable import GISSimulator

struct ServiceDefTest {

    @Test func create() async throws {
		let allServices = ServiceDefTest.sampleServiceTypes.map({($0, ServiceDefTest.sampleService(for: $0))})
			.reduce(into: [:]) { $0[$1.0] = $1.1 }
		
		#expect(allServices.count == ServiceDefTest.sampleServiceTypes.count)
		#expect(allServices["pro"] != nil)
		#expect(allServices["pro"]?.name == "Pro")
		#expect(allServices["image"]?.balancingModel == .RoundRobin)
		#expect(allServices["portal"]?.balancingModel == .Failover)
		#expect(allServices["geoevent"]?.balancingModel == .Single)
    }

	static let sampleServiceTypes: [String] = [
		"pro", "browser", "map", "feature", "image",
		"geocode", "geoevent", "geometry", "gp",
		"network", "scene", "sync", "stream",
		"ranalytics", "un", "custom", "vdi",
		"web", "portal", "dbms", "relational",
		"object", "stbds", "file", "mobile"]
	
	static func sampleService(for type: String) -> ServiceDef {
		switch type {
		case "pro":
			return ServiceDef(name: "Pro", description: "Sample Pro", serviceType: type, balancingModel: .Single)
		case "browser":
			return ServiceDef(name: "Browser", description: "Sample Browser", serviceType: type, balancingModel: .Single)
		case "mobile":
			return ServiceDef(name: "Mobile", description: "Sample App", serviceType: type, balancingModel: .Single)
		case "map":
			return ServiceDef(name: "Map", description: "Sample Map", serviceType: type, balancingModel: .RoundRobin)
		case "feature":
			return ServiceDef(name: "Feature", description: "Sample Feature", serviceType: type, balancingModel: .RoundRobin)
		case "image":
			return ServiceDef(name: "Image", description: "Sample Image", serviceType: type, balancingModel: .RoundRobin)
		case "geocode":
			return ServiceDef(name: "Geocode", description: "Sample Geocode", serviceType: type, balancingModel: .RoundRobin)
		case "geoevent":
			return ServiceDef(name: "Geoevent", description: "Sample Geoevent", serviceType: type, balancingModel: .Single)
		case "geometry":
			return ServiceDef(name: "Geometry", description: "Sample Geometry", serviceType: type, balancingModel: .RoundRobin)
		case "gp":
			return ServiceDef(name: "GP", description: "Sample GP", serviceType: type, balancingModel: .RoundRobin)
		case "network":
			return ServiceDef(name: "Network", description: "Sample Network", serviceType: type, balancingModel: .RoundRobin)
		case "scene":
			return ServiceDef(name: "Scene", description: "Sample Scene", serviceType: type, balancingModel: .RoundRobin)
		case "sync":
			return ServiceDef(name: "Sync", description: "Sample Sync", serviceType: type, balancingModel: .RoundRobin)
		case "stream":
			return ServiceDef(name: "Stream", description: "Sample Stream", serviceType: type, balancingModel: .RoundRobin)
		case "ranalytics":
			return ServiceDef(name: "Ranalytics", description: "Sample Ranalytics", serviceType: type, balancingModel: .RoundRobin)
		case "un":
			return ServiceDef(name: "UN", description: "Sample UN", serviceType: type, balancingModel: .RoundRobin)
		case "custom":
			return ServiceDef(name: "Custom", description: "Sample Custom", serviceType: type, balancingModel: .Single)
		case "vdi":
			return ServiceDef(name: "Vdi", description: "Sample VDI", serviceType: type, balancingModel: .Failover)
		case "web":
			return ServiceDef(name: "Web", description: "Sample Web", serviceType: type, balancingModel: .RoundRobin)
		case "portal":
			return ServiceDef(name: "Portal", description: "Sample Portal", serviceType: type, balancingModel: .Failover)
		case "dbms":
			return ServiceDef(name: "DBMS", description: "Sample DBMS", serviceType: type, balancingModel: .Failover)
		case "relational":
			return ServiceDef(name: "Relational", description: "Sample Relational", serviceType: type, balancingModel: .Failover)
		case "object":
			return ServiceDef(name: "Object", description: "Sample Object", serviceType: type, balancingModel: .Failover)
		case "stbds":
			return ServiceDef(name: "STBDS", description: "Sample Spatio-Temporal Data Store", serviceType: type, balancingModel: .RoundRobin)
		case "file":
			return ServiceDef(name: "File", description: "Sample File", serviceType: type, balancingModel: .Failover)
		default:
			return ServiceDef(name: "None", description: "Invalid", serviceType: type, balancingModel: .Single)
		}
	}
}
