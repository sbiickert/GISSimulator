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
