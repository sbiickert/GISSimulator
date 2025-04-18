//
//  RouteTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-17.
//

import Testing
@testable import GISSimulator

struct RouteTest {

    @Test func routeIntranet() async throws {
		let network = RouteTest.sampleIntranet
		let sourceZone = ZoneTest.sampleIntranetZone
		let route = Route.findRoute(from: sourceZone, to: sourceZone, in: network)
		#expect(route != nil)
		#expect(route!.connections.count == 1)
    }
	
	@Test func routeNetwork() async throws {
		let network = RouteTest.sampleNetwork
		let sourceZone = ZoneTest.sampleIntranetZone
		let destinationZone = ZoneTest.sampleInternetZone
		let route = Route.findRoute(from: sourceZone, to: destinationZone, in: network)
		#expect(route != nil)
		#expect(route!.connections.count == 3)
		#expect(route!.connections.first!.source == sourceZone)
		#expect(route!.connections.last!.destination == destinationZone)
	}
	
	@Test func routeComplexNetwork() async throws {
		let network = RouteTest.sampleComplexNetwork
		let sourceZone = RouteTest.sampleWAN
		let destinationZone = ZoneTest.sampleAGOLZone
		let route = Route.findRoute(from: sourceZone, to: destinationZone, in: network)
		#expect(route != nil)
		#expect(route!.connections.count == 5)
		#expect(route!.connections.first!.source == sourceZone)
		#expect(route!.connections.last!.destination == destinationZone)
	}
	
	@Test func routeLoopingNetwork() async throws {
		let network = RouteTest.sampleLoopingNetwork
		let zoneA = RouteTest.sampleZoneA
		let zoneB = RouteTest.sampleZoneB
		let zoneC = RouteTest.sampleZoneC

		let routeAC = Route.findRoute(from: zoneA, to: zoneC, in: network)
		#expect(routeAC != nil)
		#expect(routeAC!.connections.count == 2)

		let routeAB = Route.findRoute(from: zoneA, to: zoneB, in: network)
		#expect(routeAB != nil)
		#expect(routeAB!.connections.count == 2)

		let routeBC = Route.findRoute(from: zoneB, to: zoneC, in: network)
		#expect(routeBC != nil)
		#expect(routeBC!.connections.count == 2)

	}

	static var sampleIntranet: [Connection] {
		let local = ZoneTest.sampleIntranetZone.selfConnect(bandwidthMbps: 1000, latencyMs: 0)
		return [local]
	}
	
	static var sampleNetwork: [Connection] {
		var network: [Connection] = []
		
		let intranet = ZoneTest.sampleIntranetZone
		let dmz = ZoneTest.sampleEdgeZone
		let internet = ZoneTest.sampleInternetZone
		
		network.append(intranet.selfConnect(bandwidthMbps: 1000))
		
		network.append(dmz.selfConnect(bandwidthMbps: 1000))
		network.append(ConnectionTest.sampleConnectionToDMZ)
		network.append(ConnectionTest.sampleConnectionToDMZ.invert())
		
		network.append(internet.selfConnect(bandwidthMbps: 1000, latencyMs: 10))
		network.append(dmz.connect(to: internet, bandwidthMbps: 100, latencyMs: 10)) // asymmetric
		network.append(internet.connect(to: dmz, bandwidthMbps: 500, latencyMs: 10))

		return network
	}
	
	static let sampleWAN = Zone(name: "WAN Site", description: "Second office", zoneType: .Secured)
	static var sampleComplexNetwork: [Connection] {
		var network: [Connection] = []
		
		let intranet = ZoneTest.sampleIntranetZone
		let wan = sampleWAN
		let dmz = ZoneTest.sampleEdgeZone
		let internet = ZoneTest.sampleInternetZone
		let agol = ZoneTest.sampleAGOLZone
		
		network.append(intranet.selfConnect(bandwidthMbps: 1000))
		
		network.append(dmz.selfConnect(bandwidthMbps: 1000))
		network.append(intranet.connect(to: dmz, bandwidthMbps: 1000, latencyMs: 0))
		network.append(dmz.connect(to: intranet, bandwidthMbps: 1000, latencyMs: 0))
		
		network.append(wan.selfConnect(bandwidthMbps: 1000))
		network.append(intranet.connect(to: wan, bandwidthMbps: 300, latencyMs: 7))
		network.append(wan.connect(to: intranet, bandwidthMbps: 300, latencyMs: 7))

		network.append(internet.selfConnect(bandwidthMbps: 1000, latencyMs: 10))
		network.append(dmz.connect(to: internet, bandwidthMbps: 100, latencyMs: 10))
		network.append(internet.connect(to: dmz, bandwidthMbps: 500, latencyMs: 10))
		
		network.append(agol.selfConnect(bandwidthMbps: 1000))
		network.append(internet.connect(to: agol, bandwidthMbps: 1000, latencyMs: 10))
		network.append(agol.connect(to: internet, bandwidthMbps: 1000, latencyMs: 10))
		
		return network
	}
	
	static let sampleZoneA = Zone(name: "Zone A", description: "", zoneType: .Secured)
	static let sampleZoneB = Zone(name: "Zone B", description: "", zoneType: .Secured)
	static let sampleZoneC = Zone(name: "Zone C", description: "", zoneType: .Secured)
	
	static var sampleLoopingNetwork: [Connection] {
		var network: [Connection] = []
		
		let zoneA = sampleZoneA
		let zoneB = sampleZoneB
		let zoneC = sampleZoneC
		
		network.append(zoneA.selfConnect(bandwidthMbps: 1000))
		network.append(zoneB.selfConnect(bandwidthMbps: 1000))
		network.append(zoneC.selfConnect(bandwidthMbps: 1000))
		
		network.append(zoneA.connect(to: zoneB, bandwidthMbps: 100, latencyMs: 1))
		network.append(zoneB.connect(to: zoneC, bandwidthMbps: 100, latencyMs: 1))
		network.append(zoneC.connect(to: zoneA, bandwidthMbps: 100, latencyMs: 1))
		
		network.append(zoneA.connect(to: zoneC, bandwidthMbps: 100, latencyMs: 1))
		network.append(zoneC.connect(to: zoneB, bandwidthMbps: 100, latencyMs: 1))
		network.append(zoneB.connect(to: zoneA, bandwidthMbps: 100, latencyMs: 1))
		
		return network
	}
}
