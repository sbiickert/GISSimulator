//
//  VCUtil.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-04-29.
//

import UIKit

struct VCUtil {
	static func getDocument(_ vc: UIViewController) -> Document? {
		if let dvc = vc.navigationController?.viewControllers.first(where: {$0 is DocumentViewController}) as? DocumentViewController {
			return dvc.designDoc
		}
		return nil
	}
	
	static func getDesign(_ vc: UIViewController) -> Design? {
		return getDocument(vc)?.data.design
	}
}
