# PullUpDownLibrary
===========
Swift 3.0
Xcode 8
Protcol Oriented Progarmming (Extension) 

## Summary

PullUpDownLibrary is the customizion of DGElastic and Pull to refresh library.


## Use

-> Provide pull to refresh and infinite scroll view functionality.

-> In inifite scroll user can stop implementation on basis of particular scenerio.  



## Implementation

**Pull to refresh :**

/// Set the loading view's indicator color

let loadingView = DGElasticPullToRefreshLoadingViewCircle()
loadingView.tintColor = UIColor.gray

/// Add handler

        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
                print("Pull to refersh ")
        }, loadingView: loadingView)


/// Set the background color of pull to refresh

tableView.dg_setPullToRefreshFillColor(#colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1))
tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)

// Call method of scroll view


func scrollViewDidScroll(_ scrollView: UIScrollView) {
self.tableView.fixedPullToRefreshViewForDidScroll()
}



** Load More Data :**

self.tableView.addPushRefreshHandler({ [weak self] in
    print("Infinite scroll content")

})
}

/**

// Set this to false if there is no more data on the server. This should be triggered in the service response.
self.tableView.hasMoreData = false

*/

**Remove Loader :**

// for pull to refersh

        self.dg_stopLoading()

// For infinite scroll

        self.stopPushRefreshEver()


If you use it and like it, let me know: 
[@sarishti](sarishti09@gmail.com)

