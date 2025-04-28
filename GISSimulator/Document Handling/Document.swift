//
//  Document.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-15.
//

import UIKit

class Document: UIDocument {
    
	class DocumentData: Codable {
		var _design: Design? = nil
		var design: Design {
			get {
				if _design == nil {
					_design = Design(name: Design.nextName, description:"",
									 services: DefLibManager.serviceDefLib.services)
					
					// Zones and Connections
					let intranet = Zone(name: "Intranet", description: "Local Network", zoneType: .Secured)
					let dmz = Zone(name: "DMZ", description: "Edge Network", zoneType: .Edge)
					let internet = Zone(name: "Internet", description: "Public Network", zoneType: .Internet)
					let agol = Zone(name: "AGOL", description: "ArcGIS Online", zoneType: .Internet)
					
					_design!.add(zone: intranet, localBandwidthMbps: 1000, localLatencyMs: 0)
					_design!.add(zone: dmz, localBandwidthMbps: 1000, localLatencyMs: 0)
					_design!.add(zone: internet, localBandwidthMbps: 10000, localLatencyMs: 10)
					_design!.add(zone: agol, localBandwidthMbps: 10000, localLatencyMs: 0)
					
					_design!.add(connection: Connection(source: intranet, destination: dmz, bandwidthMbps: 1000, latencyMs: 0), addReciprocalConnection: true)
					_design!.add(connection: Connection(source: dmz, destination: internet, bandwidthMbps: 500, latencyMs: 10), addReciprocalConnection: true)
					_design!.add(connection: Connection(source: internet, destination: agol, bandwidthMbps: 1000, latencyMs: 10), addReciprocalConnection: true)
				}
				return _design!
			}
			set {
				_design = newValue
			}
		}
		var drawingInfo: DrawingInfo = DrawingInfo()
	}
	
	var data = DocumentData()
	
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
		print("Saving document")
		let encoder = JSONEncoder()
		let jsonData = try encoder.encode(data)
		return jsonData
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
		print("Loading document")
		let decoder = JSONDecoder()
		data = try decoder.decode(DocumentData.self, from: contents as! Data)
    }
}

