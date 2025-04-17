//
//  DataSourceType.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-16.
//

import Foundation

public enum DataSourceType: String, CaseIterable {
	case Relational = "Relational"
	case Object = "Object"
	case File = "File"
	case DBMS = "DBMS"
	case Big = "Big"
	case Other = "Other"
	case None = "None"
}
