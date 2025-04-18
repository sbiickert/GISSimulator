//
//  ConnectionTest.swift
//  GISSimulatorTests
//
//  Created by Simon Biickert on 2025-04-17.
//

import Testing
@testable import GISSimulator

struct ConnectionTest {

    @Test func create() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
		let local = ConnectionTest.sampleConnectionForIntranet
		#expect(local.isLocal)
		#expect(local.bandwidthMbps == 1000)
		#expect(local.latencyMs == 1)
		#expect(local.name == "Intranet to Intranet")
		
		let toDMZ = ConnectionTest.sampleConnectionToDMZ
		#expect(!toDMZ.isLocal)
		#expect(toDMZ.bandwidthMbps == 1000)
		#expect(toDMZ.latencyMs == 1)
		#expect(toDMZ.name == "Intranet to DMZ")
		
		let toInternet = ConnectionTest.sampleConnectionFromInternet
		#expect(!toInternet.isLocal)
		#expect(toInternet.bandwidthMbps == 500)
		#expect(toInternet.latencyMs == 10)
		#expect(toInternet.name == "DMZ to Internet")
    }
	
	@Test func invert() async throws {
		let local = ConnectionTest.sampleConnectionForIntranet
		let invLocal = local.invert()
		#expect(local == invLocal) // source and dest are swapped, but they are the same
		
		let toDMZ = ConnectionTest.sampleConnectionToDMZ
		let fromDMZ = toDMZ.invert()
		#expect(fromDMZ != toDMZ)
		#expect(fromDMZ.source == toDMZ.destination)
		#expect(fromDMZ.name == "DMZ to Intranet")
	}

	static let sampleConnectionForIntranet: Connection = Connection(
		source: ZoneTest.sampleIntranetZone,
		destination: ZoneTest.sampleIntranetZone,
		bandwidthMbps: 1000,
		latencyMs: 1)
	
	static let sampleConnectionToInternet: Connection = Connection(
		source: ZoneTest.sampleEdgeZone,
		destination: ZoneTest.sampleInternetZone,
		bandwidthMbps: 100,
		latencyMs: 10)
	
	static let sampleConnectionFromInternet: Connection = Connection(
		source: ZoneTest.sampleEdgeZone,
		destination: ZoneTest.sampleInternetZone,
		bandwidthMbps: 500,
		latencyMs: 10)

	static let sampleConnectionToDMZ: Connection = Connection(
		source: ZoneTest.sampleIntranetZone,
		destination: ZoneTest.sampleEdgeZone,
		bandwidthMbps: 1000,
		latencyMs: 1)

}
