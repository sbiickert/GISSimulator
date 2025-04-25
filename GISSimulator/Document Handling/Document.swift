//
//  Document.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-15.
//

import UIKit

class Document: UIDocument {
    
	struct DocumentData: Codable {
		var design: Design = Design(name: Design.nextName, description:"",
									
									services: DefLibManager.serviceDefLib.services)
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

