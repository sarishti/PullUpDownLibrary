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
    func loaderStopAnimating(_ pushLoader: Bool = false) {
      //   self.dg_stopLoading()
        if pushLoader {
         self.stopPushRefreshEver()
        }

	}
}
