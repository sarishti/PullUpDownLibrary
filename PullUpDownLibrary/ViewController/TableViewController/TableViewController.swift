//
//  TableViewController.swift
//  PullUpDownLibrary
//
//  Created by Sarishti on 9/8/16.
//  Copyright © 2016 sarishti. All rights reserved.
//

import UIKit


class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

	// MARK: - Properties

	let tableViewCellIdentifier = "TableViewCell"
    var option = PullToRefreshOption()

	/// Outlet
	@IBOutlet weak var tableView: UITableView!

	/// array
	var arrayData = [String]()

	/// Paggination Limit
	let articlesLimit = 20

    /// Bool
    var stopInfiniteLoader = false


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

	override func viewDidLoad() {
		super.viewDidLoad()

        self.setPullToRefreshOnTable()
        self.self.setInfiniteScrollOnTable()
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
        /// Set the loading view's indicator color
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.gray

        /// Add handler
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.tableView.hasMoreData = true
            self?.stopInfiniteLoader = false
            self?.fetchData(0)
            }, loadingView: loadingView)

        /// Set the background color of pull to refresh
        tableView.dg_setPullToRefreshFillColor(#colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tableView.fixedPullToRefreshViewForDidScroll()
    }

	// MARK: - Infinite scrolling
	/**
     Set reuseable component Infinite scroller handler
     */

    func setInfiniteScrollOnTable() {
            self.tableView.addPushRefreshHandler({ [weak self] in
            self?.stopInfiniteLoader = true
            // Send the next starting offset.
            self?.loadMoreData(with: (self?.arrayData.count)!)

            })
    }

	// MARK: - UITableView DataSource methods

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return arrayData.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		guard let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath) as? TableViewCell else {
			return UITableViewCell()
		}
		cell.textLabel?.text = arrayData[(indexPath as NSIndexPath).row]


		return cell
	}

	// MARK: - Load more
	/**
     Load more data
     - parameter offset: starting index
     */

	func loadMoreData(with offset: Int) {
		fetchData(offset)
	}
	/**
     Fetch More Data

     - parameter offset: offset value
     */

	func fetchData(_ offset: Int) {

		var arrResponseData = [String]()

		DispatchQueue.main.async(execute: { () -> Void in
			/**
             *  arrResponse data represent the array of data which will come from service
             */
			if offset == 0 {
				arrResponseData = ["Test1", "Test2", "Test3", "Test4", "Test5", "Test6", "Test7", "Test8", "Test9", "Test10", "Test11", "Test12", "Test13", "Test14", "Test15", "Test16", "Test17", "Test18", "Test19", "Test20"]
				self.arrayData = arrResponseData

			} else {
				arrResponseData = ["Test21", "Test22", "Test23", "Test24", "Test25", "Test26", "Test27", "Test28", "Test29", "Test30"]
				self.arrayData.append(contentsOf: arrResponseData)
			}

			// sleep to show indicator for some time, though it's not required while service call.
			sleep(1)

			// Condition to stop load more data
			if arrResponseData.count < self.articlesLimit {
                // hasMoreData false will stop the calling of service next time.
                self.tableView.hasMoreData = false
            }
            // Stop the loader and stopInfiniteLoader is used to indicate that infiniteLoader have to stop
            self.tableView.loaderStopAnimating(self.stopInfiniteLoader)
		    self.tableView.reloadData()

		})
	}
}
