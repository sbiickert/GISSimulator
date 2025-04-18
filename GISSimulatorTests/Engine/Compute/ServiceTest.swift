//
//  ServiceTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-18.
//

import Testing
@testable import GISSimulator

struct ServiceTest {

    @Test func create() async throws {
		let allServices = ServiceTest.sampleServiceTypes.map({($0, ServiceTest.sampleService(for: $0))})
			.reduce(into: [:]) { $0[$1.0] = $1.1 }
		
		#expect(allServices.count == ServiceTest.sampleServiceTypes.count)
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
		"object", "stbds", "file"]
	
	static func sampleService(for type: String) -> Service {
		switch type {
		case "pro":
			return Service(name: "Pro", description: "Sample Pro", serviceType: type, balancingModel: .Single)
		case "browser":
			return Service(name: "Browser", description: "Sample Browser", serviceType: type, balancingModel: .Single)
		case "map":
			return Service(name: "Map", description: "Sample Map", serviceType: type, balancingModel: .RoundRobin)
		case "feature":
			return Service(name: "Feature", description: "Sample Feature", serviceType: type, balancingModel: .RoundRobin)
		case "image":
			return Service(name: "Image", description: "Sample Image", serviceType: type, balancingModel: .RoundRobin)
		case "geocode":
			return Service(name: "Geocode", description: "Sample Geocode", serviceType: type, balancingModel: .RoundRobin)
		case "geoevent":
			return Service(name: "Geoevent", description: "Sample Geoevent", serviceType: type, balancingModel: .Single)
		case "geometry":
			return Service(name: "Geometry", description: "Sample Geometry", serviceType: type, balancingModel: .RoundRobin)
		case "gp":
			return Service(name: "Gp", description: "Sample Gp", serviceType: type, balancingModel: .RoundRobin)
		case "network":
			return Service(name: "Network", description: "Sample Network", serviceType: type, balancingModel: .RoundRobin)
		case "scene":
			return Service(name: "Scene", description: "Sample Scene", serviceType: type, balancingModel: .RoundRobin)
		case "sync":
			return Service(name: "Sync", description: "Sample Sync", serviceType: type, balancingModel: .RoundRobin)
		case "stream":
			return Service(name: "Stream", description: "Sample Stream", serviceType: type, balancingModel: .RoundRobin)
		case "ranalytics":
			return Service(name: "Ranalytics", description: "Sample Ranalytics", serviceType: type, balancingModel: .RoundRobin)
		case "un":
			return Service(name: "Un", description: "Sample Un", serviceType: type, balancingModel: .RoundRobin)
		case "custom":
			return Service(name: "Custom", description: "Sample Custom", serviceType: type, balancingModel: .Single)
		case "vdi":
			return Service(name: "Vdi", description: "Sample Vdi", serviceType: type, balancingModel: .Failover)
		case "web":
			return Service(name: "Web", description: "Sample Web", serviceType: type, balancingModel: .RoundRobin)
		case "portal":
			return Service(name: "Portal", description: "Sample Portal", serviceType: type, balancingModel: .Failover)
		case "dbms":
			return Service(name: "Dbms", description: "Sample Dbms", serviceType: type, balancingModel: .Failover)
		case "relational":
			return Service(name: "Relational", description: "Sample Relational", serviceType: type, balancingModel: .Failover)
		case "object":
			return Service(name: "Object", description: "Sample Object", serviceType: type, balancingModel: .Failover)
		case "stbds":
			return Service(name: "Stbds", description: "Sample Stbds", serviceType: type, balancingModel: .RoundRobin)
		case "file":
			return Service(name: "File", description: "Sample File", serviceType: type, balancingModel: .Failover)
		default:
			return Service(name: "None", description: "Invalid", serviceType: type, balancingModel: .Single)
		}
	}
}
