# PullUpDownLibrary
===========
-> Swift 3.0

-> Xcode 8.0 Compatible 

-> Protcol Oriented Progarmming (Extension) 

## Summary

PullUpDownLibrary is the customizion of ICSPullToRefresh and DGElasticPullTo refresh Library.In infinite scroll it provide the falicity to add a label with text "No More Record" at the end of infinite scroller.It use elastic pull to refresh for pull to refresh.


## Use

-> Provide pull to refresh and infinite scroll view functionality.

-> In infinite scroll user can stop implementation on basis of particular scenerio.  

-> User can select the color and font for label "No More Record"


## Implementation

**Pull to refresh :**

tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in

        self?.fetchData(0)

    }, loadingView: loadingView)


** Load More Data :**

//Set the Color of Label 

var fontForInfiniteScrolling = UIFont(name: "HelveticaNeue-Bold", size: 15) ?? UIFont.boldSystemFontOfSize(17)

self.tableView.addInfiniteScrollingWithHandler(fontForInfiniteScrolling, fontColor: UIColor.redColor(), actionHandler: {

//condition to stop calling function
if self.tableView.infiniteScrollingView!.hasMoreData {   

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in

print("Infinite scroller action")
})
}
}

/**

// Set this to false if there is no more data on the server. This should be triggered in the service response.
self.tableView.infiniteScrollingView?.hasMoreData = false

hasMoreData false will display "No more record" Label at the bottom of the tableview.
*/

**Remove Loader :**

self.infiniteScrollingView?.stopAnimating()



## License
PullUpDownLibrary is available under the MIT License

If you use it and like it, let me know: 
[@sarishti](sarishti09@gmail.com)

