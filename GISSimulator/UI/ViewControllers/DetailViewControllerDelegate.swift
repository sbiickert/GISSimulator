//
//  DetailViewControllerDelegate.swift
//  GISSimulator
//
//  Created by Simon Biickert on 2025-05-21.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
	func detailViewControllerDidDismiss(_ detailViewController: UIViewController)
}
