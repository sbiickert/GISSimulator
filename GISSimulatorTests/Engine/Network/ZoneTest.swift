//
//  ZoneTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-17.
//

import Testing
@testable import GISSimulator

struct ZoneTest {

    @Test func create() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
		let internet = ZoneTest.sampleInternetZone
		#expect(internet.name == "Internet")
		#expect(internet.description == "The internet zone.")
		#expect(internet.zoneType == .Internet)
    }
	
	@Test func editZone() async throws {
		var dmz = ZoneTest.sampleEdgeZone
		let network = RouteTest.sampleNetwork
		var local = dmz.localConnection(in: network)
		#expect(local != nil)
		// Connection identity is defined by the identity of the zones on either end
		// Connection equality is by value
		local?.bandwidthMbps = 789
		#expect(dmz.localConnection(in: network)! != local!)
		#expect(dmz.localConnection(in: network)! === local!)
		// Zone identity is based on id
		// Zone equality is by value
		dmz.name = "New Name"
		#expect(ZoneTest.sampleEdgeZone === dmz)
		#expect(dmz.localConnection(in: network) != nil) // Identity
		#expect(ZoneTest.sampleEdgeZone != dmz)
		#expect(dmz.connections(in: network).count == 5)
		#expect(local!.source === dmz)
		#expect(local!.source != dmz)
	}
	
	static let sampleInternetZone: Zone = Zone(
		name: "Internet",
		description: "The internet zone.",
		zoneType: .Internet)
	
	static let sampleEdgeZone: Zone = Zone(
		name: "DMZ",
		description: "The edge zone.",
		zoneType: .Edge)
	
	static let sampleIntranetZone: Zone = Zone(
		name: "Intranet",
		description: "The intranet zone.",
		zoneType: .Secured)
	
	static let sampleAGOLZone: Zone = Zone(
		name: "AGOL",
		description: "The ArcGIS Online zone.",
		zoneType: .Edge)
}
