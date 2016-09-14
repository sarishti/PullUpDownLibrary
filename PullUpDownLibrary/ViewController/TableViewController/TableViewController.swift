//
//  TableViewController.swift
//  PullUpDownLibrary
//
//  Created by Sarishti on 9/8/16.
//  Copyright © 2016 sarishti. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {

	// MARK: - Properties

	let tableViewCellIdentifier = "TableViewCell"

	/// Outlet
	@IBOutlet weak var tableView: UITableView!

	/// array
	var arrayData = [String]()

	/// Paggination Limit
	let articlesLimit = 20

	override func viewDidLoad() {
		super.viewDidLoad()

		self.setPullToRefreshOnTable()
		self.setInfiniteScrollOnTable()
		self.fetchData(0)
		// Do any additional setup after loading the view.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	// MARK: Pull to refresh
	/**
     Set the Reuseable component Pull to refresh handler
     */
	func setPullToRefreshOnTable() {
		/**
         *  Add Pull to refresh handler
         */
		tableView.addPullToRefreshHandler {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in

				/**
                 When pull to refresh works every time call the fetch data function with offset 0
                 */
				self.fetchData(0)
			})
		}
	}
	// MARK: - Infinite scrolling
	/**
     Set reuseable component Infinite scroller handler
     */
	func setInfiniteScrollOnTable() {

		/// Set the font and size of No more Record
		let fontForInfiniteScrolling = UIFont(name: "HelveticaNeue-Bold", size: 15) ?? UIFont.boldSystemFontOfSize(17)

		/**
         Add infinite scroller handler
         */
		self.tableView
			.addInfiniteScrollingWithHandler(fontForInfiniteScrolling, fontColor: UIColor.redColor(), actionHandler: {
				/**
                 If has more data true then scroller works
                 */
				if self.tableView.infiniteScrollingView!.hasMoreData {
					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
						// Send the next starting offset.
						self.loadMoreData(with: self.arrayData.count)
					})
				}

		})
	}
	// MARK: - UITableView DataSource methods

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return arrayData.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		guard let cell: TableViewCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier, forIndexPath: indexPath) as? TableViewCell else {
			return UITableViewCell()
		}
		cell.textLabel?.text = arrayData[indexPath.row]

		return cell
	}

	// MARK: - Load more
	/**
     Load more adata
     - parameter offset: starting index
     */

	func loadMoreData(with offset: Int) {
		fetchData(offset)
	}
	/**
     Fetch More Data

     - parameter offset: offset value
     */

	func fetchData(offset: Int) {

		var arrResponseData = [String]()

		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			/**
             *  arrResponse data represent the array of data which will come from service
             */
			if offset == 0 {
				arrResponseData = ["Test1", "Test2", "Test3", "Test4", "Test5", "Test6", "Test7", "Test8", "Test9", "Test10", "Test11", "Test12", "Test13", "Test14", "Test15", "Test16", "Test17", "Test18", "Test19", "Test20"]
				self.arrayData = arrResponseData
				/**
                 In pull to refresh No more record should not display
                 */
				self.tableView.infiniteScrollingView?.hasMoreData = true
			} else {
				arrResponseData = ["Test21", "Test22", "Test23", "Test24", "Test25", "Test26", "Test27", "Test28", "Test29", "Test30"]
				self.arrayData.appendContentsOf(arrResponseData)
			}

			// sleep to show indicator for some time, though it's not required while service call.
			sleep(3)

			/**
             *  Remove the Loader of Pull to refresh/Infinite scroller added on extension
             */
			self.tableView.loaderStopAnimating()

			// Condition to stop load more data
			if arrResponseData.count < self.articlesLimit {
				/**
                 Has no more data false will show "No more record" at the bottom
                 */
				self.tableView.infiniteScrollingView?.hasMoreData = false
			}
			self.tableView.reloadData()

		})
	}
}
