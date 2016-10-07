//
//  Extension.swift
//  PullUpDownLibrary
//
//  Created by Sarishti on 9/8/16.
//  Copyright © 2016 sarishti. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
	func loaderStopAnimating() {
         self.dg_stopLoading()
		self.infiniteScrollingView?.stopAnimating()
	}
}
