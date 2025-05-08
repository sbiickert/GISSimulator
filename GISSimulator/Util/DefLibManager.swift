//
//  DefLibManager.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-23.
//

import Foundation
import UIKit

struct DefLibManager {
	private enum LibName: String {
		case Hardware = "hardwaredef"
		case Workflows = "workflowdef"
		case Services = "servicedef"
	}
	
	static func asset(named name: String, in bundle: Bundle = .main) -> NSDataAsset {
		let a = NSDataAsset(name: name, bundle: bundle)
		guard let asset = a else {
			fatalError("Could not load asset \(name)")
		}
		return asset
	}
	
	static func json(named name: String) -> String? {
		let asset = asset(named: name)
		guard let data = String(data: asset.data, encoding: .utf8) else {
			return nil
		}
		return data
	}
	
	static func dictionary(named name: String) -> NSDictionary? {
		let asset = asset(named: name)
		let data = try? JSONSerialization.jsonObject(with: asset.data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
		return data
	}
	
	// MARK: - Hardware Definitions

	static var hardwareDefLib: HardwareDefLib {
		guard let dict = dictionary(named: LibName.Hardware.rawValue) else {
			fatalError("Could not read hardware def lib")
		}
		guard let version = dict["version"] as? Int else {
			fatalError("Could not determine version of hardware def lib")
		}
		switch version {
		case 1:
			return parseHWv1(dict)
		default:
			fatalError("Unsupported hardware def lib version \(version)")
		}
	}
	
	private static func parseHWv1(_ dict: NSDictionary) -> HardwareDefLib {
		guard let dateString = dict["updatedOn"] as? String else {
			fatalError("Could not determine update date of hardware def lib")
		}
		guard let date = dateFormatter.date(from: dateString) else {
			fatalError("Could not parse update date of hardware def lib")
		}
		
		guard let hardwareDicts = dict["hardware"] as? NSArray else {
			fatalError("Could not find hardware array for hardware def lib")
		}
		var hardware: [String: HardwareDef] = [:]
		for hwDict in hardwareDicts {
			guard let hwDict = hwDict as? NSDictionary else {
				continue
			}
			guard let hwDef = hwFromDictv1(hwDict) else {
				continue
			}
			hardware[hwDef.processor + " [\(hwDef.cores)]"] = hwDef
		}
		
		return HardwareDefLib(date: date, hardware: hardware)
	}
	
	public static func hwFromDictv1(_ dict: NSDictionary) -> HardwareDef? {
		guard let processor = dict["processor"] as? String else { return nil }
		guard let cores = dict["cores"] as? Int else { return nil }
		guard let spec = dict["spec"] as? Double else { return nil }
		guard let arch = dict["arch"] as? String else { return nil }
		
		let compArch = ComputeArchitecture.from(arch)
		let threading = compArch == .Intel ? ThreadingModel.HyperThreaded : .Physical
		
		return HardwareDef(processor: processor, cores: cores, specIntRate2017: spec, architecture: compArch, threading: threading)
	}

	// MARK: - Workflow Definitions
	
	static var workflowDefLib: WorkflowDefLib {
		guard let dict = dictionary(named: LibName.Workflows.rawValue) else {
			fatalError("Could not read workflow def lib")
		}
		guard let version = dict["version"] as? Int else {
			fatalError("Could not determine version of workflow def lib")
		}
		switch version {
		case 1:
			return parseWFv1(dict)
		default:
			fatalError("Unsupported workflow def lib version \(version)")
		}
	}
	
	private static func parseWFv1(_ dict: NSDictionary) -> WorkflowDefLib {
		guard let dateString = dict["updatedOn"] as? String else {
			fatalError("Could not determine update date of workflow def lib")
		}
		guard let date = dateFormatter.date(from: dateString) else {
			fatalError("Could not parse update date of workflow def lib")
		}
		guard let baseline = dict["baselineSPECPerCore"] as? Double else {
			fatalError("Could not parse baseline SPEC per core")
		}
		guard let stepsArr = dict["steps"] as? NSArray else {
			fatalError("Could not find steps array for workflow def lib")
		}
		guard let chainsArr = dict["chains"] as? NSArray else {
			fatalError("Could not find chains array for workflow def lib")
		}
		guard let workflowsArr = dict["workflows"] as? NSArray else {
			fatalError("Could not find workflows array for workflow def lib")
		}

		let steps: [String: WorkflowDefStep] = stepsArr
			.compactMap({ wfStepFromDictv1( $0 as! NSDictionary )})
			.reduce(into: [String:WorkflowDefStep](), {$0[$1.name] = $1})
		
		let chains: [String: WorkflowChain] = chainsArr
			.compactMap { wfChainFromDictv1($0 as! NSDictionary, stepsLookup: steps) }
			.reduce(into: [String:WorkflowChain]()) {$0[$1.name] = $1}
		
		let workflows: [String: WorkflowDef] = workflowsArr
			.compactMap {workflowFromDictv1($0 as! NSDictionary, chainsLookup: chains) }
			.reduce(into: [String:WorkflowDef]()) {$0[$1.name] = $1}
		
		return WorkflowDefLib(date: date,
							  baselineSpecPerCore: baseline,
							  steps: steps,
							  chains: chains,
							  workflows: workflows)
	}
	
	private static func wfStepFromDictv1(_ dict: NSDictionary) -> WorkflowDefStep? {
		guard let name = dict["name"] as? String else { return nil }
		guard let desc = dict["desc"] as? String else { return nil }
		guard let type = dict["type"] as? String else { return nil }
		guard let st = dict["st"] as? Int else { return nil }
		guard let chatter = dict["chatter"] as? Int else { return nil }
		guard let reqKB = dict["reqKB"] as? Int else { return nil }
		guard let respKB = dict["respKB"] as? Int else { return nil }
		guard let cache = dict["cache"] as? Int else { return nil }
		guard let ds = dict["ds"] as? String else { return nil }

		let dataSourceType: DataSourceType
		switch ds {
		case "DBMS": dataSourceType = .DBMS
		case "FILE": dataSourceType = .File
		case "RELATIONAL": dataSourceType = .Relational
		case "NONE": dataSourceType = .None
		case "BIG": dataSourceType = .Big
		case "OBJECT": dataSourceType = .Object
		default:
			dataSourceType = .Other
		}
		return WorkflowDefStep(name: name, description: desc, serviceType: type, serviceTime: st, chatter: chatter, requestSizeKB: reqKB, responseSizeKB: respKB, dataSourceType: dataSourceType, cachePercent: cache)
	}
	
	private static func wfChainFromDictv1(_ dict: NSDictionary,
										  stepsLookup: [String: WorkflowDefStep]) -> WorkflowChain? {
		guard let name = dict["name"] as? String else { return nil }
		guard let desc = dict["desc"] as? String else { return nil }
		guard let stepsArr = dict["steps"] as? NSArray else { return nil }
		
		let steps = stepsArr.compactMap { stepsLookup[$0 as! String] }
		return WorkflowChain(name: name, description: desc, steps: steps, serviceProviders: [])
	}
	
	private static func workflowFromDictv1(_ dict: NSDictionary,
										   chainsLookup: [String: WorkflowChain]) -> WorkflowDef? {
		guard let name = dict["name"] as? String else { return nil }
		guard let desc = dict["desc"] as? String else { return nil }
		guard let think = dict["think"] as? Int else { return nil }
		guard let chainsArr = dict["chains"] as? NSArray else { return nil }
		
		let chains = chainsArr.compactMap { chainsLookup[$0 as! String] }
		return WorkflowDef(name: name, description: desc,
						   thinkTimeSeconds: think,
						   chains: chains)
	}
	
	
	// MARK: - Service Definitions

	static var serviceDefLib: ServiceDefLib {
		guard let dict = dictionary(named: LibName.Services.rawValue) else {
			fatalError("Could not read service def lib")
		}
		guard let version = dict["version"] as? Int else {
			fatalError("Could not determine version of service def lib")
		}
		switch version {
		case 1:
			return parseSv1(dict)
		default:
			fatalError("Unsupported service def lib version \(version)")
		}
	}
	
	private static func parseSv1(_ dict: NSDictionary) -> ServiceDefLib {
		guard let dateString = dict["updatedOn"] as? String else {
			fatalError("Could not determine update date of service def lib")
		}
		guard let date = dateFormatter.date(from: dateString) else {
			fatalError("Could not parse update date of service def lib")
		}
		
		guard let serviceDicts = dict["services"] as? NSArray else {
			fatalError("Could not find services array for service def lib")
		}
		var services: [String: ServiceDef] = [:]
		for sDict in serviceDicts {
			guard let sDict = sDict as? NSDictionary else {
				continue
			}
			guard let sDef = sFromDictv1(sDict) else {
				continue
			}
			services[sDef.serviceType] = sDef
		}
		
		return ServiceDefLib(date: date, services: services)
	}
	
	public static func sFromDictv1(_ dict: NSDictionary) -> ServiceDef? {
		guard let name = dict["name"] as? String else { return nil }
		guard let desc = dict["description"] as? String else { return nil }
		guard let type = dict["serviceType"] as? String else { return nil }
		guard let balancing = dict["balancingModel"] as? String else { return nil }
		
		guard let bModel = BalancingModel(rawValue: balancing) else { return nil }

		return ServiceDef(name: name, description: desc, serviceType: type, balancingModel: bModel)
	}
	
	private static var dateFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		return formatter
	}
}
